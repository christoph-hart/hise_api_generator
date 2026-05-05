---
title: "FlexAHDSRGraph"
description: "Editable AHDSR envelope graph for the Flex AHDSR modulator with per-stage drag points and curve handles."
contentType: "FlexAHDSRGraph"
componentType: "floating-tile"
screenshot: "/images/v2/reference/ui-components/floating-tiles/flexahdsrgraph.png"
llmRef: |
  FlexAHDSRGraph (FloatingTile)
  ContentType string: "FlexAHDSRGraph"
  Set via: FloatingTile.set("ContentType", "FlexAHDSRGraph")

  Editable envelope graph for the Flex AHDSR modulator. Each stage has a drag point that adjusts time and level; curve points between stages adjust shape. A position indicator tracks the active envelope stage during playback. Connects via ProcessorId.

  JSON Properties:
    ProcessorId: ID of the connected Flex AHDSR modulator
    Index: Display buffer index (default: -1)
    CurvePointTolerance: Pixel tolerance for hitting a curve point (default: 20)
    UseOneDimensionDrag: Restrict each drag to a single axis (default: true)

  Customisation:
    LAF: drawFlexAhdsrBackground, drawFlexAhdsrFullPath, drawFlexAhdsrSegment, drawFlexAhdsrCurvePoint, drawFlexAhdsrPosition, drawFlexAhdsrText
    CSS: none
seeAlso: []
commonMistakes:
  - title: "Connecting to a regular AHDSR modulator"
    wrong: "Setting ProcessorId to a classic AHDSR modulator and expecting per-stage curve points"
    right: "Use the AHDSRGraph floating tile for AHDSR modulators; FlexAHDSRGraph only renders Flex AHDSR data"
    explanation: "FlexAHDSRGraph reads its parameters from the Flex AHDSR display buffer (parameter values + position index). A regular AHDSR modulator does not expose this data layout, so the path will not render."
  - title: "Hold has no drag point"
    wrong: "Looking for a hold-stage drag point in the graph or in the LAF callbacks"
    right: "Hold has only Time and Level (Level is shared with Attack); there is no curve point for the Hold segment"
    explanation: "Hold is a static stage — its level is taken from the attack peak, and there is no curve parameter. The graph only renders curve points for the dynamic stages (Attack, Decay, Release)."
---

![FlexAHDSRGraph](/images/v2/reference/ui-components/floating-tiles/flexahdsrgraph.png)

The FlexAHDSRGraph floating tile is the editable visualisation for the Flex AHDSR modulator. It renders the full envelope path, a drag point for each stage (Attack, Hold, Decay, Sustain, Release), and curve points between stages that change the shape of each segment. During playback the current envelope position is shown as a moving indicator.

Connect the floating tile to a Flex AHDSR modulator by setting `ProcessorId`. The graph automatically updates when the modulator's parameters change and follows the envelope position of the last started voice.

## Setup

```javascript
const var ft = Content.getComponent("FloatingTile1");

ft.set("ContentType", "FlexAHDSRGraph");
ft.set("Data", JSON.stringify({
    "ProcessorId": "Flex AHDSR1",
    "Index": -1,
    "CurvePointTolerance": 20,
    "UseOneDimensionDrag": true
}));
```

## JSON Properties

Configure via the `Data` property as a JSON string, or set individual properties in the Interface Designer.

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `ProcessorId` | String | `""` | The ID of the connected Flex AHDSR modulator |
| `Index` | int | `-1` | Display buffer index (only relevant when the modulator exposes multiple buffers) |
| `CurvePointTolerance` | float | `20` | Pixel radius around a curve point in which a click will start a curve drag |
| `UseOneDimensionDrag` | bool | `true` | Restrict each drag to a single axis (horizontal = time, vertical = level) so dragging cannot accidentally change both at once |

