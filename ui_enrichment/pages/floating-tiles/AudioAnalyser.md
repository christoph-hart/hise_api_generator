---
title: "AudioAnalyser"
description: "Connects to an Analyser module and visualises the signal as a goniometer, oscilloscope or spectrum view."
contentType: "AudioAnalyser"
componentType: "floating-tile"
screenshot: "/images/v2/reference/ui-components/floating-tiles/audioanalyser.png"
llmRef: |
  AudioAnalyser (FloatingTile)
  ContentType string: "AudioAnalyser"
  Set via: FloatingTile.set("ContentType", "AudioAnalyser")

  Visualises the audio signal collected by an Analyser module. Three visualisation modes selected via the Index property: 0 = Goniometer, 1 = Oscilloscope, 2 = Spectral Analyser. The Plotter floating tile reuses the same LAF functions.

  JSON Properties:
    ProcessorId: ID of the connected Analyser module
    Index: Visualisation mode (0=Goniometer, 1=Oscilloscope, 2=Spectral Analyser)

  Customisation:
    LAF: drawAnalyserBackground, drawAnalyserPath, drawAnalyserGrid
    CSS: none
seeAlso: []
commonMistakes:
  - title: "No signal in the analyser"
    wrong: "Adding an AudioAnalyser floating tile and connecting it to an audio FX module that is not an Analyser"
    right: "Insert an Analyser module in the signal chain and connect the floating tile to that Analyser"
    explanation: "AudioAnalyser visualises data collected by an Analyser module. Without an Analyser in the chain (or with the wrong ProcessorId), no buffer data is available and the view stays empty."
  - title: "drawAnalyserGrid never fires for the goniometer"
    wrong: "Registering drawAnalyserGrid and expecting it to be called for every visualisation mode"
    right: "Implement grid drawing only for the oscilloscope and spectral analyser; the goniometer does not use a grid"
    explanation: "The goniometer renders dots in a circular field and does not paint a grid path. Only the oscilloscope and FFT modes call drawAnalyserGrid."
---

![AudioAnalyser](/images/v2/reference/ui-components/floating-tiles/audioanalyser.png)

The AudioAnalyser floating tile renders the signal that an [Analyser]($MODULES.Analyser$) module captures into its display buffer. Three visualisation modes are available — choose between them with the `Index` property:

| `Index` | Mode | Description |
|---------|------|-------------|
| `0` | Goniometer | Stereo correlation field — left/right plotted against each other |
| `1` | Oscilloscope | Time-domain waveform |
| `2` | Spectral Analyser | FFT-based frequency spectrum |

Connect the floating tile to the Analyser module by setting `ProcessorId` to the module's ID. The same LAF callbacks are reused by the [Plotter]($UI.Plotter$) floating tile — drawing code written for one applies to the other.

## Setup

```javascript
const var ft = Content.getComponent("FloatingTile1");

ft.set("ContentType", "AudioAnalyser");
ft.set("Data", JSON.stringify({
    "ProcessorId": "Analyser1",
    "Index": 2
}));
```

## JSON Properties

Configure via the `Data` property as a JSON string, or set individual properties in the Interface Designer.

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `ProcessorId` | String | `""` | The ID of the connected Analyser module |
| `Index` | int | `-1` | Visualisation mode (`0` = Goniometer, `1` = Oscilloscope, `2` = Spectral Analyser) |

The `ColourData` object can be used to set colours for the default rendering:

| Colour ID | Description |
|-----------|-------------|
| `bgColour` | Background colour |
| `itemColour1` | Path / waveform colour |
| `itemColour2` | Secondary line colour (e.g. grid in oscilloscope mode) |

> [!Warning:Properties Editor colours can be ignored] In several setups (e.g. when the source is a Parametric EQ or an Analyser inside a Script FX) editing the floating tile's colours from the Properties Editor has no visible effect. If you hit this, register a `drawAnalyserPath` LAF callback and pick the colour explicitly inside it — that bypasses the broken colour-data path.

