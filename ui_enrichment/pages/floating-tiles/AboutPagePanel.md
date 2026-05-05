---
title: "AboutPagePanel"
description: "Plugin about page — shows product name, version, build date, copyright, licensee email and a website link."
contentType: "AboutPagePanel"
componentType: "floating-tile"
llmRef: |
  AboutPagePanel (FloatingTile)
  ContentType string: "AboutPagePanel"
  Set via: FloatingTile.set("ContentType", "AboutPagePanel")

  About / credits page that auto-fills product information from project settings (product name, version, build date) and the licensee data, plus configurable copyright string and website URL.

  JSON Properties:
    ShowProductName: Show the product name from project settings (default: true)
    UseCustomImage: Use a custom background image instead of the auto-generated text (default: false)
    CopyrightNotice: Plain string to render as copyright notice
    ShowLicensedEmail: Show the licensee's email address from the licence file (default: true)
    ShowVersion: Show the product version from project settings (default: true)
    BuildDate: Show the build date string (default: true)
    WebsiteURL: Plain URL string to render as a clickable link

  Customisation:
    LAF: none
    CSS: none
seeAlso: []
commonMistakes:
  - title: "Licensee email blank in development"
    wrong: "Expecting ShowLicensedEmail to display an email while testing in HISE — it is empty"
    right: "ShowLicensedEmail only resolves to a real address in a compiled, licensed plugin build. In HISE / unlicensed builds it is blank"
    explanation: "The licensee email is read from the user's licence file. Inside HISE there is no licence, so the field is empty by design."
---

The AboutPagePanel floating tile renders a generated about / credits page using project metadata. Most fields are auto-populated from the project settings (product name, version, build date) and the user's licence file (licensed email). Copyright notice and website URL are static strings provided through the JSON `Data`.

## Setup

```javascript
const var ft = Content.getComponent("FloatingTile1");

ft.set("ContentType", "AboutPagePanel");
ft.set("Data", JSON.stringify({
    "Font": "Arial",
    "FontSize": 14,
    "ShowProductName": true,
    "ShowVersion": true,
    "BuildDate": true,
    "ShowLicensedEmail": true,
    "CopyrightNotice": "© 2026 My Company",
    "WebsiteURL": "https://example.com",
    "UseCustomImage": false,
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
| `ShowProductName` | bool | `true` | Show the product name from project settings |
| `ShowVersion` | bool | `true` | Show the product version |
| `BuildDate` | bool | `true` | Show the build date |
| `ShowLicensedEmail` | bool | `true` | Show the licensee's email address (resolves only in licensed plugin builds) |
| `CopyrightNotice` | String | `""` | Static copyright string |
| `WebsiteURL` | String | `""` | Static URL string rendered as a clickable link |
| `UseCustomImage` | bool | `false` | Use a custom background image instead of auto-generated text |
| `Font` | String | `""` | Optional font override |
| `FontSize` | float | `14.0` | Font size in points |

The `ColourData` object can be used to set colours for the default rendering:

| Colour ID | Description |
|-----------|-------------|
| `bgColour` | Background colour |
| `textColour` | Body text colour |
| `itemColour1` | Link / accent colour |

## Notes

- `ShowLicensedEmail` only produces text in a compiled, licensed plugin build. Inside HISE there is no licence, so the field is empty.
- `BuildDate` reads the timestamp captured at build time. It does not update at runtime.
- `UseCustomImage = true` swaps the auto-generated text layout for a single image (the image path follows the same `{PROJECT_FOLDER}` convention as other floating tiles). Use this when the about screen needs full custom artwork.
- `WebsiteURL` accepts a plain string — wrap your URL in quotes. The link is rendered with the `itemColour1` colour and opens in the system browser when clicked.
- This content type does not respond to mouse interaction beyond the website link. For richer about pages with images, links, and changelog text, use a `MarkdownPanel` with project documentation instead.

**See also:** $UI.MarkdownPanel$ -- richer alternative for changelog / about content, $API.ScriptFloatingTile$ -- scripting API for the floating tile wrapper
