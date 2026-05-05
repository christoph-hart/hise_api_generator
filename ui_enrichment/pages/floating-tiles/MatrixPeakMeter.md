---
title: "MatrixPeakMeter"
description: "Multi-channel peak meter that taps into a routable processor's matrix output (or input)."
contentType: "MatrixPeakMeter"
componentType: "floating-tile"
screenshot: "/images/v2/reference/ui-components/floating-tiles/matrixpeakmeter.png"
llmRef: |
  MatrixPeakMeter (FloatingTile)
  ContentType string: "MatrixPeakMeter"
  Set via: FloatingTile.set("ContentType", "MatrixPeakMeter")

  Multi-channel peak meter rendering current and max-hold peak levels for the channels of a routable processor (sound generator, FX). Configurable channel selection, decay times, segment style and orientation.

  JSON Properties:
    ProcessorId: ID of the connected RoutableProcessor (sound generator, FX, etc.)
    SegmentLedSize: Segment height in pixels for stepped LED rendering (0 = smooth)
    UseSourceChannels: Read source channels instead of destination (default: false)
    ChannelIndexes: Array of channel indexes to display (empty = all)
    UpDecayTime: Smoothing time for peak rise in ms (0 = instant)
    DownDecayTime: Smoothing time for peak fall in ms (0 = instant)
    SkewFactor: Skew applied to dB-to-position mapping (default: 1.0)
    PaddingSize: Padding in pixels between channel meters (default: 1.0)
    ShowMaxPeak: Render the max-hold peak indicator (default: true)

  Customisation:
    LAF: drawMatrixPeakMeter
    CSS: none
seeAlso: []
commonMistakes:
  - title: "Showing all channels when only stereo output is wanted"
    wrong: "Leaving ChannelIndexes empty on a 16-channel module and getting 16 meter columns"
    right: "Set ChannelIndexes to [0, 1] (or whichever pair) to limit the display"
    explanation: "An empty ChannelIndexes array shows every channel exposed by the routable processor. For typical stereo monitoring, restrict the array to the relevant indexes."
  - title: "Custom LAF too wide because of leftover channels"
    wrong: "Drawing all numChannels in drawMatrixPeakMeter without checking which channel indexes were requested"
    right: "Use obj.numChannels and obj.peaks/obj.maxPeaks length — the array is already filtered to the configured ChannelIndexes"
    explanation: "obj.peaks and obj.maxPeaks are pre-filtered: their length equals the number of configured channels. Layout the meter based on obj.numChannels rather than the parent module's channel count."
---

![MatrixPeakMeter](/images/v2/reference/ui-components/floating-tiles/matrixpeakmeter.png)

The MatrixPeakMeter floating tile renders peak levels for any routable processor — sound generators, FX modules, and the main mix container all expose a routing matrix, and this meter taps directly into it. Use it for plugin output meters, per-channel send monitoring, or sub-mix metering inside a Container.

Connect via `ProcessorId`. The peaks update at the GUI rate; the optional max-hold indicator fades according to its internal timer.

## Setup

```javascript
const var ft = Content.getComponent("FloatingTile1");

ft.set("ContentType", "MatrixPeakMeter");
ft.set("Data", JSON.stringify({
    "ProcessorId": "Master Chain",
    "ChannelIndexes": [0, 1],
    "SegmentLedSize": 4.0,
    "UpDecayTime": 0.0,
    "DownDecayTime": 200.0,
    "SkewFactor": 1.0,
    "PaddingSize": 2.0,
    "ShowMaxPeak": true,
    "UseSourceChannels": false
}));
```

## JSON Properties

### Connection

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `ProcessorId` | String | `""` | The ID of the connected RoutableProcessor |
| `Index` | int | `-1` | Reserved (not used by this content type) |

### Channels

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `UseSourceChannels` | bool | `false` | Read the source (input) channels instead of the destination (output) channels |
| `ChannelIndexes` | Array | `[]` | Channel indexes to render. Empty = render every channel of the matrix |

> [!Warning:ChannelIndexes must be a JSON array] When editing the `Data` field directly in the Interface Designer, `ChannelIndexes` has to be wrapped in `[ ]` — typing `0, 1` or `"0,1"` silently fails and falls back to all channels. The correct form is `"ChannelIndexes": [0, 1]`. This trips up a lot of beginners following older meter tutorials.

### Rendering

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `SegmentLedSize` | float | `0.0` | Segment height in pixels for stepped LED rendering. `0` = smooth gradient meter |
| `UpDecayTime` | float | `0.0` | Smoothing time for peak rise in ms (`0` = instant) |
| `DownDecayTime` | float | `0.0` | Smoothing time for peak fall in ms (`0` = instant) |
| `SkewFactor` | float | `1.0` | Non-linear skew on the dB-to-position mapping. Values < 1.0 expand the top of the meter |
| `PaddingSize` | float | `1.0` | Padding in pixels between channel meter columns |
| `ShowMaxPeak` | bool | `true` | Render the max-hold peak indicator on top of the live peak |