## LAF Customisation

Register a custom look and feel to control how the analyser is drawn. The same three functions cover all three visualisation modes.

### LAF Functions

| Function | Description |
|----------|-------------|
| `drawAnalyserBackground` | Draws the background of the analyser |
| `drawAnalyserPath` | Draws the visualisation path (FFT spectrum, oscilloscope waveform, or goniometer dots) |
| `drawAnalyserGrid` | Draws the grid lines (only called by the oscilloscope and spectral analyser modes) |

### `obj` Properties (shared across all functions)

| Property | Type | Description |
|----------|------|-------------|
| `obj.id` | String | The component's ID |
| `obj.area` | Array[x,y,w,h] | The component bounds |
| `obj.bgColour` | int (ARGB) | Background colour |
| `obj.itemColour1` | int (ARGB) | Fill / line colour |
| `obj.itemColour2` | int (ARGB) | Secondary line colour |

### Additional `obj` properties per function

`drawAnalyserBackground` uses only the shared properties above.

#### `drawAnalyserPath`

| Property | Type | Description |
|----------|------|-------------|
| `obj.path` | Path | The visualisation path (waveform, spectrum, or dot field) |
| `obj.pathArea` | Array[x,y,w,h] | The bounds of the path |

#### `drawAnalyserGrid`

| Property | Type | Description |
|----------|------|-------------|
| `obj.grid` | Path | The grid path |

### Example

```javascript
const var ft = Content.getComponent("FloatingTile1");
const var laf = Content.createLocalLookAndFeel();

laf.registerFunction("drawAnalyserBackground", function(g, obj)
{
    g.setColour(obj.bgColour);
    g.fillRect(obj.area);
});

laf.registerFunction("drawAnalyserGrid", function(g, obj)
{
    g.setColour(Colours.withAlpha(obj.itemColour2, 0.4));
    g.drawPath(obj.grid, obj.area, 1.0);
});

laf.registerFunction("drawAnalyserPath", function(g, obj)
{
    // Filled body
    g.setColour(Colours.withAlpha(obj.itemColour1, 0.4));
    g.fillPath(obj.path, obj.pathArea);

    // Outline
    g.setColour(obj.itemColour1);
    g.drawPath(obj.path, obj.pathArea, 1.5);
});

ft.setLocalLookAndFeel(laf);
```

## Notes

> [!Tip:Tune the spectrum's range and decay on the Analyser] To make the spectrum more responsive or scale it visually, set properties directly on the connected Analyser module — `BufferSize`, `Decibel range`, `WindowType`, `Decay` — using `setAttribute`. The floating tile picks these up automatically; there is no equivalent "sensitivity" property on the floating tile itself.

> [!Tip:Reach for ScriptNode for advanced visualisations] If the built-in Analyser cannot do what you need (gradient fills, multichannel input, custom buffer length), use a `HardcodedFX` / ScriptNode FX with an Analyser node and an external `DisplayBuffer`. You can then either feed the floating tile from the script FX's processor ID, or render the path manually with `Buffer.createPath()` inside a Panel.

- The Plotter floating tile reuses these same three LAF callbacks for visualising modulation signals — register them once on a shared LAF object and reuse it across both content types.
- `drawAnalyserGrid` is not called for the Goniometer (`Index = 0`) — that mode draws stereo correlation dots and has no grid.
- `Index` selects the visualisation mode. The Analyser module also has its own `Type` parameter (`Nothing`, `Goniometer`, `Oscilloscope`, `Spectral Analyser`) used by inline editors; the floating tile uses its own `Index` property and is independent of it.

**See also:** $MODULES.Analyser$ -- analyser module that captures the audio data, $UI.Plotter$ -- modulation-signal counterpart sharing the same LAF callbacks, $API.ScriptFloatingTile$ -- scripting API for the floating tile wrapper
