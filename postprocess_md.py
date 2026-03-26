#!/usr/bin/env python3
"""
Post-processes scripting API markdown files to convert plain markdown patterns
into MDC (Markdown Components) format.

Transformations:
1. ### methodName + signature + param table -> ::method-heading + fenced code block
2. **See also:** links -> ::see-also
3. > **Warning:** blockquotes -> ::warning
4. > info blockquotes (in class overview) -> ::tip
5. Common Mistakes section -> ::common-mistakes

Usage:
    python postprocess_md.py content/v2/scripting-api/*.md
    python postprocess_md.py content/v2/scripting-api/engine.md  # single file
"""

import re
import sys
import os
from pathlib import Path


def get_class_name_from_heading(lines):
    """Extract class name from the first # heading."""
    for line in lines:
        if line.startswith("# "):
            return line[2:].strip()
    return ""


def convert_warning_blockquotes(content):
    """Convert > **Warning:** blockquotes to ::warning components."""
    pattern = r'^> \*\*Warning:\*\* (.+?)$'

    def replace_warning(m):
        text = m.group(1)
        return f"::warning\n{text}\n::"

    return re.sub(pattern, replace_warning, content, flags=re.MULTILINE)


def convert_tip_blockquotes(content):
    """Convert general info blockquotes (before ## Methods) to ::tip.
    Only converts blockquotes that are NOT warnings and appear in the overview section."""
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
                and not line.startswith("> **Warning*")):
            # Collect multi-line blockquote
            bq_lines = []
            while i < len(lines) and lines[i].startswith("> "):
                bq_lines.append(lines[i][2:])  # strip "> "
                i += 1
            text = "\n".join(bq_lines)
            result.append(f"::tip\n{text}\n::")
            continue
        result.append(line)
        i += 1
    return "\n".join(result)


def convert_see_also(content):
    """Convert **See also:** lines to ::see-also components."""
    pattern = r'^\*\*See also:\*\* (.+)$'

    def replace_see_also(m):
        line = m.group(1)
        links = re.findall(r'\[([^\]]+)\]\(([^)]+)\)', line)
        if not links:
            return m.group(0)

        yaml_links = []
        for label, url in links:
            # Check for annotation separator in label
            if '` -- ' in label:
                parts = label.split('` -- ', 1)
                clean_label = parts[0].rstrip('`')
                desc = parts[1]
                # Fix URL if it also contains the annotation
                if '` -- ' in url:
                    url = url.split('` -- ')[0].rstrip('`')
                    url = url.split('#')[0] + '#' + clean_label.split('.')[-1].lower() if '#' not in url else url
                # Try to extract clean anchor from URL
                if '#' in url:
                    anchor_part = url.split('#')[1]
                    # Clean up messy anchors
                    anchor_part = anchor_part.split('`')[0].split(' ')[0].lower()
                    base_path = url.split('#')[0]
                    url = f"{base_path}#{anchor_part}"
                yaml_links.append(
                    f'  - {{ label: "{clean_label}", to: "{url}", desc: "{desc}" }}'
                )
            elif '/transporthandler#' in url or self_page_match(url, links):
                # Internal link - extract just method name
                method = label.split('.')[-1] if '.' in label else label
                anchor = '#' + url.split('#')[-1] if '#' in url else url
                yaml_links.append(f'  - {{ label: "{method}", to: "{anchor}" }}')
            else:
                # Check if it's a same-page link
                if '#' in url:
                    page_path = url.split('#')[0]
                    anchor = url.split('#')[1]
                    # We'll detect same-page links by checking if label starts with same class
                    method = label.split('.')[-1] if '.' in label else label
                    yaml_links.append(f'  - {{ label: "{label}", to: "{url}" }}')
                else:
                    yaml_links.append(f'  - {{ label: "{label}", to: "{url}" }}')

        return "::see-also\n---\nlinks:\n" + "\n".join(yaml_links) + "\n---\n::"

    return re.sub(pattern, replace_see_also, content, flags=re.MULTILINE)


def self_page_match(url, all_links):
    """Helper - not actually needed, we detect by URL pattern instead."""
    return False


def convert_see_also_smart(content, class_name):
    """Convert **See also:** lines using class name for same-page detection."""
    slug = class_name.lower()
    pattern = r'^\*\*See also:\*\* (.+)$'

    def replace_see_also(m):
        line = m.group(1)
        links = re.findall(r'\[([^\]]+)\]\(([^)]+)\)', line)
        if not links:
            return m.group(0)

        yaml_links = []
        for label, url in links:
            # Check for annotation in label (cross-class with description)
            if '` -- ' in label:
                parts = label.split('` -- ', 1)
                clean_label = parts[0].rstrip('`')
                desc = parts[1].replace('"', '\\"')
                # Clean up the URL
                if '#' in url:
                    base = url.split('#')[0]
                    anchor = clean_label.split('.')[-1].lower()
                    url = f"{base}#{anchor}"
                yaml_links.append(
                    f'  - {{ label: "{clean_label}", to: "{url}", desc: "{desc}" }}'
                )
            elif f"/{slug}#" in url:
                # Same-page link
                method = label.split('.')[-1] if '.' in label else label
                anchor = '#' + url.split('#')[-1]
                yaml_links.append(f'  - {{ label: "{method}", to: "{anchor}" }}')
            else:
                # Cross-page link - keep full label
                yaml_links.append(f'  - {{ label: "{label}", to: "{url}" }}')

        return "::see-also\n---\nlinks:\n" + "\n".join(yaml_links) + "\n---\n::"

    return re.sub(pattern, replace_see_also, content, flags=re.MULTILINE)


