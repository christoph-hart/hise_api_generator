---
title: "FilterDisplay"
description: "Read-only frequency response graph for any module that exposes filter coefficients."
contentType: "FilterDisplay"
componentType: "floating-tile"
screenshot: "/images/v2/reference/ui-components/floating-tiles/filterdisplay.png"
llmRef: |
  FilterDisplay (FloatingTile)
  ContentType string: "FilterDisplay"
  Set via: FloatingTile.set("ContentType", "FilterDisplay")

  Displays the frequency / magnitude response of any module that provides FilterCoefficients (e.g. PolyphonicFilter, CurveEQ). Read-only — for an interactive variant that lets the user drag filter parameters, use DraggableFilterPanel.

  JSON Properties:
    ProcessorId: ID of the connected filter or EQ module
    Index: Display slot for the filter coefficients
    ShowLines: Draw the frequency / magnitude grid lines (default: false)
    GainRange: Vertical dB range of the graph (default: 24.0)
    PathMargin: Margin in pixels around the path inside the graph (default: 3.0)
    PathType: One of "StrokeFullWidth", "StrokeMinimal", "FillFullWidth", "FillMinimal"

  Customisation:
    LAF: drawFilterBackground, drawFilterPath, drawFilterGridLines
    CSS: .filtergraph with --filterPath variable
seeAlso: []
commonMistakes:
  - title: "Connecting to a module that does not expose coefficients"
    wrong: "Setting ProcessorId to a module that has no filter coefficients (e.g. an EQ section without a CurveEQ instance)"
    right: "Connect to a PolyphonicFilter, CurveEQ, or any module derived from FilterEffect"
    explanation: "FilterDisplay reads its data from the connected module's filter coefficients. If the module does not expose them, the graph stays flat. Use DraggableFilterPanel for editable curves."
  - title: "Using FilterDisplay for editable filter curves"
    wrong: "Adding a FilterDisplay and trying to drag the curve to change the filter"
    right: "Use the DraggableFilterPanel content type for an interactive filter graph"
    explanation: "FilterDisplay is purely a visualisation. Mouse interaction is not handled — connect a DraggableFilterPanel instead when users need to edit bands directly."
  - title: "Border stroke distorting the path"
    wrong: "Adding a CSS border to .filtergraph without setting box-sizing"
    right: "Set `box-sizing: border-box` on .filtergraph when the path is rendered as a background image with a border"
    explanation: "Without `border-box`, the border occupies space outside the path's coordinate system, causing the rendered curve to scale inconsistently when margin or padding is applied."
---

![FilterDisplay](/images/v2/reference/ui-components/floating-tiles/filterdisplay.png)

The FilterDisplay floating tile renders the frequency / magnitude response of any HISE module that publishes filter coefficients. Connect it to a `Polyphonic Filter`, `Curve EQ`, or any other module derived from a filter effect, and the graph updates automatically as the filter parameters change.

This is a read-only visualisation. To allow the user to drag the filter parameters directly inside the graph, use the [DraggableFilterPanel]($UI.DraggableFilterPanel$) instead.

## Setup

```javascript
const var ft = Content.getComponent("FloatingTile1");

ft.set("ContentType", "FilterDisplay");
ft.set("Data", JSON.stringify({
    "ProcessorId": "Polyphonic Filter1",
    "Index": 0,
    "ShowLines": true,
    "GainRange": 24.0,
    "PathType": "StrokeFullWidth",
    "PathMargin": 3.0
}));
```

## JSON Properties

