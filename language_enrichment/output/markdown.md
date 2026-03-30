---
title: Markdown in HISE
description: "HISE's markdown dialect for in-app text rendering and forum posts"

guidance:
  summary: >
    Reference for the markdown syntax accepted by HISE's built-in renderer.
    Two consumers: the MarkdownRenderer scripting API class (for displaying
    formatted text inside plugin UIs) and the HISE forum. The documentation
    pipeline that previously used markdown within HISE is deprecated — this
    page covers only the rendering syntax, not a documentation authoring
    workflow.
  concepts:
    - markdown
    - MarkdownRenderer
    - forum formatting
    - YAML header
  prerequisites: []
  complexity: beginner
---

HISE includes a lightweight markdown renderer used in two contexts: the $API.MarkdownRenderer$ scripting API class for displaying formatted text inside your plugin UI, and the [HISE forum](https://forum.hise.audio) which uses the same dialect for post formatting.

> [!Warning:Documentation pipeline deprecated] The markdown-based documentation system within HISE is deprecated. This reference covers the syntax accepted by the MarkdownRenderer and the forum — not a documentation authoring workflow.


## Syntax

HISE's markdown follows standard [Markdown](https://www.markdownguide.org) conventions with a few customizations.

### Text Formatting

| Syntax | Result |
| --- | --- |
| `**bold**` | **bold** |
| `` `code` `` | Monospaced inline code |
| Two trailing spaces | Line break |

### Headings

```
# Heading 1
## Heading 2
### Heading 3
```

Headings up to level 2 appear in the table of contents and are linkable via anchor syntax (`#heading-urlified`).

### Paragraphs & Lists

```
> This is a blockquote

- Bullet point
- Another point

1. Numbered item
2. Another item
```

### Links

```
[Display text](link-target)
```

For links within HISE documentation, the target follows the HISE file system path conventions.

### Images

```
![Alt text](image-url)
```

Local images should use the image creation tool, which copies the file to the correct subfolder and generates a relative link.

### Tables

Standard markdown table syntax with an optional HISE extension for fixed column widths:

```
| Column A | Column B |
| ---:120px | --- |
| cell 1 | cell 2 |
| cell 3 | cell 4 |
```

The `:120px` suffix after `---` sets a fixed pixel width for that column. This is useful for icon or shortcut columns.

> [!Tip:Use the Table generator] The HISE markdown table parser is stricter than most parsers. Use the built-in Table generator in the editor to avoid formatting issues.

### Code Blocks

Fenced code blocks with language hints are supported:

````
```javascript
Console.print("Hello");
```
````

### YAML Front Matter

Markdown files in HISE expect a YAML header:

```
---
keywords: Page Title
summary: A short description
author: Your Name
modified: 29.03.2026
---
```

| Property | Description |
| --- | --- |
| `keywords` | Page title (shown in search and TOC) |
| `summary` | Short description for search popup |
| `author` | Author name |
| `modified` | Last modification date (DD.MM.YYYY) |
| `index` | Override natural TOC sort order (0-based) |
| `weight` | Search importance (0-100, default 50) |
| `colour` | TOC colour (`#AARRGGBB`) |


## Differences from Standard Markdown

| Feature | Standard Markdown | HISE Markdown | Notes |
| --- | --- | --- | --- |
| Italic (`*text*`) | Supported | Not supported | |
| Strikethrough (`~~text~~`) | Supported | Not supported | |
| Custom HTML | Supported | Not supported | No inline HTML allowed |
| Table column widths | Not available | `---:120px` syntax | HISE extension |
| Table parser strictness | Lenient | Strict | Use the Table generator |
| YAML front matter | Optional | Expected | Required for TOC and search |
| Blockquotes (`>`) | Generic quotes | Rendered as styled comments | Visual styling differs |
| Heading anchors | Varies | Auto-generated for h1 and h2 | Linkable via `#heading-id` |
| Nested blockquotes | Supported | Not supported | Single level only |
| Reference-style links | Supported | Not supported | Use inline links only |


## What's Next

**See also:** $API.MarkdownRenderer$ -- scripting API for rendering markdown in plugin UIs
