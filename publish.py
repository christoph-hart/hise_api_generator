#!/usr/bin/env python3
"""
Publish pipeline for HISE documentation.

Collects markdown from all enrichment pipeline outputs, resolves canonical
link tokens ($DOMAIN.Target$), applies MDC (Markdown Components) transforms
for Nuxt.js, validates links and images, and writes to a target directory.

Link syntax:  [display text]($DOMAIN.Target#fragment$)
Domains:      API, MODULES, UI, SN, DOC

Usage:
    python publish.py [output_dir]              # default: CWD
    python publish.py content/v2 --strict       # CI mode: fail on broken links
    python publish.py --dry-run                 # resolve + validate only, no file writes

Configuration lives in site_structure.json (same directory as this script).
"""

import argparse
import difflib
import json
import os
import re
import shutil
import sys
from pathlib import Path

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------

SCRIPT_DIR = Path(__file__).resolve().parent
SITE_STRUCTURE_PATH = SCRIPT_DIR / "site_structure.json"

# Enrichment pipeline directories (relative to SCRIPT_DIR)
ENRICHMENT_BASE_DIR = SCRIPT_DIR / "enrichment" / "base"
ENRICHMENT_WEBSITE_DIR = SCRIPT_DIR / "enrichment" / "output" / "website"
ENRICHMENT_PREVIEW_DIR = SCRIPT_DIR / "enrichment" / "output" / "preview"
MODULE_ENRICHMENT_OUTPUT_DIR = SCRIPT_DIR / "module_enrichment" / "output"
MODULE_LIST_PATH = SCRIPT_DIR / "module_enrichment" / "base" / "moduleList.json"


# ---------------------------------------------------------------------------
# Registry: builds the set of valid link targets for each domain
# ---------------------------------------------------------------------------

