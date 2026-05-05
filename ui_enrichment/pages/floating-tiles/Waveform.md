---
title: "Waveform"
description: "Static display of an oscillator's waveform — connects to a Sine Wave Generator or Waveform Generator."
contentType: "Waveform"
componentType: "floating-tile"
screenshot: "/images/v2/reference/ui-components/floating-tiles/waveform.png"
llmRef: |
  Waveform (FloatingTile)
  ContentType string: "Waveform"
  Set via: FloatingTile.set("ContentType", "Waveform")

  Renders the waveform of a Sine Wave Generator or Waveform Generator. The path updates whenever the underlying oscillator selects a different waveform.

  JSON Properties:
    ProcessorId: ID of the connected oscillator module

  Customisation:
    LAF: drawWavetableBackground, drawWavetablePath
    CSS: none
seeAlso: []
commonMistakes:
  - title: "Connecting to a non-oscillator module"
    wrong: "Setting ProcessorId to a sampler, filter or modulator and expecting a waveform"
    right: "Connect to a Sine Wave Generator or Waveform Generator (any module derived from WavetableSynth)"
    explanation: "Waveform reads its path from a wavetable-style oscillator. Other module types do not publish that data, so the display stays empty."
---

![Waveform](/images/v2/reference/ui-components/floating-tiles/waveform.png)

The Waveform floating tile shows the current oscillator waveform of a [Sine Wave Generator]($MODULES.SineSynth$) or [Waveform Generator]($MODULES.WaveSynth$). Set `ProcessorId` to the oscillator module's ID and the path updates automatically as the waveform selection changes.

## Setup

```javascript
const var ft = Content.getComponent("FloatingTile1");

ft.set("ContentType", "Waveform");
ft.set("Data", JSON.stringify({
    "ProcessorId": "Wave Generator1"
}));
```

## JSON Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `ProcessorId` | String | `""` | The ID of the connected oscillator module |
| `Index` | int | `-1` | Display slot (only relevant if the module exposes multiple) |

> [!Warning:Wavetable synth display is voice-driven] When connected to a Wavetable Synthesiser, the Waveform tile only renders while a voice is active — at idle the tile goes blank because the path is published per voice. Sine and Waveform Generators publish their static waveform regardless of voice state, so they always show. If you need a permanent wavetable preview, drive a non-`-1` `Index` value (which selects a fixed slot) or use the [WavetableWaterfall]($UI.WavetableWaterfall$) tile instead.

The `ColourData` object can be used to set colours for the default rendering:

| Colour ID | Description |
|-----------|-------------|
| `bgColour` | Background colour |
| `itemColour1` | Path fill colour |
| `itemColour2` | Path outline colour |
| `textColour` | "Empty" placeholder text colour |

## LAF Customisation

Register a custom look and feel to control how the waveform is rendered.

### LAF Functions

| Function | Description |
|----------|-------------|
| `drawWavetableBackground` | Draws the background; receives an `isEmpty` flag for showing a placeholder when no waveform is loaded |
| `drawWavetablePath` | Draws a single waveform path (called once per waveform / table index) |

### `obj` Properties (shared across both functions)

| Property | Type | Description |
|----------|------|-------------|
| `obj.id` | String | The component's ID |
| `obj.area` | Array[x,y,w,h] | The component bounds |
| `obj.processorId` | String | ID of the connected processor |
| `obj.parentType` | String | ContentType of the parent FloatingTile (if nested) |
| `obj.bgColour` | int (ARGB) | Background colour |
| `obj.itemColour` | int (ARGB) | Fill / top colour |
| `obj.itemColour2` | int (ARGB) | Outline colour |

### Additional `obj` properties per function

#### `drawWavetableBackground`

| Property | Type | Description |
|----------|------|-------------|
| `obj.isEmpty` | bool | `true` when no waveform is loaded — useful for drawing placeholder text |
| `obj.textColour` | int (ARGB) | Text colour for the placeholder |

#### `drawWavetablePath`

| Property | Type | Description |
|----------|------|-------------|
| `obj.path` | Path | The waveform path |
| `obj.tableIndex` | int | Index of this waveform inside the wavetable |
| `obj.isStereo` | bool | Whether the table is stereo |
| `obj.currentTableIndex` | int | The currently playing table index |
| `obj.numTables` | int | Total number of tables in the wavetable |

### Example

```javascript
const var ft = Content.getComponent("FloatingTile1");
const var laf = Content.createLocalLookAndFeel();

laf.registerFunction("drawWavetableBackground", function(g, obj)
{
    g.setColour(obj.bgColour);
    g.fillRect(obj.area);

    if (obj.isEmpty)
    {
        g.setColour(obj.textColour);
        g.setFont("Arial", 12.0);
        g.drawAlignedText("No waveform loaded", obj.area, "centred");
    }
});

laf.registerFunction("drawWavetablePath", function(g, obj)
{
    var isCurrent = obj.tableIndex == obj.currentTableIndex;

    g.setColour(isCurrent ? obj.itemColour : Colours.withAlpha(obj.itemColour, 0.3));
    g.fillPath(obj.path, obj.area);

    g.setColour(obj.itemColour2);
    g.drawPath(obj.path, obj.area, 1.5);
});

ft.setLocalLookAndFeel(laf);
```

## Notes

- For a Sine Wave Generator, `numTables` is 1 — `drawWavetablePath` is called once with `tableIndex = 0`. Wavetable-style oscillators may call it multiple times.
- `obj.isEmpty` in `drawWavetableBackground` is `true` only when the connected processor does not publish a path (e.g. an empty `ProcessorId`). Use it to render a placeholder hint.
- The waveform updates whenever the oscillator's wave selection changes — no manual repaint is required.

> [!Tip:Probe LAF callbacks by registering empty stubs] When you're not sure which LAF function controls a piece of the rendering, register an empty function for each known callback name in turn — whichever one makes the corresponding visual disappear is the one you need to override. This is faster than scanning the source for the right name and works for any floating tile, not just Waveform.

**See also:** $MODULES.SineSynth$ -- common oscillator source, $MODULES.WaveSynth$ -- multi-shape oscillator source, $UI.WavetableWaterfall$ -- richer 3D waterfall display for wavetable synths, $API.ScriptFloatingTile$ -- scripting API for the floating tile wrapper
