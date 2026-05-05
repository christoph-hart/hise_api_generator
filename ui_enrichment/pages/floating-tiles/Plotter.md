---
title: "Plotter"
description: "Oscilloscope view of a modulation signal — reuses the AudioAnalyser LAF callbacks for modulators."
contentType: "Plotter"
componentType: "floating-tile"
screenshot: "/images/v2/reference/ui-components/floating-tiles/plotter.png"
llmRef: |
  Plotter (FloatingTile)
  ContentType string: "Plotter"
  Set via: FloatingTile.set("ContentType", "Plotter")

  Visualises the output of a TimeModulation modulator as a scrolling oscilloscope. Reuses the AudioAnalyser LAF functions (drawAnalyserBackground, drawAnalyserPath). Right-click context menu controls timespan and freeze. Modulation values are only sampled while the interface is visible.

  JSON Properties:
    ProcessorId: ID of the connected modulator
    Font: Optional override font for the timespan label
    FontSize: Optional override font size

  Customisation:
    LAF: drawAnalyserBackground, drawAnalyserPath (drawAnalyserGrid is never called)
    CSS: none
seeAlso: []
commonMistakes:
  - title: "Plotter shows no signal in the background"
    wrong: "Hiding the interface and assuming the plotter still records modulation values"
    right: "The plotter only samples modulation while the interface is visible — keep the page on screen to capture data"
    explanation: "To keep CPU low across many modulators, the plotter only reads modulation values when its parent interface is visible. Switching pages or hiding the plugin window pauses the capture."
  - title: "Registering drawAnalyserGrid for the plotter"
    wrong: "Drawing a grid in drawAnalyserGrid expecting it to render on the plotter"
    right: "Skip drawAnalyserGrid for plotter LAFs — it is never called in this content type"
    explanation: "Unlike the spectrum / oscilloscope modes of AudioAnalyser, the plotter does not invoke drawAnalyserGrid. Any grid lines must be drawn inside drawAnalyserBackground or drawAnalyserPath."
  - title: "Hiding the timespan label"
    wrong: "Trying to suppress the timespan text via the LAF callback"
    right: "Set textColour to a transparent ARGB value (e.g. 0x00000000) — the text overlay is not LAF-customisable"
    explanation: "The timespan / freeze indicator is drawn outside the LAF callbacks. The only way to hide it is to render it transparently by giving textColour zero alpha."
---

![Plotter](/images/v2/reference/ui-components/floating-tiles/plotter.png)

The Plotter floating tile renders a scrolling oscilloscope of any modulator's output. It connects to a TimeModulation modulator via `ProcessorId` and visualises the modulation signal in real time.

> [!Tip:Use AudioAnalyser for audio signals] Plotter is for modulation signals. To visualise audio (spectrum, oscilloscope, goniometer), use the [AudioAnalyser]($UI.AudioAnalyser$) floating tile instead — it shares the same LAF callbacks but reads from an Analyser module.

A right-click context menu lets the user change the displayed timespan and freeze the plot for closer inspection.

## Setup

```javascript
const var ft = Content.getComponent("FloatingTile1");

ft.set("ContentType", "Plotter");
ft.set("Data", JSON.stringify({
    "ProcessorId": "LFO Modulator1"
}));
```

## JSON Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `ProcessorId` | String | `""` | The ID of the connected modulator (any TimeModulation type) |
| `Index` | int | `-1` | Reserved (not used by this content type) |
| `Font` | String | `""` | Optional override for the timespan / freeze label font |
| `FontSize` | float | `14.0` | Optional override for the label font size |

The `ColourData` object can be used to set colours for the default rendering:

| Colour ID | Description |
|-----------|-------------|
| `bgColour` | Background colour |
| `itemColour1` | Path fill colour |
| `itemColour2` | Path outline colour |
| `textColour` | Timespan / freeze label colour (set transparent to hide the overlay) |

## LAF Customisation

Plotter reuses the same three LAF callbacks as the AudioAnalyser. Only the background and path callbacks are invoked — `drawAnalyserGrid` is never called for the plotter.

### LAF Functions

| Function | Description |
|----------|-------------|
| `drawAnalyserBackground` | Draws the background of the plotter |
| `drawAnalyserPath` | Draws the modulation signal path |
| `drawAnalyserGrid` | **Not called** for the Plotter — implement on the AudioAnalyser if shared |

### `obj` Properties (shared)

| Property | Type | Description |
|----------|------|-------------|
| `obj.id` | String | The component's ID |
| `obj.area` | Array[x,y,w,h] | The component bounds |
| `obj.bgColour` | int (ARGB) | Background colour |
| `obj.itemColour1` | int (ARGB) | Fill colour |
| `obj.itemColour2` | int (ARGB) | Line colour |

### Additional `obj` properties

#### `drawAnalyserPath`

| Property | Type | Description |
|----------|------|-------------|
| `obj.path` | Path | The modulation signal path |
| `obj.pathArea` | Array[x,y,w,h] | The path bounds |

### Example

```javascript
const var ft = Content.getComponent("FloatingTile1");
const var laf = Content.createLocalLookAndFeel();

laf.registerFunction("drawAnalyserBackground", function(g, obj)
{
    g.setColour(obj.bgColour);
    g.fillRect(obj.area);
});

laf.registerFunction("drawAnalyserPath", function(g, obj)
{
    g.setColour(Colours.withAlpha(obj.itemColour1, 0.4));
    g.fillPath(obj.path, obj.pathArea);

    g.setColour(obj.itemColour2);
    g.drawPath(obj.path, obj.pathArea, 1.5);
});

// drawAnalyserGrid is never called for the Plotter — leave it unregistered
ft.setLocalLookAndFeel(laf);
```

## Notes

> [!Warning:Plotter can stay blank in compiled plugins] If the plotter works inside HISE but shows nothing in the exported plugin (Ableton, Cubase, etc.), add `ENABLE_ALL_PEAK_METERS=1` to the project's `Extra Definitions` (Project Settings -> Compiler). Without it the modulation peak data is stripped from release builds and the plotter has no signal to draw.

> [!Tip:Same modulator can drive multiple plotters] You can connect the same modulator to two or more Plotter floating tiles and they will both render the signal. There is no need for a global modulator wrapper — set `ProcessorId` on each plotter and they will share the same source independently.

- The plotter only samples modulation while its parent interface is visible. This is intentional — many modulators in a project would otherwise share the cost continuously. Hiding the page or plugin window pauses the capture.
- A right-click context menu lets the user change the displayed timespan and freeze the plot. Both are built into the floating tile and do not require scripting.
- The timespan / freeze label that overlays the plot is **not** routed through the LAF callbacks. To hide it, set the `textColour` ColourData entry to a fully transparent ARGB value.
- The same LAF object can drive both a Plotter and an AudioAnalyser — register all three analyser callbacks once, and only the relevant ones will fire per content type.

**See also:** $UI.AudioAnalyser$ -- audio-signal counterpart sharing the same LAF callbacks, $MODULES.LFO$ -- common modulator source for the plotter, $MODULES.AHDSR$ -- envelope source visualised over time, $API.ScriptFloatingTile$ -- scripting API for the floating tile wrapper