class LinkRegistry:
    """Holds all valid link targets, keyed by domain.

    Each domain maps canonical names (case-preserved) to URL paths.
    A parallel lowercase index enables case-insensitive lookup.
    """

    def __init__(self, site_structure: dict, script_dir: Path):
        self.structure = site_structure
        self.script_dir = script_dir
        # domain -> { canonical_key: url_path }
        self.targets = {}
        # domain -> { lowercase_key: canonical_key }
        self.lower_index = {}
        # domain -> { lowercase_key: canonical_key } (dash-stripped for DOC)
        self.normalized_index = {}

        self._build_api_registry()
        self._build_modules_registry()
        self._build_doc_registry()
        # UI and SN are future -- register empty domains so resolution
        # produces warnings instead of crashes
        for domain in ("UI", "SN"):
            if domain not in self.targets:
                self.targets[domain] = {}
                self.lower_index[domain] = {}
                self.normalized_index[domain] = {}

    def _build_api_registry(self):
        """Build API domain registry from enrichment/base/*.json."""
        targets = {}
        base_path = self.structure["domains"]["API"]["basePath"]
        base_dir = self.script_dir / "enrichment" / "base"

        if not base_dir.is_dir():
            self.targets["API"] = {}
            self.lower_index["API"] = {}
            self.normalized_index["API"] = {}
            return

        for json_path in sorted(base_dir.glob("*.json")):
            with open(json_path, "r", encoding="utf-8") as f:
                data = json.load(f)
            class_name = data["className"]
            slug = class_name.lower()

            # Class-level target: $API.ClassName$
            targets[class_name] = f"{base_path}/{slug}"

            # Method-level targets: $API.ClassName.method$
            for method_name in data.get("methods", {}).keys():
                key = f"{class_name}.{method_name}"
                targets[key] = f"{base_path}/{slug}#{method_name.lower()}"

        self.targets["API"] = targets
        self._build_indexes("API")

    def _build_modules_registry(self):
        """Build MODULES domain registry from moduleList.json."""
        targets = {}
        domain_config = self.structure["domains"]["MODULES"]
        base_path = domain_config["basePath"]
        type_mapping = domain_config.get("typeMapping", {})

        if not MODULE_LIST_PATH.is_file():
            self.targets["MODULES"] = {}
            self.lower_index["MODULES"] = {}
            self.normalized_index["MODULES"] = {}
            return

        with open(MODULE_LIST_PATH, "r", encoding="utf-8") as f:
            module_list = json.load(f)

        for module in module_list.get("modules", []):
            module_id = module["id"]
            module_type = module.get("type", "")
            module_subtype = module.get("subtype", "")

            # Find the directory mapping
            # Try type.subtype first, then type alone
            type_key = f"{module_type}.{module_subtype}" if module_subtype else module_type
            dir_path = type_mapping.get(type_key)
            if dir_path is None:
                dir_path = type_mapping.get(module_type)
            if dir_path is None:
                continue  # Unknown type, skip

            # Nuxt strips number prefixes from URLs
            url_segments = []
            for segment in dir_path.split("/"):
                # Strip leading "NN." prefix
                clean = re.sub(r"^\d+\.", "", segment)
                url_segments.append(clean)
            url_dir = "/".join(url_segments)

            slug = module_id.lower()
            targets[module_id] = f"{base_path}/{url_dir}/{slug}"

            # Parameter-level targets: $MODULES.ModuleId.ParamId$
            for param in module.get("parameters", []):
                param_id = param.get("id", "")
                if param_id:
                    key = f"{module_id}.{param_id}"
                    targets[key] = f"{base_path}/{url_dir}/{slug}#{param_id.lower()}"

        self.targets["MODULES"] = targets
        self._build_indexes("MODULES")

    def _build_doc_registry(self):
        """Build DOC domain registry by scanning the content directory.

        Since DOC pages use numbered prefixes (01.overview.md) that Nuxt
        strips, we scan the actual content dirs and register slug targets.
        """
        targets = {}
        domain_config = self.structure["domains"]["DOC"]
        base_path = domain_config["basePath"]
        subdomains = domain_config.get("subdomains", {})

        # Try to find the content root -- check common locations
        content_roots = [
            self.script_dir / ".." / ".." / ".." / "hise_website_v2" / "content" / "v2",
            Path("D:/Development/Projekte/hise_website_v2/content/v2"),
        ]

        content_root = None
        for root in content_roots:
            if root.is_dir():
                content_root = root.resolve()
                break

        if content_root is None:
            # Can't scan -- register empty
            self.targets["DOC"] = {}
            self.lower_index["DOC"] = {}
            self.normalized_index["DOC"] = {}
            return

        for subdomain_name, dir_name in subdomains.items():
            section_dir = content_root / dir_name
            if not section_dir.is_dir():
                continue

            for md_file in section_dir.rglob("*.md"):
                if md_file.name.startswith("_") or md_file.name.startswith("."):
                    continue
                if md_file.name.lower() == "readme.md":
                    continue

                # Build the slug by stripping number prefixes from each segment
                rel = md_file.relative_to(section_dir)
                slug_parts = []
                for part in rel.parts:
                    # Strip .md extension from filename
                    name = part
                    if name.endswith(".md"):
                        name = name[:-3]
                    # Strip leading "NN." prefix
                    name = re.sub(r"^\d+\.", "", name)
                    if name and name.lower() != "index":
                        slug_parts.append(name)

                if not slug_parts:
                    continue

                slug = "/".join(slug_parts)
                # Key format: SubdomainName.SlugPart1.SlugPart2
                # e.g., Architecture.data-model or Guide.building-a-sampler
                key_parts = [subdomain_name] + slug_parts
                key = ".".join(key_parts)
                targets[key] = f"{base_path}/{dir_name}/{slug}"

        self.targets["DOC"] = targets
        self._build_indexes("DOC")

    def _build_indexes(self, domain: str):
        """Build case-insensitive and normalized indexes for a domain."""
        lower = {}
        normalized = {}
        for key in self.targets[domain]:
            lk = key.lower()
            lower[lk] = key
            # Normalized: lowercase + strip dashes (for DOC fuzzy matching)
            nk = lk.replace("-", "").replace("_", "")
            normalized[nk] = key
        self.lower_index[domain] = lower
        self.normalized_index[domain] = normalized

    def resolve(self, domain: str, target: str, fragment: str = None):
        """Resolve a link target within a domain.

        Returns (url, canonical_key, match_type) where match_type is one of:
        - "exact": exact match
        - "case": case-insensitive match
        - "normalized": dash/underscore-insensitive match
        - "fuzzy": difflib fuzzy match
        - None: no match found
        """
        if domain not in self.targets:
            return None, None, None

        targets = self.targets[domain]

        # 1. Exact match
        if target in targets:
            url = targets[target]
            if fragment:
                url = f"{url}#{fragment}" if "#" not in url else url
            return url, target, "exact"

        # 2. Case-insensitive exact match
        lower_idx = self.lower_index.get(domain, {})
        lower_target = target.lower()
        if lower_target in lower_idx:
            canonical = lower_idx[lower_target]
            url = targets[canonical]
            if fragment:
                url = f"{url}#{fragment}" if "#" not in url else url
            return url, canonical, "case"

        # 3. Normalized match (strip dashes, underscores)
        norm_idx = self.normalized_index.get(domain, {})
        norm_target = lower_target.replace("-", "").replace("_", "")
        if norm_target in norm_idx:
            canonical = norm_idx[norm_target]
            url = targets[canonical]
            if fragment:
                url = f"{url}#{fragment}" if "#" not in url else url
            return url, canonical, "normalized"

        # 4. Fuzzy match using difflib
        all_keys = list(targets.keys())
        # Compare lowercase for better fuzzy matching
        all_lower = [k.lower() for k in all_keys]
        matches = difflib.get_close_matches(lower_target, all_lower, n=1, cutoff=0.6)
        if matches:
            # Find the original-case key
            match_idx = all_lower.index(matches[0])
            canonical = all_keys[match_idx]
            url = targets[canonical]
            if fragment:
                url = f"{url}#{fragment}" if "#" not in url else url
            return url, canonical, "fuzzy"

        return None, None, None

    def resolve_compound(self, domain: str, parts: list, fragment: str = None):
        """Resolve a compound target like API.ClassName.method by trying
        progressively from full compound down to class-only.

        For API: try "ClassName.method" first, then "ClassName"
        For MODULES: try "ModuleId.ParamId" first, then "ModuleId"
        For DOC: try "Subdomain.slug1.slug2" as full key
        """
        # Try full compound key
        full_key = ".".join(parts)
        url, canonical, match_type = self.resolve(domain, full_key, fragment)
        if url:
            return url, canonical, match_type

        # For API/MODULES: if we have ClassName.method, try resolving
        # the class first (fuzzy), then the method within that class
        if domain in ("API", "MODULES") and len(parts) >= 2:
            # Resolve the class/module part
            class_target = parts[0]
            class_url, class_canonical, class_match = self.resolve(domain, class_target)

            if class_canonical:
                # Now try the full key with the corrected class name
                method_part = ".".join(parts[1:])
                corrected_key = f"{class_canonical}.{method_part}"
                url, canonical, match_type = self.resolve(domain, corrected_key, fragment)
                if url:
                    # The match type is the "worst" of the two resolutions
                    worst = _worst_match(class_match, match_type)
                    return url, canonical, worst

                # Try fuzzy on just the method within the class
                class_prefix = f"{class_canonical}."
                class_methods = {
                    k: v for k, v in self.targets[domain].items()
                    if k.startswith(class_prefix)
                }
                if class_methods:
                    method_keys = list(class_methods.keys())
                    method_lower = [k.lower() for k in method_keys]
                    target_lower = corrected_key.lower()
                    matches = difflib.get_close_matches(
                        target_lower, method_lower, n=1, cutoff=0.6
                    )
                    if matches:
                        match_idx = method_lower.index(matches[0])
                        canonical = method_keys[match_idx]
                        url = class_methods[canonical]
                        if fragment:
                            url = f"{url}#{fragment}" if "#" not in url else url
                        return url, canonical, "fuzzy"

        return None, None, None


