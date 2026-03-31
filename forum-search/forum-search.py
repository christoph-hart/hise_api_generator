#!/usr/bin/env python3
"""
HISE Forum Search Tool

Pre-filters and cleans HISE forum search results for LLM consumption.
Reduces token usage by ~90% compared to raw WebFetch of the NodeBB API.

Usage:
    # Search - returns filtered topic list with signal scores
    python forum-search.py search "ScriptSlider" --also "knob filmstrip"

    # Fetch - returns cleaned post content for selected topics
    python forum-search.py fetch 3630 5460

    # Update - search + diff + fetch + combine in one pass (primary command)
    python forum-search.py update "LFO" --also "lfo modulation" --scope modules:LFO

    # Extract code - extract code fences from combined topic file (upvote > 0)
    python forum-search.py extract-code --scope api:ScriptPanel

    # Refresh trusted posters from forum reputation API
    python forum-search.py refresh-users --min-reputation 100
"""

import argparse
import html
import io
import json
import os
import re
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from datetime import datetime, timezone
from pathlib import Path

# Force UTF-8 output on Windows (avoids cp1252 encoding errors)
if sys.stdout.encoding != "utf-8":
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", errors="replace")
if sys.stderr.encoding != "utf-8":
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding="utf-8", errors="replace")

SCRIPT_DIR = Path(__file__).parent
CONFIG_PATH = SCRIPT_DIR / "forum_search" / "config.json"
SCANNED_PATH = SCRIPT_DIR / "forum_search" / "forum_scanned.json"
CACHE_DIR = SCRIPT_DIR / "forum_cache"

FORUM_BASE = "https://forum.hise.audio"
API_BASE = f"{FORUM_BASE}/api"

# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------

def load_config():
    if CONFIG_PATH.exists():
        with open(CONFIG_PATH, "r", encoding="utf-8") as f:
            return json.load(f)
    return default_config()


def default_config():
    return {
        "trusted_posters": {},
        "excluded_categories": [4, 20],
        "category_weights": {
            "7": 0.15, "2": 0.10, "3": 0.10, "15": 0.10,
            "5": 0.05, "17": 0.05, "8": 0.05
        },
        "scoring": {
            "trusted_poster_reply": 0.30,
            "high_reply_count_threshold": 10,
            "high_reply_count_weight": 0.20,
            "solved_weight": 0.10,
            "recency_weight": 0.10,
            "recency_months": 12,
            "upvote_weight": 0.05
        },
        "defaults": {
            "max_age_years": 10,
            "max_search_pages": 3,
            "max_posts_per_topic": 30,
            "max_post_words": 500
        }
    }


def save_config(config):
    CONFIG_PATH.parent.mkdir(parents=True, exist_ok=True)
    with open(CONFIG_PATH, "w", encoding="utf-8") as f:
        json.dump(config, f, indent=2, ensure_ascii=False)


# ---------------------------------------------------------------------------
# Scanned tracker
# ---------------------------------------------------------------------------

def load_scanned():
    if SCANNED_PATH.exists():
        with open(SCANNED_PATH, "r", encoding="utf-8") as f:
            return json.load(f)
    return {}


def save_scanned(scanned):
    SCANNED_PATH.parent.mkdir(parents=True, exist_ok=True)
    with open(SCANNED_PATH, "w", encoding="utf-8") as f:
        json.dump(scanned, f, indent=2, ensure_ascii=False)


# ---------------------------------------------------------------------------
# HTTP helpers
# ---------------------------------------------------------------------------

def api_get(endpoint, params=None, retries=2, delay=1.0):
    """GET from the NodeBB API with retry and rate-limit awareness."""
    url = f"{API_BASE}/{endpoint}"
    if params:
        url += "?" + urllib.parse.urlencode(params)

    for attempt in range(retries + 1):
        try:
            req = urllib.request.Request(url, headers={
                "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
                "Accept": "application/json"
            })
            with urllib.request.urlopen(req, timeout=15) as resp:
                return json.loads(resp.read().decode("utf-8"))
        except urllib.error.HTTPError as e:
            if e.code == 429 and attempt < retries:
                time.sleep(delay * (attempt + 1))
                continue
            raise
        except urllib.error.URLError as e:
            if attempt < retries:
                time.sleep(delay)
                continue
            raise


# ---------------------------------------------------------------------------
# Cache helpers
# ---------------------------------------------------------------------------

def ensure_cache_dir():
    CACHE_DIR.mkdir(parents=True, exist_ok=True)


def cache_topic(tid, data):
    """Cache a processed topic to disk."""
    ensure_cache_dir()
    path = CACHE_DIR / f"topic_{tid}.json"
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)


