---
title: "Empty"
description: "Placeholder floating tile — fills its area with the configured background colour. No content, no module connection."
contentType: "Empty"
componentType: "floating-tile"
llmRef: |
  Empty (FloatingTile)
  ContentType string: "Empty"
  Set via: FloatingTile.set("ContentType", "Empty")

  Placeholder floating tile that draws nothing but its background colour. Useful for reserving space inside a floating layout, prototyping, or as a visible spacer. Replace later with a real ContentType.

  JSON Properties:
    (none beyond base ColourData)

  Customisation:
    LAF: none
    CSS: none
seeAlso: []
commonMistakes:
  - title: "Using Empty for permanent layout spacing"
    wrong: "Leaving an Empty tile in a final layout to push other tiles around"
    right: "Use the Spacer floating tile (ContentType `Spacer`) for invisible layout padding"
    explanation: "Empty draws its bgColour and intercepts mouse clicks. For pure layout spacing that should not catch input or paint, the Spacer ContentType is a better fit."
---

The Empty floating tile is a placeholder. It does not connect to any module, has no LAF callbacks, no CSS support, and renders only its `bgColour`. Use it during layout prototyping or as a temporary placeholder when scaffolding a floating layout — replace it with a real ContentType once the layout is finalised.

## Setup

```javascript
const var ft = Content.getComponent("FloatingTile1");

ft.set("ContentType", "Empty");
ft.set("Data", JSON.stringify({
    "ColourData": {
        "bgColour": "0xFF222222"
    }
}));
```

## JSON Properties

The Empty content type has no special properties of its own. The standard FloatingTile `ColourData`, `Font`, `FontSize`, and `LayoutData` properties still apply (only `bgColour` is rendered).

| Colour ID | Description |
|-----------|-------------|
| `bgColour` | Fill colour of the tile |

## Notes

- Empty intercepts mouse clicks. If you need a non-interactive layout filler, use the `Spacer` content type instead.
- The Type ID in JSON is `"Empty"`. There is also a separate `"Spacer"` ContentType for invisible padding inside floating layouts.

**See also:** $API.ScriptFloatingTile$ -- scripting API for the floating tile wrapper