def _worst_match(*match_types):
    """Return the least precise match type from a set."""
    order = {"exact": 0, "case": 1, "normalized": 2, "fuzzy": 3}
    worst = max(match_types, key=lambda m: order.get(m, 99))
    return worst


# ---------------------------------------------------------------------------
# Link token resolution
# ---------------------------------------------------------------------------

# Pattern: $DOMAIN.target.parts#fragment$ inside markdown links or standalone
LINK_TOKEN_PATTERN = re.compile(
    r'\$([A-Z]+)\.([^$#]+?)(?:#([^$]+))?\$'
)


def resolve_tokens(content: str, registry: LinkRegistry, filepath: str,
                   messages: list) -> str:
    """Replace all $DOMAIN.target$ tokens in content with resolved URLs.

    For tokens inside markdown links [text]($...$), replaces the URL part.
    For standalone $...$ tokens, replaces with the URL.
    """

    def _replace_token(m):
        domain = m.group(1)
        target_str = m.group(2)
        fragment = m.group(3)  # may be None

        parts = target_str.split(".")
        url, canonical, match_type = registry.resolve_compound(
            domain, parts, fragment
        )

        if url is None:
            messages.append({
                "level": "ERROR",
                "file": filepath,
                "token": m.group(0),
                "message": f"Unresolved link: {m.group(0)}"
            })
            # Leave the token as-is so it's visible in output
            return m.group(0)

        original_token = f"${domain}.{target_str}$"
        canonical_token = f"${domain}.{canonical}$"

        if match_type == "case":
            messages.append({
                "level": "INFO",
                "file": filepath,
                "token": original_token,
                "message": f"Case fix: {original_token} -> {canonical_token}"
            })
        elif match_type == "normalized":
            messages.append({
                "level": "INFO",
                "file": filepath,
                "token": original_token,
                "message": f"Normalized: {original_token} -> {canonical_token}"
            })
        elif match_type == "fuzzy":
            messages.append({
                "level": "WARN",
                "file": filepath,
                "token": original_token,
                "message": f"Fuzzy match: {original_token} -> {canonical_token}"
            })

        return url

    # Process markdown links: [text]($DOMAIN.target$)
    def _replace_md_link(m):
        before = m.group(1)  # [text](
        token_match = LINK_TOKEN_PATTERN.search(m.group(2))
        after = m.group(3)   # )
        if token_match:
            resolved = _replace_token(token_match)
            return f"{before}{resolved}{after}"
        return m.group(0)

    # First pass: resolve tokens inside markdown links
    content = re.sub(
        r'(\[[^\]]*\]\()(\$[A-Z]+\.[^$]+\$)(\))',
        _replace_md_link,
        content
    )

    # Second pass: resolve any remaining standalone tokens
    # (e.g., in see-also lines, YAML blocks)
    content = LINK_TOKEN_PATTERN.sub(_replace_token, content)

    return content


# ---------------------------------------------------------------------------
# MDC transforms (absorbed from postprocess_md.py)
# ---------------------------------------------------------------------------

def get_class_name_from_heading(lines):
    """Extract class name from the first # heading."""
    for line in lines:
        if line.startswith("# "):
            return line[2:].strip()
    return ""


def convert_h1_to_frontmatter(content):
    """Convert '# ClassName\\n*category*\\n\\nbrief\\n' to YAML frontmatter."""
    m = re.match(r'^# (.+)\n\*(\w+)\*\n\n(.+)\n\n', content)
    if not m:
        return content
    title = m.group(1)
    category = m.group(2)
    description = m.group(3)
    frontmatter = (f"---\ntitle: {title}\ncategory: {category}\n"
                   f"description: \"{description}\"\n---\n\n")
    return frontmatter + content[m.end():]


def convert_warning_blockquotes(content, messages=None, filepath=""):
    """Convert warning blockquotes to ::warning components.

    Supports two formats:
    1. New titled format:  > [!Warning:Title here] text...
    2. Legacy format:      > **Warning:** text...

    The placeholder $WARNING_TO_BE_REPLACED$ is treated as "no title" and
    emits an INFO message so untitled warnings can be found.
    """
    PLACEHOLDER = "$WARNING_TO_BE_REPLACED$"

    # New format: > [!Warning:title] text
    def replace_titled_warning(m):
        title = m.group(1).strip()
        text = m.group(2).strip()
        if title == PLACEHOLDER:
            if messages is not None:
                messages.append({
                    "level": "INFO",
                    "file": filepath,
                    "token": PLACEHOLDER,
                    "message": f"Untitled warning (needs title): {text[:60]}..."
                })
            return f"::warning\n{text}\n::"
        return f'::warning{{title="{title}"}}\n{text}\n::'

    content = re.sub(
        r'^> \[!Warning:([^\]]+)\]\s*(.+?)$',
        replace_titled_warning, content, flags=re.MULTILINE
    )

    # Legacy format: > **Warning:** text
    pattern = r'^> \*\*Warning:\*\* (.+?)$'

    def replace_warning(m):
        text = m.group(1)
        return f"::warning\n{text}\n::"

    return re.sub(pattern, replace_warning, content, flags=re.MULTILINE)