> [!Tip:Set UseOneDimensionDrag = false for Serum-style handles] The default one-dimensional drag mode requires the user to release and re-grab to change the other axis — if you want the per-stage drag points to behave like Serum (free 2D drag adjusting time and level simultaneously), set `UseOneDimensionDrag` to `false`. This option was added specifically to let designers opt out of the constrained behaviour.

> [!Warning:Add edge padding so corner drag points are reachable] The drag points sit on the path inside `pathArea`, so when a stage hits the corner of the component (e.g. release at the bottom-right) it can become hard or impossible to grab. Inset your custom background so the path area has 8-10 px of padding on every side, or design your LAF to draw the drag handles slightly outside the path area to keep them clickable.

The `ColourData` object can be used to set colours for the default rendering:

| Colour ID | Description |
|-----------|-------------|
| `bgColour` | Background colour |
| `itemColour1` | Path / segment fill colour |
| `itemColour2` | Path / segment line colour |
| `textColour` | Label and drag-point text colour |

## LAF Customisation

Register a custom look and feel to control how the envelope graph is drawn. The Flex AHDSR exposes six LAF callbacks: one each for the background, the full path, individual segments, curve drag points, the playback position indicator, and parameter text.

### LAF Functions

| Function | Description |
|----------|-------------|
| `drawFlexAhdsrBackground` | Draws the background of the graph |
| `drawFlexAhdsrFullPath` | Draws the complete envelope path (full outline) |
| `drawFlexAhdsrSegment` | Draws a single stage segment — called per stage, can highlight the active stage |
| `drawFlexAhdsrCurvePoint` | Draws a curve drag point between two stages |
| `drawFlexAhdsrPosition` | Draws the indicator at the current playback position |
| `drawFlexAhdsrText` | Draws a parameter label (e.g. attack time, sustain level) |

### `obj` Properties (shared across all functions)

| Property | Type | Description |
|----------|------|-------------|
| `obj.id` | String | The component's ID |
| `obj.area` | Array[x,y,w,h] | The graph bounds |
| `obj.bgColour` | int (ARGB) | Background colour |
| `obj.itemColour` | int (ARGB) | Fill colour |
| `obj.itemColour2` | int (ARGB) | Line colour |
| `obj.textColour` | int (ARGB) | Text colour |

### Additional `obj` properties per function

`drawFlexAhdsrBackground` uses only the shared properties above.

#### `drawFlexAhdsrFullPath`

| Property | Type | Description |
|----------|------|-------------|
| `obj.path` | Path | The full envelope path |
| `obj.pathArea` | Array[x,y,w,h] | The path area (graph bounds reduced by margins) |

#### `drawFlexAhdsrSegment`

| Property | Type | Description |
|----------|------|-------------|
| `obj.path` | Path | The segment path (from one stage to the next) |
| `obj.state` | int | Envelope stage index of this segment |
| `obj.active` | bool | Whether this segment is currently being played by the last started voice |
| `obj.hover` | bool | Whether the mouse is over the segment |

#### `drawFlexAhdsrCurvePoint`

| Property | Type | Description |
|----------|------|-------------|
| `obj.curvePoint` | Array[x,y] | The curve point position |
| `obj.state` | int | Envelope stage index this curve belongs to |
| `obj.hover` | bool | Whether the mouse is over the point |
| `obj.down` | bool | Whether the mouse is currently pressed on the point |

#### `drawFlexAhdsrPosition`

| Property | Type | Description |
|----------|------|-------------|
| `obj.path` | Path | The full envelope path (for sampling the position along the curve) |
| `obj.pointOnPath` | Array[x,y] | The current playback position on the path |
| `obj.state` | int | The currently active envelope stage |

#### `drawFlexAhdsrText`

| Property | Type | Description |
|----------|------|-------------|
| `obj.text` | String | The text to display (parameter name or value) |

### Example

