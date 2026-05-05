---
title: "ActivityLed"
description: "MIDI activity indicator that lights up briefly whenever a MIDI message is received."
contentType: "ActivityLed"
componentType: "floating-tile"
screenshot: "/images/v2/reference/ui-components/floating-tiles/activityled.png"
llmRef: |
  ActivityLed (FloatingTile)
  ContentType string: "ActivityLed"
  Set via: FloatingTile.set("ContentType", "ActivityLed")

  Visual MIDI activity indicator. Renders an "off" image when idle and an "on" image when MIDI is being received. Optionally shows a "MIDI" text label. Custom on/off images go in the project's Images folder, or use a Base64 path icon for a vector look.

  JSON Properties:
    OffImage: Path to the off-state image (typically "{PROJECT_FOLDER}offLed.png")
    OnImage: Path to the on-state image
    ShowMidiLabel: Show a text label next to the LED (default: true)
    MidiLabel: Text label content (default: "MIDI")
    UseMidiPath: Render the LED using a Base64 vector path instead of images (default: false)
    Base64MidiPath: The Base64 path data when UseMidiPath is true

  Customisation:
    LAF: none
    CSS: none
seeAlso: []
commonMistakes:
  - title: "ActivityLed never lights up"
    wrong: "Adding the panel and expecting it to react to a specific MIDI Player or external MIDI source"
    right: "ActivityLed reflects all incoming MIDI to the plugin (host/standalone MIDI input). It does not filter by source"
    explanation: "The LED listens to the global MIDI input of the plugin. There is no ProcessorId — any incoming MIDI message triggers the indicator."
  - title: "Custom images do not load"
    wrong: "Pointing OffImage / OnImage at an absolute system path or a relative project path"
    right: "Use the {PROJECT_FOLDER} prefix and place the files in the project's Images subfolder (e.g. {PROJECT_FOLDER}offLed.png)"
    explanation: "The LED loads images through the project's image pool. Files must live inside the Images folder and the path must use the {PROJECT_FOLDER} placeholder so it resolves at runtime."
---

![ActivityLed](/images/v2/reference/ui-components/floating-tiles/activityled.png)

The ActivityLed floating tile is a visual MIDI input indicator. When any MIDI message is received by the plugin, the LED switches to its "on" state for a brief moment, providing instant feedback that MIDI input is reaching the engine.

Two rendering modes are available: **image-based** (using PNG files for the off/on state) or **path-based** (using a Base64 path string for vector-style rendering).

## Setup

```javascript
const var ft = Content.getComponent("FloatingTile1");

ft.set("ContentType", "ActivityLed");
ft.set("Data", JSON.stringify({
    "OffImage": "{PROJECT_FOLDER}offLed.png",
    "OnImage": "{PROJECT_FOLDER}onLed.png",
    "ShowMidiLabel": true,
    "MidiLabel": "MIDI"
}));
```

## JSON Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `OffImage` | String | `""` | Image path for the LED's off state (place in `{PROJECT_FOLDER}/Images/`) |
| `OnImage` | String | `""` | Image path for the LED's on state |
| `ShowMidiLabel` | bool | `true` | Show a text label next to the LED |
| `MidiLabel` | String | `"MIDI"` | Text content of the label |
| `UseMidiPath` | bool | `false` | Render the LED from a Base64 vector path instead of images |
| `Base64MidiPath` | String | `""` | The Base64-encoded path used when `UseMidiPath` is `true` |

The `ColourData` object can be used to set colours for the default rendering:

| Colour ID | Description |
|-----------|-------------|
| `bgColour` | Background colour |
| `itemColour1` | Off-state tint (for the path renderer) |
| `itemColour2` | On-state tint (for the path renderer) |
| `textColour` | Label colour |

## Notes

- ActivityLed listens to the plugin's global MIDI input. Any incoming MIDI message — note, CC, pitch bend, etc. — triggers the on state. There is no per-module filtering.
- For image mode, the off and on images should have the same dimensions. They are drawn at the LED's logical size; oversized source images are scaled down by the rendering pipeline.
- For path mode (`UseMidiPath = true`), `Base64MidiPath` accepts a single path that is recoloured between `itemColour1` (idle) and `itemColour2` (active). Generate path data with `Content.createPath().toBase64()`.

> [!Tip:For sophisticated LEDs build a custom panel] ActivityLed has no LAF hooks, so glow, lens flares and animated states are not possible inside this tile. For polished UIs most developers replace it with a Panel that paints two frames (or a filmstrip) and is driven by a global cable or an `onNoteOn` MIDI callback — the same approach as a Panel-based VU meter.

> [!Warning:Base64 path must come from the SVG-to-Base64 converter] Hand-rolled byte arrays in `Base64MidiPath` will load garbage and either render nothing or crash — the renderer expects the exact format produced by HISE's SVG converter (or `Content.createPath().toBase64()`). Use one of those generators rather than pasting an arbitrary path string.

**See also:** $API.ScriptFloatingTile$ -- scripting API for the floating tile wrapper, $UI.Components.ScriptPanel$ -- recommended substitute for fully custom LED rendering