def convert_tip_blockquotes(content, messages=None, filepath=""):
    """Convert tip blockquotes (before ## Methods) to ::tip.

    Supports two formats:
    1. New titled format:  > [!Tip:Title here] text...
    2. Legacy format:      > plain blockquote text (not a warning)

    The placeholder $TIP_TO_BE_REPLACED$ is treated as "no title".
    """
    PLACEHOLDER = "$TIP_TO_BE_REPLACED$"

    # First pass: handle new titled format anywhere in the document
    def replace_titled_tip(m):
        title = m.group(1).strip()
        text = m.group(2).strip()
        if title == PLACEHOLDER:
            if messages is not None:
                messages.append({
                    "level": "INFO",
                    "file": filepath,
                    "token": PLACEHOLDER,
                    "message": f"Untitled tip (needs title): {text[:60]}..."
                })
            return f"::tip\n{text}\n::"
        return f'::tip{{title="{title}"}}\n{text}\n::'

    content = re.sub(
        r'^> \[!Tip:([^\]]+)\]\s*(.+?)$',
        replace_titled_tip, content, flags=re.MULTILINE
    )

    # Second pass: legacy plain blockquotes (before ## Methods only)
    lines = content.split('\n')
    result = []
    in_methods = False
    i = 0
    while i < len(lines):
        line = lines[i]
        if line.startswith("## Methods"):
            in_methods = True
        if (not in_methods and line.startswith("> ")
                and not line.startswith("> **Warning:")
                and not line.startswith("> **Warning*")
                and not line.startswith("> [!Warning:")
                and not line.startswith("> [!Tip:")):
            bq_lines = []
            while i < len(lines) and lines[i].startswith("> "):
                bq_lines.append(lines[i][2:])
                i += 1
            text = "\n".join(bq_lines)
            result.append(f"::tip\n{text}\n::")
            continue
        result.append(line)
        i += 1
    return "\n".join(result)


def convert_see_also(content, class_name):
    """Convert **See also:** lines to ::see-also MDC components.

    Handles two formats:
    - Plain: ClassName.methodName
    - Annotated: ClassName.methodName` -- description text
    Same-class references become anchor-only links (#methodname).
    Cross-class references link to /v2/scripting-api/classname#methodname.
    """
    slug = class_name.lower()
    pattern = r'^\*\*See also:\*\* (.+)$'

    def replace_see_also(m):
        line = m.group(1)
        items = re.split(r',\s*(?=[A-Z]\w*\.)', line)
        if not items:
            return m.group(0)

        yaml_links = []
        for item in items:
            item = item.strip().rstrip(',')
            if not item:
                continue

            ann_match = re.match(r'([A-Z]\w*\.\w+)`?\s*--\s*(.+)', item, re.DOTALL)
            if ann_match:
                ref = ann_match.group(1).strip()
                desc = ann_match.group(2).strip().replace('"', '\\"')
                cls, method = ref.split('.', 1)
                if cls.lower() == slug:
                    yaml_links.append(
                        f'  - {{ label: "{method}", to: "#{method.lower()}", desc: "{desc}" }}'
                    )
                else:
                    yaml_links.append(
                        f'  - {{ label: "{ref}", to: "/v2/scripting-api/{cls.lower()}#{method.lower()}", desc: "{desc}" }}'
                    )
            else:
                ref = item.strip('` ')
                if '.' in ref:
                    cls, method = ref.split('.', 1)
                    if cls.lower() == slug:
                        yaml_links.append(
                            f'  - {{ label: "{method}", to: "#{method.lower()}" }}'
                        )
                    else:
                        yaml_links.append(
                            f'  - {{ label: "{ref}", to: "/v2/scripting-api/{cls.lower()}#{method.lower()}" }}'
                        )
                else:
                    yaml_links.append(
                        f'  - {{ label: "{ref}", to: "#{ref.lower()}" }}'
                    )

        if not yaml_links:
            return m.group(0)

        return "::see-also\n---\nlinks:\n" + "\n".join(yaml_links) + "\n---\n::"

    return re.sub(pattern, replace_see_also, content, flags=re.MULTILINE)


