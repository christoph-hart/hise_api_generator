#!/usr/bin/env python3
"""
Forum Code Example Validator

3-pass pipeline for validating HISE forum code examples:
  Pass 1 (--analyze):  AI analysis via Claude to generate setup code + REPL checks
  Pass 2 (--validate): HISE runtime compilation + REPL verification
  Pass 3 (--retry-failures): Re-analyze failures with error context, re-test

Input:  forum-search/code_examples/batch_*.json, snippet_batch_*.json
Output: forum-search/code_examples/validated/*.json (enriched with validation metadata)

Usage:
    python forum_validator.py --analyze --batch batch_001.json
    python forum_validator.py --analyze --all
    python forum_validator.py --validate --batch batch_001.json --launch
    python forum_validator.py --validate --all --launch
    python forum_validator.py --retry-failures --all --launch
    python forum_validator.py --coverage [--all | --batch X]
    python forum_validator.py --dry-run --batch batch_001.json --index 5
"""

import argparse
import json
import os
import re
import sys
import time
import traceback
from datetime import datetime, timezone
from pathlib import Path

# Add parent dir to path so we can import from snippet_validator
SCRIPT_DIR = Path(__file__).parent
PARENT_DIR = SCRIPT_DIR.parent
sys.path.insert(0, str(PARENT_DIR))

from snippet_validator import HISEAPIClient, HISELauncher, SnippetValidator, Colors

CODE_EXAMPLES_DIR = SCRIPT_DIR / "code_examples"
VALIDATED_DIR = CODE_EXAMPLES_DIR / "validated"
MAX_ATTEMPTS = 2


# ---------------------------------------------------------------------------
# Data helpers
# ---------------------------------------------------------------------------

def collect_batch_files():
    """Return sorted list of all batch JSON files."""
    files = sorted(CODE_EXAMPLES_DIR.glob("batch_*.json")) + \
            sorted(CODE_EXAMPLES_DIR.glob("snippet_batch_*.json"))
    return files


def load_batch(path: Path) -> list:
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def save_validated_batch(filename: str, entries: list):
    VALIDATED_DIR.mkdir(parents=True, exist_ok=True)
    out = VALIDATED_DIR / filename
    with open(out, "w", encoding="utf-8") as f:
        json.dump(entries, f, indent=2, ensure_ascii=False)
    return out


def load_validated_batch(filename: str) -> list:
    path = VALIDATED_DIR / filename
    if not path.exists():
        return []
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def topic_slug(url: str) -> str:
    """Extract a stable slug from forum URL: 'https://forum.hise.audio/topic/7486' -> 'topic-7486'"""
    m = re.search(r'/topic/(\d+)', url)
    return f"topic-{m.group(1)}" if m else url


# ---------------------------------------------------------------------------
# Tier classification (mechanical pre-filter before AI analysis)
# ---------------------------------------------------------------------------

# Patterns that indicate external resource dependencies (Tier 4 / skip)
EXTERNAL_PATTERNS = [
    r'\.loadImage\s*\(',
    r'Server\.\w+',
    r'Engine\.loadFontAs\w*\(',
]

# Patterns for module references (Tier 3)
MODULE_PATTERNS = [
    r'Synth\.getEffect\s*\(',
    r'Synth\.getSampler\s*\(',
    r'Synth\.getChildSynth\s*\(',
    r'Synth\.getMidiProcessor\s*\(',
    r'Synth\.getModulator\s*\(',
    r'Synth\.getMidiPlayer\s*\(',
    r'Synth\.getSlotFX\s*\(',
]

# Patterns for component references (Tier 2)
COMPONENT_PATTERNS = [
    r'Content\.getComponent\s*\(',
]


def classify_tier(code: str) -> int:
    """Classify example into testability tier (1-4) based on code patterns."""
    for pat in EXTERNAL_PATTERNS:
        if re.search(pat, code):
            return 4
    for pat in MODULE_PATTERNS:
        if re.search(pat, code):
            return 3
    for pat in COMPONENT_PATTERNS:
        if re.search(pat, code):
            return 2
    return 1


# ---------------------------------------------------------------------------
# AI Analysis prompt construction
# ---------------------------------------------------------------------------