def convert_common_mistakes(content):
    """Convert ## Common Mistakes section to ::common-mistakes component."""
    # Find the Common Mistakes section
    pattern = r'^## Common Mistakes\n\n((?:- \*\*Wrong:\*\*.*?\n(?:  .*?\n)*\n?)+)'

    def replace_cm(m):
        block = m.group(1)
        mistakes = []
        # Parse each mistake entry
        entries = re.findall(
            r'- \*\*Wrong:\*\* (.+?)\n  \*\*Right:\*\* (.+?)\n  \*(.+?)\*',
            block
        )
        if not entries:
            return m.group(0)  # Return unchanged if parsing fails

        yaml_items = []
        for wrong, right, reason in entries:
            # Escape quotes for YAML
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

    return re.sub(pattern, replace_cm, content, flags=re.MULTILINE)


def convert_method_headings(content):
    """Convert ### method + signature + param table to ::method-heading + code block."""
    lines = content.split('\n')
    result = []
    i = 0
    in_methods_section = False

    while i < len(lines):
        if lines[i].strip() == '## Methods':
            in_methods_section = True

        # Look for ### heading pattern
        if (lines[i].startswith('### ')
                and not lines[i].startswith('### #')  # skip anchor-only headings
                and i + 2 < len(lines)):
            method_name = lines[i][4:].strip()

            # Check if next non-empty line is a backtick signature
            j = i + 1
            while j < len(lines) and lines[j].strip() == '':
                j += 1

            has_signature = (j < len(lines)
                             and lines[j].startswith('`')
                             and lines[j].endswith('`')
                             and '```' not in lines[j])

            if has_signature:
                signature = lines[j][1:-1]  # Strip backticks
                k = j + 1
            else:
                signature = None
                k = j  # No signature line to skip

            # Look for parameter table
            while k < len(lines) and lines[k].strip() == '':
                k += 1

            params = []
            table_end = k
            if (k < len(lines)
                    and '| Parameter' in lines[k]
                    and '| Type' in lines[k]
                    and '| Description' in lines[k]):
                # Skip header and separator rows
                k += 1  # separator row |---|---|---|
                if k < len(lines) and lines[k].startswith('|---'):
                    k += 1

                # Parse parameter rows
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

            # Convert if we found a signature, param table, or we're in the Methods section
            if has_signature or params or in_methods_section:
                # Emit ::method-heading
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
                    result.append("")  # Blank line after code block

                # Skip consumed lines
                i = table_end
                continue
            else:
                # Not a method pattern, keep as-is
                result.append(lines[i])
                i += 1
                continue
        else:
            result.append(lines[i])
            i += 1

    return "\n".join(result)


def fix_blank_lines_after_code_blocks(content):
    """Ensure a blank line exists after every code block closing fence.
    Without this, text immediately after ``` gets absorbed into the code block."""
    return re.sub(r'(\n```)\n([^\n`])', r'\1\n\n\2', content)


def postprocess_file(filepath):
    """Apply all transformations to a single markdown file."""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    original = content
    lines = content.split('\n')
    class_name = get_class_name_from_heading(lines)

    # Apply transformations in order
    content = convert_method_headings(content)
    content = convert_common_mistakes(content)
    content = convert_warning_blockquotes(content)
    content = convert_tip_blockquotes(content)
    content = convert_see_also_smart(content, class_name)
    content = fix_blank_lines_after_code_blocks(content)

    if content != original:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        return True
    return False


def main():
    if len(sys.argv) < 2:
        print("Usage: python postprocess_md.py <file.md> [file2.md ...]")
        print("       python postprocess_md.py content/v2/scripting-api/*.md")
        sys.exit(1)

    files = sys.argv[1:]
    changed = 0
    errors = 0

    for filepath in files:
        if not os.path.isfile(filepath):
            print(f"  SKIP {filepath} (not a file)")
            continue
        try:
            if postprocess_file(filepath):
                print(f"  OK   {Path(filepath).name}")
                changed += 1
            else:
                print(f"  SKIP {Path(filepath).name} (no changes)")
        except Exception as e:
            print(f"  ERR  {Path(filepath).name}: {e}")
            errors += 1

    print(f"\nDone: {changed} files changed, {errors} errors, {len(files) - changed - errors} unchanged")


if __name__ == "__main__":
    main()