def convert_common_mistakes(content, messages=None, filepath=""):
    """Convert ## Common Mistakes section to ::common-mistakes component.

    Supports two formats:
    1. New titled format:
       - **Title here**
         **Wrong:** ...
         **Right:** ...
         *reason*

    2. Legacy format (no title):
       - **Wrong:** ...
         **Right:** ...
         *reason*
    """
    TITLE_PLACEHOLDER = "$COMMON_MISTAKE_TITLE_TO_BE_REPLACED$"

    # New format with title: - **Title**\n  **Wrong:** ...\n  **Right:** ...\n  *reason*
    titled_pattern = r'^## Common Mistakes\n\n((?:- \*\*[^W].*?\n(?:  .*?\n)*\n?)+)'

    def replace_titled_cm(m):
        block = m.group(1)
        entries = re.findall(
            r'- \*\*(.+?)\*\*\n  \*\*Wrong:\*\* (.+?)\n  \*\*Right:\*\* (.+?)\n  \*(.+?)\*',
            block
        )
        if not entries:
            return None  # Signal to try legacy format

        yaml_items = []
        for title, wrong, right, reason in entries:
            title = title.rstrip().replace('"', '\\"')
            wrong = wrong.rstrip().replace('\\', '\\\\').replace('"', '\\"')
            right = right.rstrip().replace('\\', '\\\\').replace('"', '\\"')
            reason = reason.rstrip().replace('\\', '\\\\').replace('"', '\\"')

            if title == TITLE_PLACEHOLDER:
                if messages is not None:
                    messages.append({
                        "level": "INFO",
                        "file": filepath,
                        "token": TITLE_PLACEHOLDER,
                        "message": f"Untitled common mistake (needs title): {wrong[:50]}..."
                    })
                yaml_items.append(
                    f'  - wrong: "{wrong}"\n'
                    f'    right: "{right}"\n'
                    f'    reason: "{reason}"'
                )
            else:
                yaml_items.append(
                    f'  - title: "{title}"\n'
                    f'    wrong: "{wrong}"\n'
                    f'    right: "{right}"\n'
                    f'    reason: "{reason}"'
                )

        return (
            "::common-mistakes\n---\nmistakes:\n"
            + "\n".join(yaml_items)
            + "\n---\n::\n"
        )

    # Try titled format first
    titled_match = re.search(titled_pattern, content, flags=re.MULTILINE)
    if titled_match:
        result = replace_titled_cm(titled_match)
        if result is not None:
            return content[:titled_match.start()] + result + content[titled_match.end():]

    # Legacy format: - **Wrong:** ...\n  **Right:** ...\n  *reason*
    legacy_pattern = r'^## Common Mistakes\n\n((?:- \*\*Wrong:\*\*.*?\n(?:  .*?\n)*\n?)+)'

    def replace_legacy_cm(m):
        block = m.group(1)
        entries = re.findall(
            r'- \*\*Wrong:\*\* (.+?)\n  \*\*Right:\*\* (.+?)\n  \*(.+?)\*',
            block
        )
        if not entries:
            return m.group(0)

        yaml_items = []
        for wrong, right, reason in entries:
            wrong = wrong.rstrip().replace('\\', '\\\\').replace('"', '\\"')
            right = right.rstrip().replace('\\', '\\\\').replace('"', '\\"')
            reason = reason.rstrip().replace('\\', '\\\\').replace('"', '\\"')
            yaml_items.append(
                f'  - wrong: "{wrong}"\n'
                f'    right: "{right}"\n'
                f'    reason: "{reason}"'
            )

        return (
            "::common-mistakes\n---\nmistakes:\n"
            + "\n".join(yaml_items)
            + "\n---\n::\n"
        )

    return re.sub(legacy_pattern, replace_legacy_cm, content, flags=re.MULTILINE)


def convert_method_headings(content):
    """Convert ### method + signature + param table to ::method-heading + code block."""
    lines = content.split('\n')
    result = []
    i = 0
    in_methods_section = False

    while i < len(lines):
        if lines[i].strip() == '## Methods':
            in_methods_section = True

        if (lines[i].startswith('### ')
                and not lines[i].startswith('### #')
                and i + 2 < len(lines)):
            raw_heading = lines[i][4:].strip()
            sig_match = re.match(r'`?(?:\w+\s+)?(?:\w+\.)?(\w+)\(', raw_heading)
            method_name = sig_match.group(1) if sig_match else raw_heading.strip('` ')

            j = i + 1
            while j < len(lines) and lines[j].strip() == '':
                j += 1

            has_signature = (j < len(lines)
                             and lines[j].startswith('`')
                             and lines[j].endswith('`')
                             and '```' not in lines[j])

            if has_signature:
                signature = lines[j][1:-1]
                k = j + 1
            else:
                signature = None
                k = j

            while k < len(lines) and lines[k].strip() == '':
                k += 1

            params = []
            table_end = k
            if (k < len(lines)
                    and '| Parameter' in lines[k]
                    and '| Type' in lines[k]
                    and '| Description' in lines[k]):
                k += 1
                if k < len(lines) and lines[k].startswith('|---'):
                    k += 1

                while k < len(lines) and lines[k].startswith('| `'):
                    row = lines[k]
                    cells = [c.strip() for c in row.split('|')[1:-1]]
                    if len(cells) >= 3:
                        pname = cells[0].strip('` ')
                        ptype = cells[1].strip('` ')
                        pdesc = cells[2].strip().replace('"', '\\"')
                        params.append(
                            f'  - {{ name: {pname}, type: {ptype}, desc: "{pdesc}" }}'
                        )
                    k += 1
                table_end = k

            if has_signature or params or in_methods_section:
                if params:
                    result.append("::method-heading")
                    result.append("---")
                    result.append(f"name: {method_name}")
                    result.append("params:")
                    result.extend(params)
                    result.append("---")
                    result.append("::")
                else:
                    result.append(f'::method-heading{{name="{method_name}"}}')
                    result.append("::")

                if signature:
                    result.append("")
                    result.append("```javascript")
                    if not signature.rstrip().endswith(';'):
                        signature = signature.rstrip() + ';'
                    result.append(signature)
                    result.append("```")
                    result.append("")

                i = table_end
                continue
            else:
                result.append(lines[i])
                i += 1
                continue
        else:
            result.append(lines[i])
            i += 1

    return "\n".join(result)


def rewrite_svg_paths(content):
    """Rewrite relative SVG image links to absolute Nuxt paths."""
    return re.sub(
        r'!\[([^\]]*)\]\(([^)]*\.svg)\)',
        r'![\1](/images/v2/scripting-api/\2)',
        content
    )


def fix_blank_lines_after_code_blocks(content):
    """Ensure a blank line exists after every code block closing fence."""
    return re.sub(r'(\n```)\n([^\n`])', r'\1\n\n\2', content)


def apply_mdc_transforms(content: str, class_name: str,
                         messages: list = None, filepath: str = "") -> str:
    """Apply all MDC transformations to API markdown content."""
    content = convert_h1_to_frontmatter(content)
    content = convert_method_headings(content)
    content = convert_common_mistakes(content, messages, filepath)
    content = convert_warning_blockquotes(content, messages, filepath)
    content = convert_tip_blockquotes(content, messages, filepath)
    content = convert_see_also(content, class_name)
    content = rewrite_svg_paths(content)
    content = fix_blank_lines_after_code_blocks(content)
    return content