ANALYSIS_SYSTEM_PROMPT = """\
You are analyzing HiseScript code examples from the HISE audio framework forum. \
For each example, you must generate test metadata that will allow automated \
validation via the HISE runtime REST API.

## Your Task

For each code example, produce a JSON object with these fields:

```json
{
  "tier": <int 1-4>,
  "testable": <bool>,
  "skipReason": <string or null>,
  "setupCode": <string or null>,
  "testOnlyCode": <string or null>,
  "verifyScript": <array of verification objects or null>,
  "notes": <string or null>
}
```

## Tier Classification

- **Tier 1**: No setup needed. Self-contained code (pure functions, LAF definitions, \
code that creates its own components via Content.add*).
- **Tier 2**: Needs UI component creation. Code calls Content.getComponent("name") \
for components that don't exist. Setup must create them.
- **Tier 3**: Needs audio module creation AND possibly components. Code calls \
Synth.getEffect, Synth.getSampler, etc. for modules that don't exist.
- **Tier 4**: Depends on external resources (images, server, sample maps, expansions). \
Mark testable: false.

## Setup Code Rules

Setup code is **prepended** to the example code before compilation. It must:

1. Include `Content.makeFrontInterface(600, 400);` if the example doesn't already have it
2. Create any UI components the example references via Content.getComponent:
   - Knobs/Sliders: `Content.addKnob("name", x, y);`
   - Buttons: `Content.addButton("name", x, y);`
   - Panels: `Content.addPanel("name", x, y);`
   - Labels: `Content.addLabel("name", x, y);`
   - ComboBoxes: `Content.addComboBox("name", x, y);`
   - Tables: `Content.addTable("name", x, y);`
   - SliderPacks: `Content.addSliderPack("name", x, y);`
   - Viewports: `Content.addViewport("name", x, y);`
   - AudioWaveforms: `Content.addAudioWaveform("name", x, y);`
   - FloatingTiles: `Content.addFloatingTile("name", x, y);`
3. Infer component type from:
   - Name prefix (Knob*, knb* -> addKnob; Button*, btn* -> addButton; Panel*, pnl* -> addPanel)
   - Method usage (.setPaintRoutine -> Panel; .addItem -> ComboBox; .setRange -> Knob)
   - Default to addKnob if ambiguous

For Tier 3, modules must be created SEPARATELY before the example compiles \
(they persist across recompilations). Use this pattern in setupCode, \
but prefix module creation lines with `// MODULE_SETUP: ` so the validator \
can split them into a separate compilation step:
```
// MODULE_SETUP: Synth.addEffect("SimpleGain", "Simple Gain1", -1);
// MODULE_SETUP: Synth.addEffect("SimpleGain", "Simple Gain2", -1);
Content.makeFrontInterface(600, 400);
Content.addKnob("Knob1", 0, 0);
```

## Test-Only Code

Code appended after the example that compiles with it but is hidden from end users. \
Use this for additional declarations or setup that must share scope with the example. \
Do NOT put callback triggers here — they won't work because callbacks aren't active \
during compilation. Instead, trigger callbacks via REPL verification steps (see below).

## Verification Script

Array of verification steps. Each step is one of:

### REPL verification
```json
{"type": "REPL", "expression": "variableName", "value": expectedValue, "delay": 0}
```
- `expression`: any valid HiseScript expression accessible in onInit scope
- `value`: expected result (number, string, bool, or "undefined")
- `delay`: milliseconds to wait before checking (use 100-300 for async, 0 for sync)

**IMPORTANT: Triggering callbacks via REPL.** Control callbacks set up with \
`setControlCallback` are NOT active during compilation. To test them, use a REPL \
step to trigger, then a subsequent REPL step to check the result:
```json
{"type": "REPL", "expression": "MyKnob.setValue(-6.0) || MyKnob.changed()", "value": 0, "delay": 0},
{"type": "REPL", "expression": "someVariable", "value": expectedAfterCallback, "delay": 200}
```
The `||` trick works because `setValue` and `changed` return undefined/0, so the \
expression evaluates to 0. The 200ms delay on the next step gives the callback time to fire.

### Log output verification
```json
{"type": "log-output", "values": ["expected", "log", "lines"]}
```
- Matches Console.print output in order

### Error expectation
```json
{"type": "expect-error", "errorMessage": "substring of expected error"}
```

## Important Guidelines

1. Only mark testable: false if truly untestable (external resources, modal dialogs like FileSystem.browse)
2. For LAF/paint routines: testable via compilation only. Set verifyScript to null — \
   successful compilation is sufficient.
3. For callback-only code (function onNoteOn, function onController): these are MIDI \
   callbacks that can't be triggered via REPL. Compilation test only.
4. Variables declared with `const var` in onInit scope are accessible via REPL.
5. Inline functions can be called from testOnlyCode.
6. REPL expressions must reference variables that exist after compilation.
7. `reg` variables persist globally. `var`/`const var` are script-scoped.
8. If the example uses Content.addKnob etc. to create its own components, \
   don't duplicate them in setup.
9. When computing expected REPL values, trace through the code carefully. \
   If the result depends on runtime state you can't predict, skip REPL verification.
"""