def load_cached_topic(tid):
    """Load a previously cached topic."""
    path = CACHE_DIR / f"topic_{tid}.json"
    if path.exists():
        with open(path, "r", encoding="utf-8") as f:
            return json.load(f)
    return None


# ---------------------------------------------------------------------------
# Content cleaning
# ---------------------------------------------------------------------------

def clean_post_content(html_content, max_words=500):
    """Convert HTML post content to clean, compact text."""
    text = html_content

    # Remove HiseSnippet blocks (base64 encoded, typically in <pre><code>)
    text = re.sub(
        r'<pre><code>\s*HiseSnippet\s+[A-Za-z0-9+/=.\s]{50,}\s*</code></pre>',
        '[HiseSnippet omitted]',
        text,
        flags=re.DOTALL
    )

    # Also catch HiseSnippets outside code blocks
    text = re.sub(
        r'HiseSnippet\s+[A-Za-z0-9+/=]{100,}',
        '[HiseSnippet omitted]',
        text
    )

    # Remove blockquote duplicates (quoted replies) - keep a short summary
    def shorten_quote(m):
        inner = m.group(1).strip()
        plain = strip_html(inner)
        first_line = plain.split('\n')[0][:100]
        if first_line:
            return f'[Quoting: {first_line}...]'
        return '[Quote omitted]'

    text = re.sub(
        r'<blockquote>\s*(.*?)\s*</blockquote>',
        shorten_quote,
        text,
        flags=re.DOTALL
    )

    # Convert code blocks
    text = re.sub(r'<pre><code>(.*?)</code></pre>', r'```\n\1\n```', text, flags=re.DOTALL)
    text = re.sub(r'<code>(.*?)</code>', r'`\1`', text, flags=re.DOTALL)

    # Strip emoji images entirely
    text = re.sub(r'<img[^>]*class="[^"]*emoji[^"]*"[^>]*/?\s*>', '', text)

    # Convert regular images to alt-text placeholders
    def img_to_alt(m):
        alt = m.group(1) or "image"
        return f'[image: {alt}]'
    text = re.sub(r'<img[^>]*alt="([^"]*)"[^>]*/?\s*>', img_to_alt, text)
    text = re.sub(r'<img[^>]*/?\s*>', '[image]', text)

    # Convert links
    text = re.sub(r'<a[^>]*href="([^"]*)"[^>]*>(.*?)</a>', r'\2 (\1)', text, flags=re.DOTALL)

    # Convert basic HTML structure
    text = re.sub(r'<br\s*/?\s*>', '\n', text)
    text = re.sub(r'<p[^>]*>', '\n', text)
    text = re.sub(r'</p>', '', text)
    text = re.sub(r'<li[^>]*>', '- ', text)
    text = re.sub(r'</li>', '\n', text)
    text = re.sub(r'<h[1-6][^>]*>(.*?)</h[1-6]>', r'\n## \1\n', text, flags=re.DOTALL)
    text = re.sub(r'<strong>(.*?)</strong>', r'**\1**', text, flags=re.DOTALL)
    text = re.sub(r'<em>(.*?)</em>', r'*\1*', text, flags=re.DOTALL)

    # Strip all remaining HTML tags
    text = re.sub(r'<[^>]+>', '', text)

    # Decode HTML entities
    text = html.unescape(text)

    # Collapse whitespace
    text = re.sub(r'\n{3,}', '\n\n', text)
    text = re.sub(r' {2,}', ' ', text)
    text = text.strip()

    # Truncate to max words
    words = text.split()
    if len(words) > max_words:
        text = ' '.join(words[:max_words]) + ' [... truncated]'

    return text


def strip_html(text):
    """Quick HTML tag stripper for summaries."""
    text = re.sub(r'<[^>]+>', '', text)
    return html.unescape(text).strip()


def extract_brief(html_content, max_words=50):
    """Extract a short plain-text brief from HTML post content."""
    text = html_content
    text = re.sub(r'<pre><code>\s*HiseSnippet\s+[A-Za-z0-9+/=.\s]{50,}\s*</code></pre>', '', text, flags=re.DOTALL)
    text = re.sub(r'HiseSnippet\s+[A-Za-z0-9+/=]{100,}', '', text)
    text = re.sub(r'<blockquote>.*?</blockquote>', '', text, flags=re.DOTALL)
    text = re.sub(r'<pre><code>.*?</code></pre>', '[code]', text, flags=re.DOTALL)
    text = re.sub(r'<img[^>]*class="[^"]*emoji[^"]*"[^>]*/?\s*>', '', text)
    text = re.sub(r'<img[^>]*/?\s*>', '', text)
    text = re.sub(r'<[^>]+>', ' ', text)
    text = html.unescape(text)
    text = re.sub(r'\s+', ' ', text).strip()
    words = text.split()
    if len(words) > max_words:
        text = ' '.join(words[:max_words]) + '...'
    return text