def apply_module_mdc_transforms(content: str, messages: list = None,
                                filepath: str = "") -> str:
    """Apply MDC transformations to module reference markdown.

    Module pages already contain most MDC components (::signal-path,
    ::parameter-table, ::modulation-table, ::category-tags) authored
    directly. We only need to convert:
    - **See also:** lines -> ::see-also
    - Warning/tip blockquotes -> ::warning / ::tip
    - Blank line fixes after code blocks
    """
    content = convert_warning_blockquotes(content, messages, filepath)
    content = convert_tip_blockquotes(content, messages, filepath)
    # Module see-also uses the same **See also:** format after backport
    # Extract a pseudo class_name from frontmatter moduleId for same-module anchors
    module_id = ""
    id_match = re.search(r'^moduleId:\s*(\S+)', content, re.MULTILINE)
    if id_match:
        module_id = id_match.group(1)
    content = convert_see_also(content, module_id)
    content = fix_blank_lines_after_code_blocks(content)
    return content


# ---------------------------------------------------------------------------
# Image validation
# ---------------------------------------------------------------------------

def validate_images(content: str, filepath: str, output_dir: Path,
                    messages: list):
    """Check that all image references point to existing files."""
    # Match ![alt](path) patterns
    for m in re.finditer(r'!\[[^\]]*\]\(([^)]+)\)', content):
        img_path = m.group(1)
        # Skip external URLs
        if img_path.startswith("http://") or img_path.startswith("https://"):
            continue
        # Resolve relative to output directory or as absolute from content root
        if img_path.startswith("/"):
            # Absolute path from site root -- check in public/ dir
            # The images typically live in public/images/
            check_paths = [
                output_dir / ".." / "public" / img_path.lstrip("/"),
                output_dir / img_path.lstrip("/"),
            ]
        else:
            file_dir = Path(filepath).parent
            check_paths = [file_dir / img_path]

        found = any(p.is_file() for p in check_paths)
        if not found:
            messages.append({
                "level": "WARN",
                "file": filepath,
                "token": img_path,
                "message": f"Image not found: {img_path}"
            })


# ---------------------------------------------------------------------------
# Source collection
# ---------------------------------------------------------------------------

def _slugify(title: str) -> str:
    """Convert a title to a URL slug."""
    slug = title.lower().strip()
    slug = re.sub(r'[^a-z0-9\s-]', '', slug)
    slug = re.sub(r'[\s]+', '-', slug)
    return slug


def _extract_frontmatter_field(content: str, field: str) -> str:
    """Extract a field value from YAML frontmatter."""
    m = re.search(rf'^{field}:\s*(.+)$', content, re.MULTILINE)
    if m:
        return m.group(1).strip().strip('"').strip("'")
    return ""


def _get_module_output_subdir(module_id: str, module_list_path: Path,
                               type_mapping: dict) -> str:
    """Look up a module's output subdirectory from moduleList.json + typeMapping."""
    if not module_list_path.is_file():
        return ""

    with open(module_list_path, "r", encoding="utf-8") as f:
        module_list = json.load(f)

    for module in module_list.get("modules", []):
        if module["id"] == module_id:
            module_type = module.get("type", "")
            module_subtype = module.get("subtype", "")
            type_key = f"{module_type}.{module_subtype}" if module_subtype else module_type
            dir_path = type_mapping.get(type_key) or type_mapping.get(module_type)
            if dir_path:
                return dir_path
            break
    return ""


# Cache for module list lookups
_module_list_cache = None


def _get_module_list(module_list_path: Path) -> list:
    """Load and cache moduleList.json modules array."""
    global _module_list_cache
    if _module_list_cache is not None:
        return _module_list_cache

    if not module_list_path.is_file():
        _module_list_cache = []
        return _module_list_cache

    with open(module_list_path, "r", encoding="utf-8") as f:
        data = json.load(f)
    _module_list_cache = data.get("modules", [])
    return _module_list_cache


def _resolve_module_subdir(module_id: str, module_list_path: Path,
                            type_mapping: dict) -> str:
    """Look up a module's output subdirectory using cached module list."""
    modules = _get_module_list(module_list_path)
    for module in modules:
        if module["id"] == module_id:
            module_type = module.get("type", "")
            module_subtype = module.get("subtype", "")
            type_key = f"{module_type}.{module_subtype}" if module_subtype else module_type
            return type_mapping.get(type_key) or type_mapping.get(module_type, "")
    return ""


