---
title: "WavetableWaterfall"
description: "3D wavetable waterfall display — pseudo-isometric view of the connected wavetable synth's tables with active-cycle highlighting."
contentType: "WavetableWaterfall"
componentType: "floating-tile"
screenshot: "/images/v2/reference/ui-components/floating-tiles/wavetablewaterfall.png"
llmRef: |
  WavetableWaterfall (FloatingTile)
  ContentType string: "WavetableWaterfall"
  Set via: FloatingTile.set("ContentType", "WavetableWaterfall")

  Pseudo-3D waterfall view of a Wavetable Synthesiser's tables. Renders many path slices stacked back-to-front with perspective displacement, the active cycle highlighted, optional glow / fill effects, and audio-file drag & drop into the synth. AlphaData JSON object controls colour processing in detail.

  JSON Properties:
    ProcessorId: ID of the connected Wavetable Synthesiser
    Index: 0 (the wavetable index)
    Displacement: [x, y] perspective displacement (y must be negative)
    LineThickness: [active, background] line thicknesses
    DownsamplingFactor: Path simplification factor (1 = 1 segment per pixel, can go below 1 to upsample)
    NumDisplayTables: Number of waterfall slices (interpolated from the loaded wavetable)
    IsometricFactor: 0..1+ skew for an isometric look
    AlphaData: JSON object with colour / glow / fill effect parameters
    GainGamma: Vertical gain shaping
    Margin: Pixel margin between bounding box and paths

  Customisation:
    LAF: none
    CSS: none
seeAlso: []
commonMistakes:
  - title: "Performance tanking with high NumDisplayTables"
    wrong: "Setting NumDisplayTables to 512 with NeighbourGlow > 0 and PrerenderBackground = false"
    right: "Keep PrerenderBackground = true and use NeighbourGlow only when needed; lower NumDisplayTables for live editing"
    explanation: "PrerenderBackground caches the static slices into an image — without it, every repaint draws all slices live. NeighbourGlow forces extra slices to be redrawn dynamically, which compounds the cost."
  - title: "Positive Y displacement looks weird"
    wrong: "Setting Displacement to [0.3, 0.5] expecting the waterfall to scroll downwards"
    right: "Use a negative Y displacement (e.g. [0.3, -0.8]) — positive Y values produce a broken perspective"
    explanation: "The renderer expects the waterfall to recede away from the viewer, which corresponds to a negative Y component. Positive Y inverts the perspective."
---

![WavetableWaterfall](/images/v2/reference/ui-components/floating-tiles/wavetablewaterfall.png)

The WavetableWaterfall floating tile renders a pseudo-3D waterfall view of a [Wavetable Synthesiser]($MODULES.WavetableSynth$)'s loaded wavetable. Many path slices are stacked back-to-front with perspective displacement; the currently playing cycle is rendered in the foreground while the rest form the waterfall behind it.