def build_analysis_prompt(entries: list, batch_name: str) -> str:
    """Build the user prompt for AI analysis of a batch of examples."""
    lines = [
        f"Analyze the following {len(entries)} code examples from batch `{batch_name}`.",
        "For each example, output a JSON array with one validation object per example, ",
        "in the same order as the input. Use the HISE MCP tools (query_scripting_api, ",
        "list_module_types, list_ui_components, query_ui_property) to look up any ",
        "unfamiliar APIs before generating setup code.",
        "",
        "Output ONLY the JSON array, no markdown fences or commentary.",
        "",
        "Examples:",
        ""
    ]

    for i, entry in enumerate(entries):
        lines.append(f"### Example {i} — {entry['title']}")
        lines.append(f"URL: {entry.get('url', 'N/A')}")
        lines.append(f"Description: {entry.get('description', 'N/A')}")
        lines.append(f"Tags: {', '.join(entry.get('tags', []))}")
        lines.append(f"```javascript\n{entry['code']}\n```")
        lines.append("")

    return "\n".join(lines)


def build_retry_prompt(entry: dict, error_info: dict) -> str:
    """Build a retry prompt for a failed example."""
    v = entry.get("validation", {})
    lines = [
        "The following forum code example FAILED validation. Fix the test metadata.",
        "",
        f"### {entry['title']}",
        f"URL: {entry.get('url', 'N/A')}",
        f"```javascript\n{entry['code']}\n```",
        "",
        "### Previous test metadata:",
        f"```json\n{json.dumps(v, indent=2)}\n```",
        "",
        "### Failure details:",
        f"Stage: {error_info.get('stage', 'unknown')}",
        f"Error: {json.dumps(error_info.get('error', 'unknown'))}",
        "",
        "Analyze the error and produce a corrected validation JSON object. ",
        "Common issues:",
        "- Missing component in setup (add it)",
        "- Wrong component type (e.g., needs Panel not Knob for setPaintRoutine)",
        "- Wrong expected REPL value (recalculate)",
        "- Missing Content.makeFrontInterface",
        "- Module type string incorrect (use MCP tools to look up correct type)",
        "- Code references a variable from test-only code in REPL (move to main code area)",
        "",
        "Output ONLY the corrected JSON object, no markdown fences."
    ]
    return "\n".join(lines)


# ---------------------------------------------------------------------------
# Claude API integration
# ---------------------------------------------------------------------------

SUB_BATCH_SIZE = 10  # Examples per Claude API call