The `ColourData` object can be used to set colours for the default rendering:

| Colour ID | Description |
|-----------|-------------|
| `bgColour` | Background of the meter track |
| `itemColour1` | Live peak fill colour |
| `itemColour2` | Track / segment outline colour |
| `itemColour3` | Over-peak (clip) colour |
| `textColour` | Max-hold indicator colour |

## LAF Customisation

The MatrixPeakMeter has a single LAF callback covering all channels. The function receives the live peaks, max-hold peaks, and layout metadata in one call so the implementation can lay out every channel in a coordinated pass.

### LAF Functions

| Function | Description |
|----------|-------------|
| `drawMatrixPeakMeter` | Draws the entire multi-channel peak meter |

### `obj` Properties

| Property | Type | Description |
|----------|------|-------------|
| `obj.id` | String | The component's ID |
| `obj.area` | Array[x,y,w,h] | The full component bounds |
| `obj.numChannels` | int | Number of channels actually rendered (matches `obj.peaks.length`) |
| `obj.peaks` | Array[double] | Current peak value per channel (linear amplitude) |
| `obj.maxPeaks` | Array[double] | Max-hold peak value per channel |
| `obj.isVertical` | bool | `true` when the component is taller than wide — meters draw vertically |
| `obj.segmentSize` | double | Segment height in pixels (from `SegmentLedSize`) — `0` = smooth |
| `obj.paddingSize` | double | Padding in pixels between channels (from `PaddingSize`) |
| `obj.processorId` | String | ID of the connected processor |
| `obj.bgColour` | int (ARGB) | Background colour |
| `obj.itemColour` | int (ARGB) | Live peak colour |
| `obj.itemColour2` | int (ARGB) | Track / segment colour |
| `obj.itemColour3` | int (ARGB) | Over-peak (clip) colour |
| `obj.textColour` | int (ARGB) | Max-peak indicator colour |

> [!Warning:obj.peaks[i] is a single number, not an array] Inside `drawMatrixPeakMeter` use `obj.peaks` (the array) for the loop and `obj.peaks[i]` (a number) for each channel's level. Writing `for (x in obj.peaks[0])` iterates over a single double value and produces nothing on screen — a very common mistake when adapting analyser-style snippets to this callback.

> [!Tip:Vertical layout is automatic] You don't need a separate `Vertical` flag — when the floating tile is taller than wide, `obj.isVertical` flips to `true` and the stock renderer draws vertical meters. For custom LAFs, branch on `obj.isVertical` to flip your axis logic instead of duplicating the callback.

### Example

```javascript
const var ft = Content.getComponent("FloatingTile1");
const var laf = Content.createLocalLookAndFeel();

laf.registerFunction("drawMatrixPeakMeter", function(g, obj)
{
    var n = obj.numChannels;

    if (n == 0)
        return;

    // Layout each channel as a vertical meter
    var totalPad = obj.paddingSize * (n - 1);
    var channelW = (obj.area[2] - totalPad) / n;

    for (i = 0; i < n; i++)
    {
        var x = obj.area[0] + i * (channelW + obj.paddingSize);
        var trackArea = [x, obj.area[1], channelW, obj.area[3]];

        // Track
        g.setColour(obj.itemColour2);
        g.fillRect(trackArea);

        // Convert linear peak to height (clamped, no dB conversion here for brevity)
        var peak = Math.min(1.0, obj.peaks[i]);
        var h = obj.area[3] * peak;

        // Pick fill colour — clip when peak >= 1.0
        g.setColour(peak >= 1.0 ? obj.itemColour3 : obj.itemColour);
        g.fillRect([x, obj.area[1] + obj.area[3] - h, channelW, h]);

        // Max-hold tick
        var mp = Math.min(1.0, obj.maxPeaks[i]);
        var mpY = obj.area[1] + obj.area[3] - obj.area[3] * mp;

        g.setColour(obj.textColour);
        g.fillRect([x, mpY - 1, channelW, 2]);
    }
});

ft.setLocalLookAndFeel(laf);
```

## Notes

- `obj.peaks` and `obj.maxPeaks` are already filtered by `ChannelIndexes` — their length matches `obj.numChannels`. Lay out the meter based on those, not on the connected processor's total channel count.
- `UseSourceChannels` flips the meter from the routable processor's *destination* (output) channels to its *source* (input) channels. Use it to monitor what is being sent into a Container before any internal routing.
- `SegmentLedSize` only affects the stock rendering. Inside a custom LAF callback, the value is exposed as `obj.segmentSize` — implement segmenting yourself if the visual style requires it.
- `UpDecayTime` and `DownDecayTime` are filter time constants in milliseconds. `0` means no smoothing; large values produce slow ballistics similar to a VU meter.
- `SkewFactor` is applied to the linear-to-position mapping. Values below 1.0 give more vertical resolution near the top (typical loud-end meter behaviour).

**See also:** $API.RoutingMatrix$ -- the matrix data this meter reads, $API.ScriptFloatingTile$ -- scripting API for the floating tile wrapper
