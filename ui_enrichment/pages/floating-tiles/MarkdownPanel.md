---
title: "MarkdownPanel"
description: "Embedded markdown documentation viewer — TOC, search, navigation, and the rendered page view."
contentType: "MarkdownPanel"
componentType: "floating-tile"
screenshot: "/images/v2/reference/ui-components/floating-tiles/markdownpanel.png"
llmRef: |
  MarkdownPanel (FloatingTile)
  ContentType string: "MarkdownPanel"
  Set via: FloatingTile.set("ContentType", "MarkdownPanel")

  Embedded markdown documentation browser. Renders a TOC, search box, navigation buttons, and the page view. Powers the in-HISE help system and can host a project's own documentation.

  JSON Properties:
    ShowToc: Show the table of contents (default: true)
    ShowSearch: Show the search box (default: true)
    ShowBack: Show the navigation buttons (default: true)
    BoldFontName: Font for bold and headlines
    FixTocWidth: Pin the TOC to a fixed pixel width (default: -1 = auto)
    StartURL: Initial page URL
    ServerUpdateURL: Server URL for fetching cached docs
    CustomContent: Inline markdown content (overrides file lookup)

  Customisation:
    LAF: none
    CSS: none
seeAlso: []
commonMistakes:
  - title: "Markdown does not render in compiled plugin"
    wrong: "Shipping a plugin without compiling the docs or pointing ServerUpdateURL at a working host"
    right: "Compile the markdown into content.dat / images.dat (cache mode) and ship those with the plugin, or set ServerUpdateURL to a reachable server"
    explanation: "Compiled plugins use the cache-based mode (content.dat / images.dat). Without those files (or a ServerUpdateURL fetching them) the panel has nothing to render."
---

![MarkdownPanel](/images/v2/reference/ui-components/floating-tiles/markdownpanel.png)

The MarkdownPanel floating tile is an embedded documentation viewer. It renders markdown content with a table of contents, a search box, navigation buttons, and a scrolling page view. The HISE help system itself uses this content type, and any project can include its own documentation the same way.

Two source modes exist: **file-based** (reads markdown files from disk — used while authoring docs inside HISE) and **cache-based** (reads `content.dat` + `images.dat` — used by compiled plugins). Compiled projects almost always run in cache mode.

For a full guide to creating project documentation see [Documentation in HISE](/working-with-hise/project-management/documentation).

## Setup

```javascript
const var ft = Content.getComponent("FloatingTile1");

ft.set("ContentType", "MarkdownPanel");
ft.set("Data", JSON.stringify({
    "Font": "Arial",
    "FontSize": 14,
    "BoldFontName": "Arial Bold",
    "ShowToc": true,
    "ShowSearch": true,
    "ShowBack": true,
    "FixTocWidth": 220,
    "StartURL": "/manual/index",
    "ServerUpdateURL": "https://docs.example.com",
    "ColourData": {
        "bgColour": "0xFF1A1A1A",
        "textColour": "0xFFEEEEEE",
        "itemColour1": "0xFF7FB6FF"
    }
}));
```

## JSON Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `ShowToc` | bool | `true` | Show the table of contents on the left edge |
| `ShowSearch` | bool | `true` | Show the search box in the topbar |
| `ShowBack` | bool | `true` | Show back / forward navigation buttons |
| `BoldFontName` | String | `""` | Font used for bold text and headlines |
| `FixTocWidth` | int | `-1` | Fixed TOC width in pixels (`-1` = auto) — useful for aligning the doc layout to the surrounding interface |
| `StartURL` | String | `""` | Initial page to display when the panel opens |
| `ServerUpdateURL` | String | `""` | URL used by the "fetch from server" update flow |
| `CustomContent` | String | `""` | Inline markdown to render — bypasses file / cache lookup |

> [!Tip:Place server cache files in /cache but omit /cache from the URL] When hosting `content.dat` and `images.dat` for `ServerUpdateURL`, put the files inside a folder literally called `cache/` on the server, then point `ServerUpdateURL` at the **parent** URL (without `/cache`). Leave `StartURL` empty in this configuration — a default slash there causes resolve errors.

> [!Warning:Update Documentation button is broken in compiled binaries] In a compiled plugin the in-panel "Update documentation" button does not refresh the cache, and the new docs only show after a second restart of the plugin. If you ship server-updated docs, expose your own update flow or document the relaunch behaviour for users.
| `Font` | String | `""` | Body / paragraph font |
| `FontSize` | float | `14.0` | Body font size — also scales headlines proportionally |

The `ColourData` object can be used to set colours for the default rendering:

| Colour ID | Description |
|-----------|-------------|
| `bgColour` | Background colour of the page view |
| `textColour` | Body text colour |
| `itemColour1` | Link / accent colour |
| `itemColour2` | TOC selection / hover colour |

## Topbar

The topbar (visible when `ShowBack` is `true`) hosts these icons:

| Icon | Action |
|------|--------|
| TOC | Toggle the table of contents on the left edge |
| Rebuild | Open the documentation update dialog |
| Back / Forward | Navigate the history (browser-style) |
| Night | Toggle the colour scheme |
| Drag / Select | Switch between scroll mode and text-select mode |
| Search | Open the search engine |
| Lock / Pen | Toggle editing mode (HISE only) |

## Source modes

- **File-based** (HISE only): reads the markdown files directly from the project's documentation folder. Used when authoring docs.
- **Cache-based** (compiled plugins): reads `content.dat` (text) and `images.dat` (images) plus `hash.json` (version info). Compile the markdown into these files via the rebuild dialog and ship them with the plugin.

The cache files live in the app data directory's `CachedDocumentation` (HISE) or `Documentation` (compiled project) subfolder. `ServerUpdateURL` controls where the rebuild dialog fetches updates from.

## Notes

- `CustomContent` bypasses both source modes and renders a literal markdown string. Useful for short embedded help texts that do not justify a full doc system.
- The search engine indexes the YAML `keywords` and `weight` fields of each markdown file — it is not a full-text search. Author docs accordingly: every page should have a `keywords:` line in its YAML frontmatter.
- The TOC entry of a page comes from the first `keywords` value, not the filename. Filenames must be URL-safe (lowercase, no spaces); the displayed name comes from YAML.
- Compiled plugins use cache mode by default. Run the "Compile docs" action from the rebuild dialog before shipping.
- This content type has no LAF or CSS support. The colour scheme is the only customisation hook beyond the JSON properties.

> [!Warning:MarkdownPanel is in maintenance-only state] The author has stated the docs system is essentially abandonware — it still works for shipped projects but receives no active development, and historically caused Pluginval blacklisting and DAW crashes (especially VST/VSTi on macOS and Linux). For new projects most developers either link to an online manual via `File.startAsProcess()` or load a hosted site in a `WebView`.

> [!Warning:Each MarkdownPanel spins up a hidden HISE instance] Every MarkdownPanel in your layout instantiates a hidden HISE instance for the dynamic help backend, which can noticeably slow down workspaces with multiple panels. Use a single panel toggled in/out of view rather than embedding several copies across tabs.

**See also:** $UI.AboutPagePanel$ -- simpler about-page alternative, $API.ScriptFloatingTile$ -- scripting API for the floating tile wrapper