# ---------------------------------------------------------------------------
# Signal scoring
# ---------------------------------------------------------------------------

def score_topic(topic_meta, config, search_posts=None):
    """Compute a 0-1 signal score for a topic based on config weights."""
    scoring = config["scoring"]
    trusted = config.get("trusted_posters", {})
    cat_weights = config.get("category_weights", {})
    score = 0.0

    cid = str(topic_meta.get("cid", ""))
    score += cat_weights.get(cid, 0.0)

    postcount = topic_meta.get("postcount", 1)
    if postcount >= scoring["high_reply_count_threshold"]:
        score += scoring["high_reply_count_weight"]

    if topic_meta.get("isSolved"):
        score += scoring["solved_weight"]

    ts = topic_meta.get("timestamp", 0)
    if ts:
        age_months = (time.time() * 1000 - ts) / (1000 * 60 * 60 * 24 * 30)
        if age_months <= scoring["recency_months"]:
            score += scoring["recency_weight"]

    if search_posts:
        for post in search_posts:
            uid = str(post.get("uid", ""))
            if uid in trusted:
                score += scoring["trusted_poster_reply"]
                break

    if search_posts:
        max_upvotes = max((p.get("upvotes", 0) for p in search_posts), default=0)
        if max_upvotes > 0:
            score += scoring["upvote_weight"] * min(max_upvotes / 5, 1.0)

    return min(score, 1.0)


# ---------------------------------------------------------------------------
# Topic fetching (shared by fetch and update)
# ---------------------------------------------------------------------------

def fetch_and_clean_topic(tid, config):
    """Fetch a topic from the API, clean it, cache it, and return the result."""
    defaults = config["defaults"]
    max_posts = defaults["max_posts_per_topic"]
    max_words = defaults.get("max_post_words", 500)
    trusted = config.get("trusted_posters", {})

    topic_data = fetch_topic_posts(tid, max_posts, trusted)

    cleaned_posts = []
    skipped_posts = 0
    for post in topic_data["posts"]:
        uid = str(post.get("uid", ""))
        username = post.get("user", {}).get("username", "Unknown")
        ts_iso = post.get("timestampISO", "")[:10]
        upvotes = post.get("upvotes", 0)
        is_trusted = uid in trusted
        is_op = bool(post.get("isMainPost"))
        # For signal filtering, only author/expert roles auto-keep;
        # other trusted posters still need upvotes to be included
        trusted_role = trusted.get(uid, {}).get("role", "") if is_trusted else ""
        is_authority = trusted_role in ("author", "expert")

        # Signal filter: OP, author/expert replies, and upvoted posts
        if not (is_op or is_authority or upvotes > 0):
            skipped_posts += 1
            continue

        content = clean_post_content(post.get("content", ""), max_words)
        if not content.strip():
            continue

        meta_parts = [username]
        if is_trusted:
            role = trusted[uid].get("role", "trusted")
            meta_parts[0] = f"{username} [{role}]"
        if ts_iso:
            meta_parts.append(ts_iso)
        if upvotes > 0:
            meta_parts.append(f"+{upvotes}")
        if is_op:
            meta_parts.append("OP")

        header = " | ".join(meta_parts)

        cleaned_posts.append({
            "uid": uid,
            "username": username,
            "is_trusted": is_trusted,
            "is_op": is_op,
            "upvotes": upvotes,
            "header": header,
            "content": content
        })

    # Sort: OP first, then trusted posters, then by upvotes
    def post_sort_key(p):
        return (
            0 if p["is_op"] else 1,
            0 if p["is_trusted"] else 1,
            -p["upvotes"]
        )
    cleaned_posts.sort(key=post_sort_key)

    topic_title = topic_data.get("title", f"Topic {tid}")
    topic_output = {
        "tid": tid,
        "title": topic_title,
        "url": f"{FORUM_BASE}/topic/{tid}",
        "post_count_total": topic_data.get("postcount", len(cleaned_posts)),
        "post_count_fetched": len(cleaned_posts),
        "posts": cleaned_posts
    }

    cache_topic(tid, topic_output)
    return topic_output