def analyze_with_claude(entries: list, batch_name: str, index_filter=None,
                        model="claude-sonnet-4-20250514", force=False):
    """Call Claude API to generate validation metadata for examples.

    Processes in sub-batches of SUB_BATCH_SIZE. Returns list of entries
    with validation metadata added.
    """
    try:
        import anthropic
    except ImportError:
        print("Error: anthropic package not installed. Run: pip3 install anthropic",
              file=sys.stderr)
        sys.exit(1)

    client = anthropic.Anthropic()

    # Determine which entries to analyze
    if index_filter is not None:
        indices = [index_filter]
    else:
        # Skip entries that already have validation metadata (unless --force)
        indices = []
        for i, entry in enumerate(entries):
            if force or not entry.get("validation"):
                indices.append(i)

    if not indices:
        print("  All examples already analyzed. Use --force to re-analyze.")
        return entries

    print(f"  {len(indices)} examples to analyze (skipping {len(entries) - len(indices)} already done)")

    # Process in sub-batches
    for batch_start in range(0, len(indices), SUB_BATCH_SIZE):
        batch_indices = indices[batch_start:batch_start + SUB_BATCH_SIZE]
        batch_entries = [entries[i] for i in batch_indices]

        sub_num = batch_start // SUB_BATCH_SIZE + 1
        total_subs = (len(indices) + SUB_BATCH_SIZE - 1) // SUB_BATCH_SIZE
        print(f"\n  Sub-batch {sub_num}/{total_subs} — examples {batch_indices[0]}-{batch_indices[-1]}")

        prompt = build_analysis_prompt(batch_entries, batch_name)

        try:
            response = client.messages.create(
                model=model,
                max_tokens=8192,
                system=ANALYSIS_SYSTEM_PROMPT,
                messages=[{"role": "user", "content": prompt}]
            )

            # Extract text response
            text = ""
            for block in response.content:
                if block.type == "text":
                    text += block.text

            # Parse JSON from response (strip any markdown fences)
            text = text.strip()
            if text.startswith("```"):
                text = re.sub(r'^```\w*\n?', '', text)
                text = re.sub(r'\n?```$', '', text)
                text = text.strip()

            validations = json.loads(text)

            if len(validations) != len(batch_indices):
                print(f"    {Colors.yellow('WARNING')}: Expected {len(batch_indices)} results, got {len(validations)}")

            # Apply validations to entries
            for j, idx in enumerate(batch_indices):
                if j < len(validations):
                    entries[idx]["validation"] = validations[j]
                    status = "testable" if validations[j].get("testable") else "skip"
                    tier = validations[j].get("tier", "?")
                    has_repl = bool(validations[j].get("verifyScript"))
                    repl_str = f" +REPL({len(validations[j].get('verifyScript', []))})" if has_repl else ""
                    print(f"    [{idx}] T{tier} {status}{repl_str} — {entries[idx].get('title', '?')[:60]}")
                else:
                    print(f"    [{idx}] {Colors.red('MISSING')} — no result from Claude")

            # Token usage
            usage = response.usage
            print(f"    Tokens: {usage.input_tokens} in / {usage.output_tokens} out")

        except json.JSONDecodeError as e:
            print(f"    {Colors.red('JSON parse error')}: {e}")
            print(f"    Raw response (first 500 chars): {text[:500]}")
        except Exception as e:
            print(f"    {Colors.red('API error')}: {e}")
            traceback.print_exc()

    return entries


def retry_with_claude(entries: list, batch_name: str,
                      model="claude-sonnet-4-20250514"):
    """Re-analyze failed examples with error context."""
    try:
        import anthropic
    except ImportError:
        print("Error: anthropic package not installed", file=sys.stderr)
        sys.exit(1)

    client = anthropic.Anthropic()
    retried = 0

    for i, entry in enumerate(entries):
        v = entry.get("validation", {})
        r = v.get("result", {})

        if not (r.get("tested") and not r.get("passed") and r.get("attempts", 0) < MAX_ATTEMPTS):
            continue

        title = entry.get("title", f"Example {i}")
        print(f"\n  [{i}] Retrying: {title}")
        print(f"       Previous error ({r.get('stage', '?')}): {str(r.get('error', ''))[:100]}")

        prompt = build_retry_prompt(entry, r)

        try:
            response = client.messages.create(
                model=model,
                max_tokens=4096,
                system=ANALYSIS_SYSTEM_PROMPT,
                messages=[{"role": "user", "content": prompt}]
            )

            text = ""
            for block in response.content:
                if block.type == "text":
                    text += block.text

            text = text.strip()
            if text.startswith("```"):
                text = re.sub(r'^```\w*\n?', '', text)
                text = re.sub(r'\n?```$', '', text)
                text = text.strip()

            new_validation = json.loads(text)

            # Preserve the old result's attempt count
            old_attempts = r.get("attempts", 1)
            new_validation["result"] = {"attempts": old_attempts}  # will be updated on next validate

            entries[i]["validation"] = new_validation
            retried += 1
            print(f"       {Colors.cyan('Updated')} — T{new_validation.get('tier', '?')}")

        except Exception as e:
            print(f"       {Colors.red('Retry failed')}: {e}")

    print(f"\n  Retried {retried} examples")
    return entries