```javascript
const var ft = Content.getComponent("FloatingTile1");
const var laf = Content.createLocalLookAndFeel();

laf.registerFunction("drawFlexAhdsrBackground", function(g, obj)
{
    g.setColour(obj.bgColour);
    g.fillRect(obj.area);
});

laf.registerFunction("drawFlexAhdsrFullPath", function(g, obj)
{
    // Translucent fill of the whole envelope
    g.setColour(Colours.withAlpha(obj.itemColour, 0.2));
    g.fillPath(obj.path, obj.pathArea);

    g.setColour(obj.itemColour2);
    g.drawPath(obj.path, obj.pathArea, 1.5);
});

laf.registerFunction("drawFlexAhdsrSegment", function(g, obj)
{
    if (obj.active)
    {
        g.setColour(Colours.withAlpha(obj.itemColour, 0.6));
        g.fillPath(obj.path, obj.area);
    }
    else if (obj.hover)
    {
        g.setColour(Colours.withAlpha(obj.itemColour, 0.25));
        g.fillPath(obj.path, obj.area);
    }
});

laf.registerFunction("drawFlexAhdsrCurvePoint", function(g, obj)
{
    var size = obj.down ? 10 : (obj.hover ? 8 : 6);
    var rect = [obj.curvePoint[0] - size / 2, obj.curvePoint[1] - size / 2, size, size];

    g.setColour(obj.itemColour2);
    g.fillEllipse(rect);

    if (obj.hover || obj.down)
    {
        g.setColour(obj.textColour);
        g.drawEllipse(rect, 1.0);
    }
});

laf.registerFunction("drawFlexAhdsrPosition", function(g, obj)
{
    g.setColour(obj.textColour);
    g.fillEllipse([obj.pointOnPath[0] - 4, obj.pointOnPath[1] - 4, 8, 8]);
});

laf.registerFunction("drawFlexAhdsrText", function(g, obj)
{
    g.setColour(obj.textColour);
    g.setFont("Arial", 11.0);
    g.drawAlignedText(obj.text, obj.area, "centred");
});

ft.setLocalLookAndFeel(laf);
```

## Notes

- The Flex AHDSR display buffer stores parameter values, not real-time audio — the path is generated from those parameters. The `drawFlexAhdsrPosition` callback receives `pointOnPath` derived from the current stage and progress within it.
- `obj.active` in `drawFlexAhdsrSegment` is `true` only for the segment currently being played by the last started voice. Use it to highlight the active stage during playback.
- Hold stage has no curve parameter (its level is the attack peak), so `drawFlexAhdsrCurvePoint` is not called for the Hold-to-Decay transition. Curve points exist for Attack, Decay, and Release.
- `CurvePointTolerance` is given in pixels and defines the click radius around each curve point. Increase it to make small drag points easier to grab on touch devices or high-DPI screens.
- When `UseOneDimensionDrag` is `true` (the default), each drag is locked to either horizontal (time) or vertical (level) movement based on the initial direction. Set it to `false` to allow free 2D dragging.
- The graph follows the envelope of the *last started* voice — when polyphony is high, the indicator will jump to the most recent note rather than averaging across voices.

> [!Warning:Flex AHDSR has no per-stage modulation slots] Unlike the classic AHDSR modulator, the Flex AHDSR currently does not expose modulation chains for Attack Time, Decay Time, etc., so dropping a Velocity Modulator into the module tree to scale a stage time does not work. Workarounds: route a UI knob with a `matrixTargetId` through the matrix modulation system, or fall back to a Table Envelope modulator if you need per-stage velocity / modulator control.

> [!Tip:Persist the envelope shape in user presets] The Flex AHDSR's stage values and curve points are module state, not regular parameters, so they don't follow the standard preset attribute serialisation. Call `Engine.addModuleStateToUserPreset("MyFlexAHDSR")` once in `onInit` and the entire envelope shape (including curve handles) will be saved and restored with each user preset.

**See also:** $MODULES.FlexAHDSR$ -- envelope source visualised by this tile, $UI.AHDSRGraph$ -- read-only counterpart for the classic AHDSR modulator, $API.ScriptFloatingTile$ -- scripting API for the floating tile wrapper