Connect the floating tile by setting `ProcessorId` to the wavetable synth's ID. `Index` is always `0`. Combine `Displacement`, `IsometricFactor`, `LineThickness`, `NumDisplayTables`, and the `AlphaData` object to replicate almost any wavetable synth's visual style — see [Styling examples](#styling-examples) below.

The display also acts as a drop target: drop an audio file onto it to load the file as a new wavetable on the connected synth (set `enabled = false` on the floating tile to disable this).

## Setup

```javascript
const var ft = Content.getComponent("FloatingTile1");

ft.set("ContentType", "WavetableWaterfall");
ft.set("Data", JSON.stringify({
    "ProcessorId": "Wavetable Synthesiser1",
    "Index": 0,
    "Displacement": [0.3, -0.8],
    "LineThickness": [1.5, 1.5],
    "DownsamplingFactor": 1.0,
    "NumDisplayTables": 64,
    "IsometricFactor": 0.5,
    "GainGamma": 1.0,
    "Margin": 5.0,
    "AlphaData": {
        "NeighbourGlow": 0.0,
        "Decay3D": 0.4,
        "FillGain": 0.3,
        "FillGainCenter": 0.0,
        "PeakGain": 2.0,
        "PrerenderBackground": true,
        "NumHighlights": 0,
        "SmoothRange": [0.95, 1.0]
    }
}));
```

## JSON Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `ProcessorId` | String | `""` | The ID of the connected Wavetable Synthesiser |
| `Index` | int | `0` | Always `0` — the wavetable index on the connected synth |
| `Displacement` | Array[2] | `[0.5, -1.0]` | `[x, y]` perspective displacement of the back row. **Y must be negative** for a correct perspective |
| `LineThickness` | Array[2] | `[2.0, 1.0]` | `[active, background]` line thickness in pixels |
| `DownsamplingFactor` | float | `2.0` | Path simplification factor. `1` = one line segment per UI pixel; values below 1 upsample |
| `NumDisplayTables` | int | `32` | Number of waterfall slices. Independent of the loaded wavetable size — slices are interpolated as needed |
| `IsometricFactor` | float | `0.0` | Perspective skew. Try `0.5`–`1.0` for an isometric look |
| `AlphaData` | Object | `{}` | Colour / glow / fill effect parameters — see below |
| `GainGamma` | float | `1.0` | Vertical gain shaping (gamma curve on path height) |
| `Margin` | float | `5.0` | Pixel margin between the bounding box and the paths |

### `AlphaData` properties

| Property | Type | Description |
|----------|------|-------------|
| `NeighbourGlow` | double | Maximum alpha for paths adjacent to the active cycle. Creates a 3D glow but is expensive — leave at `0` unless needed |
| `SmoothRange` | Array[2] | Smoothstep range for the neighbour glow, e.g. `[0.9, 1.0]` |
| `Decay3D` | double | Darkens the back-of-waterfall paths to fake depth fog. `0.0` = no decay |
| `PeakGain` | double | Brightens the top of background paths versus the bottom (highlights the peaks) |
| `FillGain` | double | Transparency of the active cycle's fill gradient at the outer position |
| `FillGainCenter` | double | Transparency of the active cycle's fill gradient at the centre. `0` = invisible centre |
| `NumHighlights` | int | Number of background paths to render in the special `HighlightColour` for emphasis |
| `HighlightColour` | int (ARGB) | Colour used for the highlighted background paths |
| `ActiveGlowColour` | int (ARGB) | Glow colour around the active cycle |
| `ActiveGlowRadius` | double | Glow radius in pixels |
| `PrerenderBackground` | bool | When `true` (default), the background paths are cached into an image — required for usable performance |

The `ColourData` object can be used to set colours used by the default rendering:

| Colour ID | Description |
|-----------|-------------|
| `bgColour` | Background colour |
| `itemColour1` | Active cycle colour |
| `itemColour2` | 3D bounding-box colour |
| `itemColour3` | Inactive (background) path colour |
| `textColour` | Text and 3D box colour |

## Performance Considerations

The waterfall display is one of the most rendering-heavy floating tiles. It applies a few optimisations to keep repaint cost in check:

1. If `bgColour` is opaque, the component renders without alpha — the parent does not have to repaint.
2. With `PrerenderBackground = true`, the background paths are drawn once into a cached image and reused. The active cycle is still drawn live as a vector path. Whenever the wavetable changes (or the tile is resized) the cache is rebuilt.
3. Three properties have outsized impact on cost: `AlphaData.NeighbourGlow`, `NumDisplayTables`, and `DownsamplingFactor`. Increase any of them carefully.

## Audio file drop

The waterfall display accepts dropped audio files as a way to load new wavetables on the connected synth. To disable this, set the floating tile's `enabled` property to `false`.

> [!Tip:Drop generic audio files as wavetables] Recent Wavetable Synthesiser builds accept regular audio files dropped onto the waterfall — if the file already has a power-of-two cycle length it is chopped, mip-mapped and loaded directly; otherwise a resynthesis pass extracts a wavetable. This means you can ship audio files with the plugin and skip the manual `.hwt` conversion / installer-copy dance entirely.

> [!Warning:Not a real-time spectrum analyser] The waterfall is built for static wavetable display — the background is rendered once into a cached image so it can show 500+ paths at smooth framerates. Repurposing it as a real-time audio spectrum view (by forcing repaints) collapses to ~1-2 FPS because every slice has to be redrawn live. Use an Analyser floating tile or a panel-based renderer for live spectra.

## Styling examples

The waterfall is versatile enough to recreate the visual style of almost any commercial wavetable synth. See the old docs for full JSON snippets that emulate Serum, Ableton, Pigments, Vital, Hive, and Bitwig — those examples are copy-paste starting points but the parameters are deliberately interesting to tweak by hand.

## Notes

- `Displacement` Y must be negative. Positive values produce a broken perspective.

> [!Tip:Mouse-drag the wavetable position] The floating tile has no built-in click-to-scrub on the waterfall, but you can lay an invisible Panel over it and either use a `mouseCallback` or attach a Broadcaster to the panel's mouse events. Convert the drag-Y into a `0..1` range and write it to the Wavetable Synth's table-index parameter — this gives you Pigments / Vital style scrubbing in a few lines of code.
- `Index` is fixed at `0`. The property is exposed only for forward compatibility.
- `NumHighlights` works best with a high `NumDisplayTables` — a few highlighted slices stand out against many faint background ones (Serum-style look).
- `PrerenderBackground = false` is for diagnostic use only — every repaint will redraw every slice live and your CPU will weep.

**See also:** $MODULES.WavetableSynth$ -- the wavetable source synth, $UI.Waveform$ -- simpler single-cycle oscillator display, $API.ScriptFloatingTile$ -- scripting API for the floating tile wrapper