def fetch_topic_posts(tid, max_posts, trusted):
    """Fetch topic posts with smart pagination for large topics."""
    data = api_get(f"topic/{tid}")
    title = strip_html(data.get("titleRaw", data.get("title", f"Topic {tid}")))
    postcount = data.get("postcount", 0)
    all_posts = data.get("posts", [])

    page_count = data.get("pagination", {}).get("pageCount", 1)

    if page_count > 1:
        pages_to_fetch = set()

        if postcount <= max_posts:
            pages_to_fetch = set(range(2, page_count + 1))
        else:
            pages_to_fetch.add(2)
            if page_count > 2:
                pages_to_fetch.add(page_count)
            if page_count > 5:
                pages_to_fetch.add(page_count // 2)

        for page_num in sorted(pages_to_fetch):
            time.sleep(0.3)
            try:
                page_data = api_get(f"topic/{tid}", {"page": page_num})
                page_posts = page_data.get("posts", [])
                all_posts.extend(page_posts)
            except Exception as e:
                print(f"[warn] Failed to fetch page {page_num} of topic {tid}: {e}",
                      file=sys.stderr)

    # Deduplicate by pid
    seen_pids = set()
    unique_posts = []
    for post in all_posts:
        pid = post.get("pid")
        if pid and pid not in seen_pids:
            seen_pids.add(pid)
            unique_posts.append(post)

    # Limit total posts, but always keep trusted poster posts and OP
    if len(unique_posts) > max_posts:
        trusted_uids = set(trusted.keys())
        priority_posts = [p for p in unique_posts
                         if str(p.get("uid", "")) in trusted_uids
                         or p.get("isMainPost")]
        other_posts = [p for p in unique_posts
                      if str(p.get("uid", "")) not in trusted_uids
                      and not p.get("isMainPost")]
        other_posts.sort(key=lambda p: p.get("upvotes", 0), reverse=True)
        remaining_slots = max_posts - len(priority_posts)
        unique_posts = priority_posts + other_posts[:max(0, remaining_slots)]

    return {
        "title": title,
        "postcount": postcount,
        "posts": unique_posts
    }


# ---------------------------------------------------------------------------
# SEARCH command
# ---------------------------------------------------------------------------

def run_search(term, also_terms, config, include_features=False, max_pages=None, max_age=None):
    """Run a search and return the scored topic list. Used by both search and update."""
    terms = [term] + (also_terms or [])
    defaults = config["defaults"]
    max_pages = max_pages or defaults["max_search_pages"]
    max_age_years = max_age or defaults["max_age_years"]
    excluded_cats = set(config.get("excluded_categories", []))
    if include_features:
        excluded_cats.discard(4)

    cutoff_ts = (time.time() - max_age_years * 365.25 * 24 * 3600) * 1000

    topics = {}
    total_raw = 0
    total_filtered = 0
    filter_reasons = {"no_replies": 0, "excluded_category": 0, "too_old": 0, "duplicate": 0}

    for search_term in terms:
        for page in range(1, max_pages + 1):
            try:
                data = api_get("search", {
                    "term": search_term,
                    "in": "titlesposts",
                    "sortBy": "relevance",
                    "page": page
                })
            except Exception as e:
                print(f"[warn] Search failed for '{search_term}' page {page}: {e}", file=sys.stderr)
                break

            posts = data.get("posts", [])
            if not posts:
                break

            for post in posts:
                total_raw += 1
                topic = post.get("topic", {})
                tid = topic.get("tid")
                if not tid:
                    continue

                if tid in topics:
                    topics[tid]["posts"].append(post)
                    continue

                cat = post.get("category", {})
                cid = cat.get("cid", 0)
                if cid in excluded_cats:
                    total_filtered += 1
                    filter_reasons["excluded_category"] += 1
                    continue

                postcount = topic.get("postcount", 1)
                if postcount <= 1:
                    total_filtered += 1
                    filter_reasons["no_replies"] += 1
                    continue

                ts = topic.get("timestamp", 0)
                if ts and ts < cutoff_ts:
                    total_filtered += 1
                    filter_reasons["too_old"] += 1
                    continue

                brief = extract_brief(post.get("content", ""), max_words=50)

                topics[tid] = {
                    "tid": tid,
                    "title": strip_html(topic.get("titleRaw", topic.get("title", ""))),
                    "postcount": postcount,
                    "category": cat.get("name", "Unknown"),
                    "cid": cid,
                    "timestamp": ts,
                    "age_months": int((time.time() * 1000 - ts) / (1000 * 60 * 60 * 24 * 30)) if ts else 0,
                    "isSolved": bool(topic.get("isSolved")),
                    "brief": brief,
                    "posts": [post]
                }

            time.sleep(0.3)

    # Score topics
    trusted = config.get("trusted_posters", {})
    results = []
    for tid, t in topics.items():
        trusted_names = []
        for post in t["posts"]:
            uid = str(post.get("uid", ""))
            if uid in trusted:
                name = trusted[uid].get("name", post.get("user", {}).get("username", ""))
                if name not in trusted_names:
                    trusted_names.append(name)

        score = score_topic(t, config, t["posts"])

        results.append({
            "tid": t["tid"],
            "title": t["title"],
            "brief": t.get("brief", ""),
            "postcount": t["postcount"],
            "category": t["category"],
            "age_months": t["age_months"],
            "is_solved": t["isSolved"],
            "has_trusted_poster": len(trusted_names) > 0,
            "trusted_posters": trusted_names,
            "signal_score": round(score, 3)
        })

    results.sort(key=lambda x: x["signal_score"], reverse=True)

    return {
        "query_terms": terms,
        "max_age_years": max_age_years,
        "total_raw_results": total_raw,
        "topics_after_filter": len(results),
        "filtered_out": total_filtered,
        "filter_reasons": filter_reasons,
        "topics": results
    }


def cmd_search(args, config):
    """Search the forum and return a filtered, scored topic list."""
    output = run_search(
        args.term, args.also, config,
        include_features=getattr(args, 'include_features', False),
        max_pages=args.max_pages,
        max_age=args.max_age
    )

    # Cache processed output
    safe_primary = re.sub(r'[^a-zA-Z0-9_-]', '_', args.term)
    ensure_cache_dir()
    with open(CACHE_DIR / f"search_{safe_primary}.json", "w", encoding="utf-8") as f:
        json.dump(output, f, indent=2, ensure_ascii=False)

    print(json.dumps(output, indent=2, ensure_ascii=False))


# ---------------------------------------------------------------------------
# FETCH command
# ---------------------------------------------------------------------------

def cmd_fetch(args, config):
    """Fetch and clean specific topics by ID."""
    all_output = []

    for tid in args.tids:
        try:
            topic_output = fetch_and_clean_topic(tid, config)
            all_output.append(topic_output)
        except Exception as e:
            print(f"[warn] Failed to fetch topic {tid}: {e}", file=sys.stderr)
            continue

    # Output as readable text for LLM consumption
    for topic in all_output:
        print(f"{'=' * 70}")
        print(f"TOPIC: {topic['title']}")
        print(f"URL: {topic['url']}")
        print(f"Posts: {topic['post_count_fetched']}/{topic['post_count_total']} fetched")
        print(f"{'=' * 70}")
        print()
        for post in topic["posts"]:
            print(f"--- {post['header']} ---")
            print(post["content"])
            print()


# ---------------------------------------------------------------------------
# UPDATE command (primary command for the /update-forum agent)
# ---------------------------------------------------------------------------

def cmd_update(args, config):
    """Search + diff + fetch + combine in one pass.

    This is the primary command used by the /update-forum agent.
    It searches the forum, diffs against already-scanned topics for the given
    scope, fetches only new topics, combines all topics into a single output
    file, and updates the scanned tracker.
    """
    scope = args.scope
    if not scope:
        print("Error: --scope is required for update command", file=sys.stderr)
        sys.exit(1)

    # Validate scope format
    if ":" not in scope:
        print(f"Error: scope must be 'domain:target' (e.g., 'modules:LFO'), got '{scope}'",
              file=sys.stderr)
        sys.exit(1)

    # Step 1: Search
    print(f"[1/5] Searching forum for '{args.term}'...", file=sys.stderr)
    search_result = run_search(
        args.term, args.also, config,
        include_features=getattr(args, 'include_features', False)
    )
    all_topics = search_result["topics"]
    before_count = len(all_topics)

    # Filter 1: minimum signal score
    min_score = getattr(args, 'min_score', None) or 0.15
    all_topics = [t for t in all_topics if t["signal_score"] >= min_score]
    score_dropped = before_count - len(all_topics)

    # Filter 2: title relevance - require any search term (primary or --also) in the title
    # Uses stem matching: "Delay" also matches "Delaying", "Delayed", etc.
    all_terms = [args.term] + (args.also or [])
    term_patterns = [re.compile(r'\b' + re.escape(t), re.IGNORECASE) for t in all_terms]
    before_relevance = len(all_topics)
    all_topics = [t for t in all_topics
                  if any(p.search(t.get("title", "")) for p in term_patterns)]
    relevance_dropped = before_relevance - len(all_topics)

    all_tids = [t["tid"] for t in all_topics]
    print(f"      Found {before_count} topics, kept {len(all_tids)} "
          f"(score dropped {score_dropped}, title relevance dropped {relevance_dropped})",
          file=sys.stderr)

    # Step 2: Diff against scanned tracker
    scanned = load_scanned()
    scope_data = scanned.get(scope, {})
    already_scanned = set(scope_data.get("topicIds", []))
    new_tids = [tid for tid in all_tids if tid not in already_scanned]
    print(f"[2/5] Diff: {len(already_scanned)} already scanned, {len(new_tids)} new",
          file=sys.stderr)

    if not new_tids and not already_scanned:
        print("      No topics found. Nothing to do.", file=sys.stderr)
        print(json.dumps({"scope": scope, "status": "empty", "topics": 0}))
        return

    # Step 3: Fetch new topics (use cache for already-fetched ones)
    print(f"[3/5] Fetching {len(new_tids)} new topics...", file=sys.stderr)
    fetched_count = 0
    for tid in new_tids:
        # Check if already cached from a different scope
        cached = load_cached_topic(tid)
        if cached:
            print(f"      Topic {tid}: using cache", file=sys.stderr)
            continue

        try:
            fetch_and_clean_topic(tid, config)
            fetched_count += 1
            print(f"      Topic {tid}: fetched", file=sys.stderr)
        except Exception as e:
            print(f"      Topic {tid}: FAILED - {e}", file=sys.stderr)

    print(f"      Fetched {fetched_count} from API, {len(new_tids) - fetched_count} from cache",
          file=sys.stderr)

    # Step 4: Combine all topics into single output file
    print(f"[4/5] Combining {len(all_tids)} topics...", file=sys.stderr)
    combined = []
    for tid in all_tids:
        topic = load_cached_topic(tid)
        if topic:
            combined.append(topic)
        else:
            print(f"      Topic {tid}: not in cache, skipping", file=sys.stderr)

    # Write combined output
    safe_scope = scope.replace(":", "_")
    output_path = CACHE_DIR / f"{safe_scope}.json"
    ensure_cache_dir()
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(combined, f, indent=2, ensure_ascii=False)

    total_posts = sum(len(t.get("posts", [])) for t in combined)
    file_size = output_path.stat().st_size

    # File size sanity check
    MAX_COMBINED_SIZE = 400_000  # 400KB ~ 100k tokens
    if file_size > MAX_COMBINED_SIZE:
        print(f"      WARNING: Combined output is {file_size // 1024}KB "
              f"(>{MAX_COMBINED_SIZE // 1024}KB). Search terms may be too broad.",
              file=sys.stderr)

    # Step 5: Update scanned tracker
    print(f"[5/5] Updating scanned tracker...", file=sys.stderr)
    all_combined_tids = [t["tid"] for t in combined]
    scanned[scope] = {
        "lastRun": datetime.now(timezone.utc).strftime("%Y-%m-%d"),
        "queries": [args.term] + (args.also or []),
        "topicIds": sorted(set(list(already_scanned) + all_combined_tids))
    }
    save_scanned(scanned)

    # Output summary as JSON
    summary = {
        "scope": scope,
        "status": "ok",
        "search_results": len(all_tids),
        "already_scanned": len(already_scanned),
        "new_topics": len(new_tids),
        "fetched_from_api": fetched_count,
        "combined_topics": len(combined),
        "combined_posts": total_posts,
        "output_file": str(output_path),
        "file_size_bytes": file_size,
        "approx_tokens": file_size // 4
    }
    print(json.dumps(summary, indent=2, ensure_ascii=False))


# ---------------------------------------------------------------------------
# EXTRACT-CODE command
# ---------------------------------------------------------------------------

def cmd_extract_code(args, config):
    """Extract code fences from a combined topic file.

    Filters for posts with upvotes > 0 and extracts code blocks with
    surrounding context. Output is a JSON file ready for LLM consumption
    (method tagging, quality rating).
    """
    scope = args.scope
    if not scope:
        print("Error: --scope is required", file=sys.stderr)
        sys.exit(1)

    # Load combined topic file
    safe_scope = scope.replace(":", "_")
    input_path = CACHE_DIR / f"{safe_scope}.json"
    if not input_path.exists():
        print(f"Error: Combined file not found: {input_path}", file=sys.stderr)
        print(f"Run 'update' first with --scope {scope}", file=sys.stderr)
        sys.exit(1)

    with open(input_path, "r", encoding="utf-8") as f:
        topics = json.load(f)

    # Extract code blocks from posts with upvotes > 0
    code_blocks = []
    for topic in topics:
        tid = topic["tid"]
        title = topic["title"]

        for post in topic.get("posts", []):
            upvotes = post.get("upvotes", 0)
            if upvotes < 1:
                continue

            content = post.get("content", "")

            # Find code fences in the cleaned content
            # Pattern: ``` ... ``` (multiline)
            fences = list(re.finditer(r'```\n?(.*?)\n?```', content, re.DOTALL))
            if not fences:
                continue

            for fence in fences:
                code = fence.group(1).strip()

                # Skip empty or trivial code blocks (< 2 lines)
                lines = code.split('\n')
                if len(lines) < 2:
                    continue

                # Skip HiseSnippet remnants
                if code.startswith('HiseSnippet') or '[HiseSnippet' in code:
                    continue

                # Extract surrounding context (text before the code fence)
                pre_text = content[:fence.start()].strip()
                # Get last 2-3 sentences of context
                sentences = re.split(r'[.!?\n]', pre_text)
                sentences = [s.strip() for s in sentences if s.strip()]
                context = '. '.join(sentences[-3:]) if sentences else ""
                # Truncate context
                if len(context) > 200:
                    context = context[:200] + "..."

                code_blocks.append({
                    "tid": tid,
                    "topic_title": title,
                    "username": post.get("username", "Unknown"),
                    "is_trusted": post.get("is_trusted", False),
                    "upvotes": upvotes,
                    "context": context,
                    "code": code
                })

    # Write output
    output_path = CACHE_DIR / f"{safe_scope}_code.json"
    output = {
        "scope": scope,
        "total_code_blocks": len(code_blocks),
        "source_topics": len(topics),
        "filter": "upvotes > 0",
        "code_blocks": code_blocks
    }

    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(output, f, indent=2, ensure_ascii=False)

    # Print summary
    total_lines = sum(len(b["code"].split('\n')) for b in code_blocks)
    print(json.dumps({
        "scope": scope,
        "status": "ok",
        "code_blocks": len(code_blocks),
        "total_code_lines": total_lines,
        "source_topics": len(topics),
        "output_file": str(output_path),
        "file_size_bytes": output_path.stat().st_size,
        "approx_tokens": output_path.stat().st_size // 4
    }, indent=2, ensure_ascii=False))


# ---------------------------------------------------------------------------
# REFRESH-USERS command
# ---------------------------------------------------------------------------

def cmd_refresh_users(args, config):
    """Fetch users sorted by reputation and update config."""
    min_rep = args.min_reputation
    print(f"Fetching users with reputation >= {min_rep}...", file=sys.stderr)

    users = {}
    page = 1
    while True:
        try:
            data = api_get("users", {"section": "sort-reputation", "page": page})
        except Exception as e:
            print(f"[warn] Failed to fetch user page {page}: {e}", file=sys.stderr)
            break

        user_list = data.get("users", [])
        if not user_list:
            break

        found_below_threshold = False
        for user in user_list:
            rep = user.get("reputation", 0)
            if rep < min_rep:
                found_below_threshold = True
                break
            uid = str(user["uid"])
            users[uid] = {
                "name": user["username"],
                "reputation": rep,
                "postcount": user.get("postcount", 0),
                "role": "author" if uid == "1" else "trusted"
            }

        if found_below_threshold:
            break

        page_count = data.get("pagination", {}).get("pageCount", 1)
        if page >= page_count:
            break
        page += 1
        time.sleep(0.3)

    config["trusted_posters"] = users
    save_config(config)

    print(f"Updated config with {len(users)} trusted posters (reputation >= {min_rep}):",
          file=sys.stderr)
    for uid, info in sorted(users.items(), key=lambda x: x[1]["reputation"], reverse=True):
        print(f"  uid {uid:>5}: {info['name']:<25} rep={info['reputation']}", file=sys.stderr)

    print(json.dumps({"trusted_posters_count": len(users), "users": users}, indent=2))


# ---------------------------------------------------------------------------
# REBUILD command (re-filter cached topics without re-fetching)
# ---------------------------------------------------------------------------

def cmd_rebuild(args, config):
    """Re-filter per-topic cache files and rebuild the combined output.

    Applies the current signal filter (OP + trusted + upvoted) to existing
    cached topics without hitting the forum API. Use after changing the
    post filter logic.
    """
    scope = args.scope
    if not scope or ":" not in scope:
        print(f"Error: scope must be 'domain:target', got '{scope}'", file=sys.stderr)
        sys.exit(1)

    scanned = load_scanned()
    scope_data = scanned.get(scope, {})
    topic_ids = scope_data.get("topicIds", [])
    if not topic_ids:
        print(f"No scanned topics for scope '{scope}'", file=sys.stderr)
        sys.exit(1)

    trusted = config.get("trusted_posters", {})
    trusted_uids = set(trusted.keys())

    print(f"[1/2] Re-filtering {len(topic_ids)} cached topics for '{scope}'...",
          file=sys.stderr)
    combined = []
    total_before = 0
    total_after = 0

    for tid in topic_ids:
        topic = load_cached_topic(tid)
        if not topic:
            print(f"      Topic {tid}: not in cache, skipping", file=sys.stderr)
            continue

        posts = topic.get("posts", [])
        total_before += len(posts)

        # Apply signal filter: OP + author/expert + upvoted only
        def is_signal_post(p):
            if p.get("is_op"):
                return True
            if p.get("upvotes", 0) > 0:
                return True
            # Only auto-keep author/expert roles, not all trusted
            uid = str(p.get("uid", ""))
            role = trusted.get(uid, {}).get("role", "")
            return role in ("author", "expert")
        filtered = [p for p in posts if is_signal_post(p)]
        total_after += len(filtered)

        topic["posts"] = filtered
        topic["post_count_fetched"] = len(filtered)

        # Write filtered version back to per-topic cache
        cache_topic(tid, topic)
        combined.append(topic)

    # Write combined output
    safe_scope = scope.replace(":", "_")
    output_path = CACHE_DIR / f"{safe_scope}.json"
    ensure_cache_dir()
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(combined, f, indent=2, ensure_ascii=False)

    file_size = output_path.stat().st_size
    reduction = (1 - total_after / max(total_before, 1)) * 100

    print(f"[2/2] Rebuilt {len(combined)} topics", file=sys.stderr)
    print(f"      Posts: {total_before} -> {total_after} "
          f"({reduction:.0f}% reduction)", file=sys.stderr)
    print(f"      File: {file_size // 1024}KB", file=sys.stderr)

    MAX_COMBINED_SIZE = 400_000
    if file_size > MAX_COMBINED_SIZE:
        print(f"      WARNING: Still >{MAX_COMBINED_SIZE // 1024}KB. "
              f"Search terms may be too broad.", file=sys.stderr)

    summary = {
        "scope": scope,
        "status": "ok",
        "topics": len(combined),
        "posts_before": total_before,
        "posts_after": total_after,
        "reduction_pct": round(reduction, 1),
        "file_size_bytes": file_size,
        "approx_tokens": file_size // 4
    }
    print(json.dumps(summary, indent=2, ensure_ascii=False))


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(
        description="HISE Forum Search Tool - pre-filter and clean forum data for LLM pipelines"
    )
    subparsers = parser.add_subparsers(dest="command", required=True)

    # search
    sp_search = subparsers.add_parser("search", help="Search forum, return filtered topic list")
    sp_search.add_argument("term", help="Primary search term")
    sp_search.add_argument("--also", nargs="*", help="Additional search terms")
    sp_search.add_argument("--max-age", type=float, help="Max age in years (default: from config)")
    sp_search.add_argument("--max-pages", type=int, help="Max search result pages per term")
    sp_search.add_argument("--include-features", action="store_true",
                           help="Include Feature Requests category (normally excluded)")

    # fetch
    sp_fetch = subparsers.add_parser("fetch", help="Fetch and clean specific topics")
    sp_fetch.add_argument("tids", nargs="+", type=int, help="Topic IDs to fetch")

    # update (primary command for /update-forum agent)
    sp_update = subparsers.add_parser("update",
        help="Search + diff + fetch + combine in one pass")
    sp_update.add_argument("term", help="Primary search term")
    sp_update.add_argument("--also", nargs="*", help="Additional search terms")
    sp_update.add_argument("--scope", required=True,
                           help="Scope identifier (e.g., 'modules:LFO', 'api:ScriptPanel')")
    sp_update.add_argument("--min-score", type=float, default=0.15,
                            help="Minimum signal score to include a topic (default: 0.15)")
    sp_update.add_argument("--include-features", action="store_true",
                            help="Include Feature Requests category")

    # rebuild
    sp_rebuild = subparsers.add_parser("rebuild",
        help="Re-filter cached topics and rebuild combined output (no API calls)")
    sp_rebuild.add_argument("--scope", required=True,
                            help="Scope identifier (must match a previous update run)")

    # extract-code
    sp_code = subparsers.add_parser("extract-code",
        help="Extract code fences from combined topic file (upvote > 0)")
    sp_code.add_argument("--scope", required=True,
                         help="Scope identifier (must match a previous update run)")

    # refresh-users
    sp_refresh = subparsers.add_parser("refresh-users",
        help="Update trusted posters from forum reputation")
    sp_refresh.add_argument("--min-reputation", type=int, default=100,
                           help="Minimum reputation threshold (default: 100)")

    args = parser.parse_args()
    config = load_config()

    if args.command == "search":
        cmd_search(args, config)
    elif args.command == "fetch":
        cmd_fetch(args, config)
    elif args.command == "update":
        cmd_update(args, config)
    elif args.command == "rebuild":
        cmd_rebuild(args, config)
    elif args.command == "extract-code":
        cmd_extract_code(args, config)
    elif args.command == "refresh-users":
        cmd_refresh_users(args, config)


if __name__ == "__main__":
    main()