def collect_sources(script_dir: Path, site_structure: dict) -> list:
    """Collect all markdown files from pipeline sources defined in site_structure.json.

    Returns list of (source_path, domain, relative_output_path) tuples.
    """
    sources = []

    for domain_name, domain_config in site_structure.get("domains", {}).items():
        domain_sources = domain_config.get("sources", {})
        content_dir = domain_config.get("contentDir", "")
        type_mapping = domain_config.get("typeMapping", {})

        # Pages: individual content files (API classes, module pages)
        pages_path = domain_sources.get("pages")
        if pages_path:
            pages_dir = script_dir / pages_path
            if pages_dir.is_dir():
                for md_file in sorted(pages_dir.glob("*.md")):
                    # Skip non-content files
                    if "_review" in md_file.name or "_llm" in md_file.name:
                        continue

                    if domain_name == "API":
                        # API: lowercase filename
                        out_rel = Path(content_dir) / md_file.name.lower()
                    elif type_mapping:
                        # Modules: use typeMapping to determine subdirectory
                        module_id = md_file.stem
                        registry_source = domain_config.get("registrySource", "")
                        module_list_path = script_dir / registry_source
                        subdir = _resolve_module_subdir(
                            module_id, module_list_path, type_mapping
                        )
                        if subdir:
                            out_rel = Path(content_dir) / subdir / md_file.name
                        else:
                            # Unknown module type, place in root
                            out_rel = Path(content_dir) / md_file.name
                    else:
                        # Default: preserve filename
                        out_rel = Path(content_dir) / md_file.name.lower()

                    sources.append((md_file, domain_name, out_rel, "pages"))

        # Static: index/overview pages placed by title-based slug
        static_path = domain_sources.get("static")
        if static_path:
            static_dir = script_dir / static_path
            if static_dir.is_dir():
                for md_file in sorted(static_dir.rglob("*.md")):
                    with open(md_file, "r", encoding="utf-8") as f:
                        file_content = f.read()

                    # Check for explicit placement override
                    placement = _extract_frontmatter_field(file_content, "placement")
                    if placement:
                        if placement == "/":
                            out_rel = Path(content_dir) / "index.md"
                        else:
                            out_rel = Path(content_dir) / placement / "index.md"
                    else:
                        # Derive from title
                        title = _extract_frontmatter_field(file_content, "title")
                        if title:
                            slug = _slugify(title)
                            # Root index: if the file is named index.md at the
                            # static root, it's the domain root
                            rel = md_file.relative_to(static_dir)
                            if rel == Path("index.md") or rel.name == "index.md" and len(rel.parts) == 1:
                                out_rel = Path(content_dir) / "index.md"
                            else:
                                out_rel = Path(content_dir) / slug / "index.md"
                        else:
                            # No title, use filename
                            stem = md_file.stem
                            if stem == "index":
                                out_rel = Path(content_dir) / "index.md"
                            else:
                                out_rel = Path(content_dir) / stem / "index.md"

                    sources.append((md_file, domain_name, out_rel, "static"))

    return sources


# ---------------------------------------------------------------------------
# Main pipeline
# ---------------------------------------------------------------------------

def collect_topology(content: str, registry: LinkRegistry, page_key: str,
                     source_path: str) -> dict:
    """Scan a file for all $DOMAIN$ tokens and classify as see-also or inline.

    Returns a dict with seeAlso and inlineLinks lists of canonical refs.
    """
    see_also = []
    inline_links = []

    # Check if we're in a see-also line context
    for line in content.split('\n'):
        is_see_also_line = (
            line.startswith("**See also:**") or
            line.startswith("**Cross References:**")
        )

        for m in LINK_TOKEN_PATTERN.finditer(line):
            domain = m.group(1)
            target_str = m.group(2)
            fragment = m.group(3)

            parts = target_str.split(".")
            url, canonical, match_type = registry.resolve_compound(
                domain, parts, fragment
            )

            if canonical:
                ref = f"{domain}.{canonical}"
            else:
                ref = f"{domain}.{target_str}"

            if is_see_also_line:
                if ref not in see_also:
                    see_also.append(ref)
            else:
                if ref not in inline_links:
                    inline_links.append(ref)

    # Also check markdown links [text]($DOMAIN.Target$) on non-see-also lines
    for line in content.split('\n'):
        is_see_also_line = (
            line.startswith("**See also:**") or
            line.startswith("**Cross References:**")
        )
        if is_see_also_line:
            continue

        for m in re.finditer(r'\[[^\]]+\]\(\$([A-Z]+)\.([^$#]+?)(?:#[^$]+)?\$\)', line):
            domain = m.group(1)
            target_str = m.group(2)
            parts = target_str.split(".")
            url, canonical, match_type = registry.resolve_compound(domain, parts)
            ref = f"{domain}.{canonical}" if canonical else f"{domain}.{target_str}"
            if ref not in inline_links and ref not in see_also:
                inline_links.append(ref)

    return {
        "source": source_path,
        "seeAlso": see_also,
        "inlineLinks": inline_links,
    }


def run_topology(topology_path: Path):
    """Scan all sources and emit a cross-reference topology JSON."""

    if not SITE_STRUCTURE_PATH.is_file():
        print(f"ERROR: {SITE_STRUCTURE_PATH} not found.")
        sys.exit(1)

    with open(SITE_STRUCTURE_PATH, "r", encoding="utf-8") as f:
        site_structure = json.load(f)

    print("Building link registry...")
    registry = LinkRegistry(site_structure, SCRIPT_DIR)
    for domain, targets in registry.targets.items():
        print(f"  {domain}: {len(targets)} targets")

    sources = collect_sources(SCRIPT_DIR, site_structure)
    if not sources:
        print("No source files found.")
        return

    print(f"\nScanning {len(sources)} files for cross-references...")

    pages = {}
    all_refs = {}  # page_key -> set of outgoing refs
    static_pages = set()  # pages from static sources (index/overview pages)

    for source_path, domain, out_rel, source_type in sources:
        with open(source_path, "r", encoding="utf-8") as f:
            content = f.read()

        # Derive page key from domain + identifier
        lines = content.split('\n')
        if domain == "API":
            name = get_class_name_from_heading(lines)
            page_key = f"API.{name}" if name else f"API.{out_rel.stem}"
        elif domain == "MODULES":
            if source_type == "static":
                # Static pages: use title for key
                title = _extract_frontmatter_field(content, "title")
                page_key = f"MODULES._static.{_slugify(title)}" if title else f"MODULES._static.{out_rel.stem}"
            else:
                # Module pages: use moduleId from frontmatter or filename
                module_id = _extract_frontmatter_field(content, "moduleId")
                if not module_id:
                    module_id = out_rel.stem
                page_key = f"MODULES.{module_id}"
        else:
            page_key = f"{domain}.{out_rel.stem}"

        rel_source = str(source_path.relative_to(SCRIPT_DIR)).replace("\\", "/")
        topo = collect_topology(content, registry, page_key, rel_source)
        topo["sourceType"] = source_type
        pages[page_key] = topo
        all_refs[page_key] = set(topo["seeAlso"] + topo["inlineLinks"])
        if source_type == "static":
            static_pages.add(page_key)

    # Detect bidirectional gaps (exclude static pages - they link to all
    # modules in their category as a directory listing, modules don't
    # need to link back to the index)
    gaps = []
    for page_key, outgoing in all_refs.items():
        if page_key in static_pages:
            continue  # Skip static -> content gaps
        for ref in outgoing:
            if ref in static_pages:
                continue  # Skip content -> static gaps
            # Check if the target page links back
            if ref in all_refs and page_key not in all_refs[ref]:
                gaps.append({
                    "from": page_key,
                    "to": ref,
                    "reverseExists": False,
                })

    # Statistics
    total_see_also = sum(len(p["seeAlso"]) for p in pages.values())
    total_inline = sum(len(p["inlineLinks"]) for p in pages.values())
    orphan_pages = [k for k, v in all_refs.items() if not v]

    topology = {
        "generated": __import__("datetime").datetime.now(
            __import__("datetime").timezone.utc
        ).isoformat(),
        "stats": {
            "totalPages": len(pages),
            "totalSeeAlso": total_see_also,
            "totalInlineLinks": total_inline,
            "bidirectionalGaps": len(gaps),
            "orphanPages": len(orphan_pages),
        },
        "pages": pages,
        "bidirectionalGaps": gaps,
        "orphanPages": orphan_pages,
    }

    with open(topology_path, "w", encoding="utf-8") as f:
        json.dump(topology, f, indent=2, ensure_ascii=False)

    print(f"\n{'=' * 60}")
    print(f"Topology written to {topology_path}")
    print(f"  Pages: {len(pages)}")
    print(f"  See-also links: {total_see_also}")
    print(f"  Inline links: {total_inline}")
    print(f"  Bidirectional gaps: {len(gaps)}")
    print(f"  Orphan pages (no outgoing links): {len(orphan_pages)}")