# ---------------------------------------------------------------------------
# HISE Validation runner
# ---------------------------------------------------------------------------

def run_validation(entries: list, launcher: HISELauncher, api: HISEAPIClient,
                   index_filter=None, verbose=True):
    """Run HISE validation on entries that have validation metadata.

    Modifies entries in-place, adding/updating validation.result.
    Returns (passed, failed, skipped) counts.
    """
    validator = SnippetValidator(api)
    passed = failed = skipped = 0

    for i, entry in enumerate(entries):
        if index_filter is not None and i != index_filter:
            continue

        v = entry.get("validation")
        if not v:
            skipped += 1
            continue

        title = entry.get("title", f"Example {i}")
        slug = topic_slug(entry.get("url", ""))

        if not v.get("testable", False):
            if verbose:
                print(f"  {Colors.dim(f'[{i}]')} {Colors.yellow('SKIP')} {title} — {v.get('skipReason', 'not testable')}")
            skipped += 1
            continue

        # Build the test dict for SnippetValidator
        setup_code = v.get("setupCode", "") or ""
        code = entry.get("code", "")

        # Split module setup lines (run as separate compilation) from component setup
        module_setup_lines = []
        component_setup_lines = []
        for line in setup_code.split("\n"):
            stripped = line.strip()
            if stripped.startswith("// MODULE_SETUP: "):
                module_setup_lines.append(stripped.replace("// MODULE_SETUP: ", "", 1))
            else:
                component_setup_lines.append(line)

        module_setup = "\n".join(module_setup_lines).strip()
        component_setup = "\n".join(component_setup_lines).strip()

        # Build the full code: component setup + example code
        parts = []
        if component_setup:
            parts.append(component_setup)
        parts.append(code)
        full_code = "\n\n".join(parts)

        test_dict = {
            "code": full_code,
            "testMetadata": {
                "testable": True,
                "setupScript": module_setup if module_setup else None,
                "testOnly": v.get("testOnlyCode"),
                "verifyScript": v.get("verifyScript"),
            }
        }
        # Remove None values from testMetadata
        test_dict["testMetadata"] = {k: val for k, val in test_dict["testMetadata"].items() if val is not None}

        # Run the test
        result = validator.test_example(test_dict)

        # Store result
        attempts = v.get("result", {}).get("attempts", 0) + 1
        result["attempts"] = attempts
        v["result"] = result

        if result.get("passed"):
            passed += 1
            if verbose:
                verify_count = len(result.get("verifications", []))
                verify_str = f" ({verify_count} checks)" if verify_count else ""
                print(f"  {Colors.dim(f'[{i}]')} {Colors.green('PASS')} {title}{verify_str}")
        elif result.get("skipped"):
            skipped += 1
            if verbose:
                print(f"  {Colors.dim(f'[{i}]')} {Colors.yellow('SKIP')} {title} — {result.get('reason', '')}")
        else:
            failed += 1
            if verbose:
                stage = result.get("stage", "?")
                error = result.get("error", "")
                if isinstance(error, list):
                    error = "; ".join(str(e) for e in error[:2])
                print(f"  {Colors.dim(f'[{i}]')} {Colors.red('FAIL')} {title} [{stage}] {error[:120]}")

    return passed, failed, skipped


# ---------------------------------------------------------------------------
# Coverage report
# ---------------------------------------------------------------------------

