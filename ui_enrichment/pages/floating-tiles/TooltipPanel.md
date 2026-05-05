---
title: "TooltipPanel"
description: "Hover-tooltip display surface — renders the text set on hovered components via .set('tooltip', ...)."
contentType: "TooltipPanel"
componentType: "floating-tile"
screenshot: "/images/v2/reference/ui-components/floating-tiles/tooltippanel.png"
llmRef: |
  TooltipPanel (FloatingTile)
  ContentType string: "TooltipPanel"
  Set via: FloatingTile.set("ContentType", "TooltipPanel")

  Surface that displays the tooltip text of whichever component the mouse is currently over. Tooltips are configured per-component via the "tooltip" property. Optional fade animation and info icon.

  JSON Properties:
    Fade: Animate text in/out (default: true)
    ShowIcon: Show an info icon to the left of the text (default: true)
    Font: Override font for the tooltip text
    FontSize: Override font size

  Customisation:
    LAF: none
    CSS: none
seeAlso: []
commonMistakes:
  - title: "TooltipPanel always empty"
    wrong: "Adding a TooltipPanel and forgetting to set the `tooltip` property on the components that should display text"
    right: "Set the `tooltip` property on each ScriptComponent (knob, button, etc.) — that string is what TooltipPanel renders"
    explanation: "TooltipPanel is purely a display surface. The actual tooltip text is configured per component via its `tooltip` property in the Interface Designer or via setProperty in script."
---

![TooltipPanel](/images/v2/reference/ui-components/floating-tiles/tooltippanel.png)

The TooltipPanel floating tile renders the tooltip text of the component that the mouse is currently hovering over. Set the `tooltip` property on each ScriptComponent (knob, button, label, etc.) — when the user hovers it, the configured string appears in the panel.

Useful for plugins that want a fixed help bar at the bottom of the interface rather than a floating tooltip popup.

## Setup

```javascript
const var ft = Content.getComponent("FloatingTile1");

ft.set("ContentType", "TooltipPanel");
ft.set("Data", JSON.stringify({
    "Font": "Arial Italic",
    "FontSize": 14,
    "Fade": true,
    "ShowIcon": true,
    "ColourData": {
        "bgColour": "0x22FFFFFF",
        "textColour": "0xFFFFFFFF",
        "itemColour1": "0xFF7FB6FF"
    }
}));
```

## JSON Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `Fade` | bool | `true` | Animate the tooltip text in / out as the hovered component changes |
| `ShowIcon` | bool | `true` | Show an info icon to the left of the text |
| `Font` | String | `""` | Optional font override |
| `FontSize` | float | `14.0` | Font size in points |

The `ColourData` object can be used to set colours for the default rendering:

| Colour ID | Description |
|-----------|-------------|
| `bgColour` | Background colour shown when a tooltip is being displayed |
| `textColour` | Tooltip text colour |
| `itemColour1` | Info icon colour |

## Notes

- The panel is invisible while no component is hovered (`bgColour` is only painted when there is text to display).
- TooltipPanel reads the `tooltip` property on whichever component the mouse hovers — this includes nested ScriptComponents inside a ScriptPanel.
- `Fade = false` produces an instant cut between tooltip strings instead of a cross-fade. Use it on a fast-moving interface where the cross-fade feels sluggish.
- The info icon (`ShowIcon`) is the stock HISE info glyph. There is no LAF callback — switch off `ShowIcon` and draw a custom one in an overlapping ScriptPanel if a different icon is needed.

**See also:** $API.ScriptFloatingTile$ -- scripting API for the floating tile wrapper