def run(output_dir: Path, strict: bool = False, dry_run: bool = False):
    """Main publish pipeline."""

    # Load site structure
    if not SITE_STRUCTURE_PATH.is_file():
        print(f"ERROR: {SITE_STRUCTURE_PATH} not found.")
        sys.exit(1)

    with open(SITE_STRUCTURE_PATH, "r", encoding="utf-8") as f:
        site_structure = json.load(f)

    # Build link registry
    print("Building link registry...")
    registry = LinkRegistry(site_structure, SCRIPT_DIR)
    for domain, targets in registry.targets.items():
        print(f"  {domain}: {len(targets)} targets")

    # Collect source files
    sources = collect_sources(SCRIPT_DIR, site_structure)
    if not sources:
        print("No source files found.")
        return

    print(f"\nProcessing {len(sources)} files...")

    messages = []
    files_written = 0

    for source_path, domain, out_rel, source_type in sources:
        with open(source_path, "r", encoding="utf-8") as f:
            content = f.read()

        # Extract class name before transforms modify the heading
        lines = content.split('\n')
        class_name = get_class_name_from_heading(lines)

        # Step 1: Resolve $DOMAIN.Target$ tokens
        content = resolve_tokens(content, registry, str(source_path), messages)

        # Step 2: Apply MDC transforms based on domain config
        mdc_transform = site_structure.get("domains", {}).get(domain, {}).get("mdcTransform", "")
        if mdc_transform == "api":
            content = apply_mdc_transforms(content, class_name, messages,
                                           str(source_path))
        elif mdc_transform == "module":
            content = apply_module_mdc_transforms(content, messages,
                                                   str(source_path))

        # Step 3: Validate images
        dest = output_dir / out_rel
        validate_images(content, str(source_path), output_dir, messages)

        # Step 4: Write output
        if not dry_run:
            dest.parent.mkdir(parents=True, exist_ok=True)
            with open(dest, "w", encoding="utf-8") as f:
                f.write(content)
            files_written += 1

    # Print summary
    print(f"\n{'=' * 60}")
    if dry_run:
        print(f"DRY RUN: {len(sources)} files processed, no files written")
    else:
        print(f"Published {files_written} files to {output_dir}")

    # Group messages by level
    errors = [m for m in messages if m["level"] == "ERROR"]
    warns = [m for m in messages if m["level"] == "WARN"]
    infos = [m for m in messages if m["level"] == "INFO"]

    if infos:
        print(f"\nINFO ({len(infos)}):")
        for m in infos:
            print(f"  {m['message']}")
            print(f"    in {m['file']}")

    if warns:
        print(f"\nWARN ({len(warns)}):")
        for m in warns:
            print(f"  {m['message']}")
            print(f"    in {m['file']}")

    if errors:
        print(f"\nERROR ({len(errors)}):")
        for m in errors:
            print(f"  {m['message']}")
            print(f"    in {m['file']}")

    print(f"\nSummary: {len(errors)} errors, {len(warns)} warnings, {len(infos)} info")

    if strict and errors:
        print("\n--strict mode: failing due to unresolved links")
        sys.exit(1)


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(
        description="Publish HISE documentation with link resolution and MDC transforms",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    parser.add_argument(
        "output_dir", nargs="?", default=".",
        help="Output directory for published files (default: current directory)",
    )
    parser.add_argument(
        "--strict", action="store_true",
        help="Exit with error code on any unresolved links (for CI)",
    )
    parser.add_argument(
        "--dry-run", action="store_true",
        help="Resolve and validate only, do not write files",
    )
    parser.add_argument(
        "--topology", metavar="FILE",
        help="Emit cross-reference topology JSON and exit (no publish)",
    )

    args = parser.parse_args()

    if args.topology:
        run_topology(Path(args.topology).resolve())
    else:
        output_dir = Path(args.output_dir).resolve()
        run(output_dir, strict=args.strict, dry_run=args.dry_run)


if __name__ == "__main__":
    main()