def print_coverage(entries: list, batch_name: str):
    """Print a coverage summary for a batch."""
    tier_counts = {1: 0, 2: 0, 3: 0, 4: 0}
    tested = passed = failed = skipped = 0
    no_metadata = 0

    for entry in entries:
        v = entry.get("validation")
        if not v:
            no_metadata += 1
            tier = classify_tier(entry.get("code", ""))
            tier_counts[tier] += 1
            continue

        tier_counts[v.get("tier", 1)] += 1
        r = v.get("result")
        if r:
            if r.get("tested"):
                tested += 1
                if r.get("passed"):
                    passed += 1
                else:
                    failed += 1
            elif r.get("skipped"):
                skipped += 1

    total = len(entries)
    print(f"\n{Colors.bold(batch_name)} — {total} examples")
    print(f"  Tiers: T1={tier_counts[1]}  T2={tier_counts[2]}  T3={tier_counts[3]}  T4={tier_counts[4]}")

    if no_metadata == total:
        print(f"  Status: {Colors.yellow('No validation metadata')} (run --analyze first)")
    else:
        analyzed = total - no_metadata
        print(f"  Analyzed: {analyzed}/{total}")
        if tested or skipped:
            print(f"  Results: {Colors.green(f'{passed} passed')}  {Colors.red(f'{failed} failed')}  {Colors.yellow(f'{skipped} skipped')}  {tested} tested")


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def resolve_batches(args) -> list:
    """Return list of (filename, path) tuples based on CLI args."""
    if args.batch:
        path = CODE_EXAMPLES_DIR / args.batch
        if not path.exists():
            print(f"Batch file not found: {path}", file=sys.stderr)
            sys.exit(1)
        return [(args.batch, path)]
    elif args.all:
        return [(f.name, f) for f in collect_batch_files()]
    else:
        print("Specify --batch <filename> or --all", file=sys.stderr)
        sys.exit(1)