Configure via the `Data` property as a JSON string, or set individual properties in the Interface Designer.

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `ProcessorId` | String | `""` | The ID of the connected filter or EQ module |
| `Index` | int | `-1` | Display slot for the filter coefficients (used when the module exposes multiple) |
| `ShowLines` | bool | `false` | Draw the frequency / magnitude grid lines behind the path |
| `GainRange` | float | `24.0` | Vertical range of the graph in dB |
| `PathMargin` | float | `3.0` | Padding in pixels between the graph bounds and the rendered path |
| `PathType` | String | `"StrokeFullWidth"` | Path render style — see [PathType](#pathtype) below |

### PathType

Four render styles are available. They control whether the curve is drawn as a stroke or a fill, and whether it extends edge-to-edge or only across the active filter range.

| Value | Description |
|-------|-------------|
| `StrokeFullWidth` | Stroked outline that spans the full width of the graph |
| `StrokeMinimal` | Stroked outline that ends at the highest / lowest filter frequency |
| `FillFullWidth` | Filled curve spanning the full width of the graph |
| `FillMinimal` | Filled curve that ends at the highest / lowest filter frequency |

The `ColourData` object can be used to set colours for the default rendering:

| Colour ID | Description |
|-----------|-------------|
| `bgColour` | Background colour |
| `itemColour1` | Path stroke / line colour |
| `itemColour2` | Path fill colour |
| `itemColour3` | Grid line colour |
| `textColour` | Frequency / magnitude label colour |

## LAF Customisation

Register a custom look and feel to control how the filter graph is drawn.

### LAF Functions

| Function | Description |
|----------|-------------|
| `drawFilterBackground` | Draws the background of the graph |
| `drawFilterPath` | Draws the frequency response path |
| `drawFilterGridLines` | Draws the grid lines (only called when `ShowLines` is `true`) |

### `obj` Properties (shared across all functions)

| Property | Type | Description |
|----------|------|-------------|
| `obj.id` | String | The component's ID |
| `obj.area` | Array[x,y,w,h] | The graph bounds |
| `obj.bgColour` | int (ARGB) | Background colour |
| `obj.itemColour1` | int (ARGB) | Path line colour |
| `obj.itemColour2` | int (ARGB) | Path fill colour |
| `obj.itemColour3` | int (ARGB) | Grid colour |
| `obj.textColour` | int (ARGB) | Text colour |

### Additional `obj` properties per function

`drawFilterBackground` uses only the shared properties above.

#### `drawFilterPath`

| Property | Type | Description |
|----------|------|-------------|
| `obj.path` | Path | The filter response path |
| `obj.pathArea` | Array[x,y,w,h] | The bounds of the path (after `PathMargin` is applied) |

#### `drawFilterGridLines`

| Property | Type | Description |
|----------|------|-------------|
| `obj.grid` | Path | The grid path (frequency / magnitude lines) |

### Example

```javascript
const var ft = Content.getComponent("FloatingTile1");
const var laf = Content.createLocalLookAndFeel();

laf.registerFunction("drawFilterBackground", function(g, obj)
{
    g.setColour(obj.bgColour);
    g.fillRect(obj.area);
});

laf.registerFunction("drawFilterGridLines", function(g, obj)
{
    g.setColour(obj.itemColour3);
    g.drawPath(obj.grid, obj.area, 1.0);
});

laf.registerFunction("drawFilterPath", function(g, obj)
{
    // Filled body of the response curve
    g.setColour(Colours.withAlpha(obj.itemColour2, 0.4));
    g.fillPath(obj.path, obj.pathArea);

    // Outline on top of the fill
    g.setColour(obj.itemColour1);
    g.drawPath(obj.path, obj.pathArea, 2.0);
});

ft.setLocalLookAndFeel(laf);
```

## CSS Styling

The filter graph supports CSS styling through the `.filtergraph` class selector. The frequency response curve is exposed as a `--filterPath` variable so that it can be used as a `background-image`.

### Selectors

| Selector | Description |
|----------|-------------|
| `.filtergraph` | The filter display element (background + path) |

### CSS Variables

| Variable | Description |
|----------|-------------|
| `--filterPath` | The frequency response path, ready to be used as `background-image` |

### Example Stylesheet

```javascript
const var ft = Content.getComponent("FloatingTile1");
const var laf = Content.createLocalLookAndFeel();

laf.setInlineStyleSheet("
.filtergraph
{
    background: #222;
    background-image: var(--filterPath);
    background-size: 100% 100%;
    background-repeat: no-repeat;
    border: 1px solid #888;
    box-sizing: border-box;
    border-radius: 3px;
}
");

ft.setLocalLookAndFeel(laf);
```

> [!Tip:Use box-sizing when stroking the path] When stroking the filter path with a CSS `border`, set `box-sizing: border-box`. Without it, the path scales inconsistently as soon as `margin` or `padding` is applied because the border lives outside the path's coordinate system.

## Notes

> [!Warning:FilterDisplay timers contribute to UI lag] On large interfaces multiple FilterDisplay tiles can produce noticeable UI lag because each one runs an internal timer to refresh the response curve. If your project becomes sluggish, hide unused FilterDisplays (set `visible` to `false`) rather than just covering them — the timer runs while the tile exists in the layout.

> [!Warning:Frequency / gain modulation is not reflected in the curve] FilterDisplay reads static filter coefficients, so a frequency or gain modulator routed onto the connected filter will move the audio but not the rendered curve. If you need the visualisation to follow modulation, drive the filter parameter from a script instead and the coefficients will update along with it.

- The path is updated automatically when the filter coefficients of the connected module change. No manual repaint is required.
- `ShowLines` toggles the grid (the `drawFilterGridLines` LAF callback is only fired when this is enabled).
- `Index` is only meaningful for modules that expose multiple filter coefficient slots — leave it at the default for typical single-filter modules.
- `PathMargin` applies in the LAF path's `obj.pathArea`. Use it to keep the rendered curve from clipping at the top or bottom of the graph.

**See also:** $UI.DraggableFilterPanel$ -- editable counterpart with drag handles for each band, $MODULES.PolyphonicFilter$ -- common source of filter coefficients, $MODULES.CurveEq$ -- multi-band parametric EQ source, $API.ScriptFloatingTile$ -- scripting API for the floating tile wrapper