def main():
    parser = argparse.ArgumentParser(description="Forum code example validator")

    # Modes
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--analyze", action="store_true",
                      help="Pass 1: AI analysis to generate validation metadata")
    mode.add_argument("--validate", action="store_true",
                      help="Pass 2: Run HISE validation on analyzed examples")
    mode.add_argument("--retry-failures", action="store_true",
                      help="Pass 3: Re-analyze and re-test failures")
    mode.add_argument("--coverage", action="store_true",
                      help="Print coverage report")
    mode.add_argument("--dry-run", action="store_true",
                      help="Show what would be tested without running")
    mode.add_argument("--apply-metadata", nargs=2, metavar=("BATCH", "METADATA"),
                      help="Apply validation metadata JSON to a batch file")

    # Batch selection
    parser.add_argument("--batch", type=str, help="Single batch filename")
    parser.add_argument("--all", action="store_true", help="Process all batches")
    parser.add_argument("--index", type=int, default=None,
                        help="Process single example by index within batch")

    # HISE options
    parser.add_argument("--launch", action="store_true",
                        help="Auto-launch HISE runtime")
    parser.add_argument("--keep-alive", action="store_true",
                        help="Keep HISE running after validation")
    parser.add_argument("--port", type=int, default=1900,
                        help="HISE REST API port (default: 1900)")

    # Claude options
    parser.add_argument("--model", type=str, default="claude-sonnet-4-20250514",
                        help="Claude model for AI analysis (default: claude-sonnet-4-20250514)")
    parser.add_argument("--force", action="store_true",
                        help="Re-analyze even if validation metadata already exists")
    parser.add_argument("--use-api", action="store_true",
                        help="Use Anthropic API directly instead of generating Claude Code instructions")

    args = parser.parse_args()

    # --apply-metadata mode
    if args.apply_metadata:
        batch_filename, metadata_path = args.apply_metadata

        # Load the base batch (validated if exists, else raw)
        entries = load_validated_batch(batch_filename)
        if not entries:
            raw_path = CODE_EXAMPLES_DIR / batch_filename
            if not raw_path.exists():
                print(f"Batch file not found: {raw_path}", file=sys.stderr)
                sys.exit(1)
            entries = load_batch(raw_path)

        # Load metadata
        with open(metadata_path, "r", encoding="utf-8") as f:
            metadata = json.load(f)

        # metadata can be:
        # - A list (one per entry, indexed by position)
        # - A dict keyed by index (string keys)
        if isinstance(metadata, list):
            for i, m in enumerate(metadata):
                if m and i < len(entries):
                    entries[i]["validation"] = m
            applied = len([m for m in metadata if m])
        elif isinstance(metadata, dict):
            for idx_str, m in metadata.items():
                idx = int(idx_str)
                if idx < len(entries) and m:
                    entries[idx]["validation"] = m
            applied = len(metadata)
        else:
            print("Metadata must be a JSON array or object keyed by index", file=sys.stderr)
            sys.exit(1)

        out = save_validated_batch(batch_filename, entries)
        print(f"Applied {applied} validation entries to {batch_filename}")
        print(f"Saved to: {out}")
        return

    # --coverage mode
    if args.coverage:
        batches = resolve_batches(args)
        totals = {"t": 0, "p": 0, "f": 0, "s": 0}
        for filename, path in batches:
            # Try validated version first, fall back to raw
            entries = load_validated_batch(filename)
            if not entries:
                entries = load_batch(path)
            print_coverage(entries, filename)
            for e in entries:
                totals["t"] += 1
                r = e.get("validation", {}).get("result", {})
                if r.get("passed"): totals["p"] += 1
                elif r.get("tested") and not r.get("passed"): totals["f"] += 1
        if len(batches) > 1:
            p_count = totals["p"]
            f_count = totals["f"]
            print(f"\n{Colors.bold('TOTAL')}: {totals['t']} examples, "
                  f"{Colors.green(f'{p_count} passed')}, "
                  f"{Colors.red(f'{f_count} failed')}")
        return

    # --dry-run mode
    if args.dry_run:
        batches = resolve_batches(args)
        for filename, path in batches:
            entries = load_validated_batch(filename)
            if not entries:
                entries = load_batch(path)
            for i, entry in enumerate(entries):
                if args.index is not None and i != args.index:
                    continue
                v = entry.get("validation")
                print(f"\n{'='*60}")
                print(f"[{i}] {entry.get('title', '?')}")
                print(f"URL: {entry.get('url', '?')}")
                print(f"Tier: {classify_tier(entry.get('code', ''))}")
                if v:
                    print(f"\nSetup code:\n{v.get('setupCode', '(none)')}")
                    print(f"\nTest-only code:\n{v.get('testOnlyCode', '(none)')}")
                    print(f"\nVerify script:\n{json.dumps(v.get('verifyScript'), indent=2)}")
                    r = v.get("result")
                    if r:
                        status = "PASS" if r.get("passed") else "FAIL" if r.get("tested") else "SKIP"
                        print(f"\nResult: {status}")
                        if r.get("error"):
                            print(f"Error: {r['error']}")
                else:
                    print("No validation metadata (run --analyze)")
                print(f"\nCode:\n{entry.get('code', '(empty)')}")
        return

    # --analyze mode
    if args.analyze:
        batches = resolve_batches(args)
        for filename, path in batches:
            # Load existing validated data or start fresh from raw batch
            entries = load_validated_batch(filename)
            if not entries:
                entries = load_batch(path)

            # Determine which examples need analysis
            if args.index is not None:
                pending = [args.index]
            elif args.force:
                pending = list(range(len(entries)))
            else:
                pending = [i for i, e in enumerate(entries) if not e.get("validation")]

            print(f"\n{Colors.bold(f'Analyzing {filename}')} — {len(entries)} examples, {len(pending)} pending")

            if not pending:
                print("  All examples already analyzed. Use --force to re-analyze.")
                continue

            if args.use_api:
                # Direct Claude API mode
                entries = analyze_with_claude(entries, filename,
                                             index_filter=args.index,
                                             model=args.model,
                                             force=args.force)
                out = save_validated_batch(filename, entries)
                print(f"\n  Saved to: {out}")
            else:
                # Claude Code mode: generate instruction file
                VALIDATED_DIR.mkdir(parents=True, exist_ok=True)
                instructions_file = VALIDATED_DIR / f"{filename.replace('.json', '')}_instructions.md"

                lines = [
                    f"# Forum Example Analysis: {filename}",
                    "",
                    f"Analyze {len(pending)} examples from `{path}` and generate validation metadata.",
                    "",
                    "## Instructions",
                    "",
                    "For each example listed below, generate a validation JSON object and apply it.",
                    "Use MCP tools (`query_scripting_api`, `list_module_types`, `list_ui_components`, ",
                    "`query_ui_property`) to look up unfamiliar APIs before generating setup code.",
                    "",
                    "After analyzing all examples, write the enriched JSON to:",
                    f"`{VALIDATED_DIR / filename}`",
                    "",
                    "## System Prompt (analysis guidelines)",
                    "",
                    ANALYSIS_SYSTEM_PROMPT,
                    "",
                    f"## Examples to Analyze (indices: {pending[0]}-{pending[-1]})",
                    "",
                ]

                for i in pending:
                    entry = entries[i]
                    lines.append(f"### [{i}] {entry.get('title', 'Untitled')}")
                    lines.append(f"URL: {entry.get('url', 'N/A')}")
                    lines.append(f"Tags: {', '.join(entry.get('tags', []))}")
                    lines.append(f"Mechanical tier: {classify_tier(entry.get('code', ''))}")
                    lines.append(f"Description: {entry.get('description', 'N/A')}")
                    lines.append(f"```javascript\n{entry['code']}\n```")
                    lines.append("")

                with open(instructions_file, "w", encoding="utf-8") as f:
                    f.write("\n".join(lines))

                print(f"  Instructions written to: {instructions_file}")
                print(f"  Run a Claude Code session to analyze, then use:")
                print(f"    python forum_validator.py --apply-metadata {filename} <metadata.json>")
        return

    # --validate mode
    if args.validate:
        batches = resolve_batches(args)
        launcher = None
        api = HISEAPIClient(f"http://127.0.0.1:{args.port}")

        try:
            if args.launch:
                launcher = HISELauncher(port=args.port)
                if not launcher.is_running():
                    print("Launching HISE runtime...")
                    if not launcher.launch():
                        print(Colors.red("Failed to launch HISE"), file=sys.stderr)
                        sys.exit(1)
                else:
                    print("HISE already running")

            total_p = total_f = total_s = 0

            for filename, path in batches:
                entries = load_validated_batch(filename)
                if not entries:
                    print(f"{Colors.yellow(f'No validated data for {filename}')} — run --analyze first")
                    continue

                print(f"\n{Colors.bold(f'Validating {filename}')} — {len(entries)} examples")
                p, f_count, s = run_validation(entries, launcher, api,
                                               index_filter=args.index,
                                               verbose=True)
                total_p += p
                total_f += f_count
                total_s += s

                # Save results back
                save_validated_batch(filename, entries)
                print(f"  Results saved to {VALIDATED_DIR / filename}")

            print(f"\n{Colors.bold('Summary')}: {Colors.green(f'{total_p} passed')}  "
                  f"{Colors.red(f'{total_f} failed')}  {Colors.yellow(f'{total_s} skipped')}")

        finally:
            if launcher and not args.keep_alive:
                launcher.cleanup()

        return

    # --retry-failures mode
    if args.retry_failures:
        batches = resolve_batches(args)
        launcher = None
        api = None

        try:
            # Set up HISE if --launch specified (for re-validation after retry)
            if args.launch:
                api = HISEAPIClient(f"http://127.0.0.1:{args.port}")
                launcher = HISELauncher(port=args.port)
                if not launcher.is_running():
                    print("Launching HISE runtime...")
                    if not launcher.launch():
                        print(Colors.red("Failed to launch HISE"), file=sys.stderr)
                        sys.exit(1)

            for filename, path in batches:
                entries = load_validated_batch(filename)
                if not entries:
                    print(f"No validated data for {filename}")
                    continue

                # Count retryable failures
                retryable = sum(1 for e in entries
                                if e.get("validation", {}).get("result", {}).get("tested")
                                and not e.get("validation", {}).get("result", {}).get("passed")
                                and e.get("validation", {}).get("result", {}).get("attempts", 0) < MAX_ATTEMPTS)

                if retryable == 0:
                    print(f"{filename}: no retryable failures")
                    continue

                print(f"\n{Colors.bold(filename)}: {retryable} failures to retry")

                # Pass 3a: Re-analyze with Claude
                entries = retry_with_claude(entries, filename, model=args.model)

                # Pass 3b: Re-validate with HISE (if --launch)
                if api and launcher:
                    print(f"\n  Re-validating retried examples...")
                    # Only validate entries that were retried (no result yet or cleared result)
                    p, f_count, s = run_validation(entries, launcher, api, verbose=True)
                    print(f"  Re-validation: {Colors.green(f'{p} passed')}  {Colors.red(f'{f_count} failed')}  {Colors.yellow(f'{s} skipped')}")

                out = save_validated_batch(filename, entries)
                print(f"  Saved to: {out}")

        finally:
            if launcher and not args.keep_alive:
                launcher.cleanup()
        return


if __name__ == "__main__":
    main()
