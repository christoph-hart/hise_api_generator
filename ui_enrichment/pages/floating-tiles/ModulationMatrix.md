---
title: "ModulationMatrix"
description: "Matrix modulation editor — connects sources to a target processor's parameters with per-cell intensity sliders."
contentType: "ModulationMatrix"
componentType: "floating-tile"
screenshot: "/images/v2/reference/ui-components/floating-tiles/modulationmatrix.png"
llmRef: |
  ModulationMatrix (FloatingTile)
  ContentType string: "ModulationMatrix"
  Set via: FloatingTile.set("ContentType", "ModulationMatrix")

  Editor surface for the HISE 5.0 matrix modulation system. Renders a matrix of modulation sources (rows) against a target processor's parameters (columns) with per-cell intensity controls. Two layouts via MatrixStyle: TableMatrix (full grid) or SliderMatrix (slider per source).

  JSON Properties:
    ProcessorId: ID of the target module (must be a GlobalModulatorContainer or compatible)
    MatrixStyle: Layout style ("TableMatrix" or "SliderMatrix"; default: "TableMatrix")
    SliderStyle: Slider type for intensity controls ("Knob", "Horizontal", "Vertical"; default: "Knob")
    TargetFilter: Optional target ID filter; empty = use ProcessorId as target

  Customisation:
    LAF: getModulatorDragData, drawModulationDragBackground, drawModulationDragger
    CSS: none
seeAlso: []
commonMistakes:
  - title: "No matrix container in the project"
    wrong: "Adding a ModulationMatrix without a GlobalModulatorContainer in the signal chain"
    right: "Insert a Global Modulator Container at the top of the modulator chain — the matrix editor reads its connections from there"
    explanation: "The matrix modulation system stores all source/target connections inside the first GlobalModulatorContainer of the project. Without it, the editor has nothing to display."
  - title: "Confusing MatrixType property name"
    wrong: "Setting `MatrixType` in the JSON `Data` and getting the default layout"
    right: "Use `MatrixStyle` (with values `TableMatrix` or `SliderMatrix`) — that is what the panel actually reads"
    explanation: "The Interface Designer property column shows MatrixType, but the panel runtime reads MatrixStyle from the JSON. When configuring via Data JSON, use MatrixStyle / SliderStyle."
---

![ModulationMatrix](/images/v2/reference/ui-components/floating-tiles/modulationmatrix.PNG)

The ModulationMatrix floating tile is the editor surface for the matrix modulation system introduced in HISE 5.0. It displays a 2D grid where each row is a modulation source and each column is a target parameter, with an intensity slider in every connected cell.

The matrix data lives in the project's first `GlobalModulatorContainer`. Add a Global Modulator Container at the top of your modulator chain to enable matrix modulation, then point the floating tile at the target you want to edit.

## Setup

```javascript
const var ft = Content.getComponent("FloatingTile1");

ft.set("ContentType", "ModulationMatrix");
ft.set("Data", JSON.stringify({
    "ProcessorId": "Master Chain",
    "MatrixStyle": "TableMatrix",
    "SliderStyle": "Knob",
    "TargetFilter": ""
}));
```

## JSON Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `ProcessorId` | String | `""` | The ID of the target module that owns the matrix entries |
| `Index` | int | `-1` | Reserved (not used by this content type) |
| `MatrixStyle` | String | `"TableMatrix"` | Layout style — `"TableMatrix"` (full grid) or `"SliderMatrix"` (one slider per source) |
| `SliderStyle` | String | `"Knob"` | Intensity slider type — `"Knob"`, `"Horizontal"`, or `"Vertical"` |
| `TargetFilter` | String | `""` | Override target ID. When empty, `ProcessorId` is used as the target |

> [!Warning:Use only one GlobalModulatorContainer] The matrix modulation system was designed around a single GlobalModulatorContainer at the project root — a lot of internal code calls `getFirstModulatorContainer()` and ignores any others. Adding a second container to keep "private" modulators out of the source list works in some scenarios but will glitch in others; if you absolutely need to do it, place the private container *second* in the chain.

> [!Tip:Match knob range to matrix modulator InputRange] When you connect a UI knob to a target's matrix modulator via `matrixTargetId`, set the knob's value range to the same range as the modulator's `InputRange`. Otherwise the knob's modulation ring will draw the wrong arc — the matrix sends the modulated value in the modulator's domain and the knob has to map it onto its own range to render correctly.

The `ColourData` object can be used to set colours for the default rendering:

| Colour ID | Description |
|-----------|-------------|
| `bgColour` | Background colour |
| `itemColour1` | Slider track / fill colour |
| `itemColour2` | Slider thumb / accent colour |
| `textColour` | Source / target label colour |

## LAF Customisation

The matrix editor exposes three LAF callbacks. One returns drag-position data (no drawing), one draws the modulation drag popup background, and one draws each modulation source dragger.

### LAF Functions

| Function | Description |
|----------|-------------|
| `getModulatorDragData` | Returns position metadata for the modulation drag UI. Not a drawing callback — must return an object |
| `drawModulationDragBackground` | Draws the background of the modulation drag popup (intensity range + hover info) |
| `drawModulationDragger` | Draws a single modulation source dragger inside the popup |

### `obj` Properties

#### `getModulatorDragData`

Receives the slider and parent bounds plus the current connection list, and must return an object describing where the drag popup should appear. This is *not* a `(g, obj)` drawing callback.

| Property | Type | Description |
|----------|------|-------------|
| `obj.sliderBounds` | Array[x,y,w,h] | Slider bounds in the parent coordinate space |
| `obj.parentBounds` | Array[x,y,w,h] | Parent component bounds |
| `obj.connections` | Array[String] | List of source names already connected to this target slider |

**Returns:** an object describing the popup layout (coordinates, size, etc.).

#### `drawModulationDragBackground`

| Property | Type | Description |
|----------|------|-------------|
| `obj.id` | String | The component's ID |
| `obj.area` | Array[x,y,w,h] | The popup bounds |
| `obj.labelArea` | Array[x,y,w,h] | The label area inside the popup |
| `obj.targetName` | String | Name of the target parameter |
| `obj.min` | double | Minimum intensity value |
| `obj.max` | double | Maximum intensity value |
| `obj.clicked` | bool | Whether the mouse is currently down |
| `obj.hover` | bool | Whether the mouse is hovering over the popup |
| `obj.hoverSourceName` | String | Name of the hovered source (when hovering a connection) |
| `obj.hoverSourceIndex` | int | Index of the hovered source |
| `obj.hoverMode` | int | Modulation mode of the hovered source |
| `obj.hoverValueIntensity` | double | Intensity value of the hovered connection |
| `obj.hoverText` | String | Label text for the hovered connection |
| `obj.bgColour` | int (ARGB) | Outline colour |
| `obj.itemColour` | int (ARGB) | Fill top colour |
| `obj.itemColour2` | int (ARGB) | Fill bottom colour |
| `obj.textColour` | int (ARGB) | Text colour |

#### `drawModulationDragger`

| Property | Type | Description |
|----------|------|-------------|
| `obj.id` | String | The component's ID |
| `obj.area` | Array[x,y,w,h] | The dragger bounds |
| `obj.targetName` | String | Name of the target parameter |
| `obj.sourceName` | String | Name of the modulation source |
| `obj.sourceIndex` | int | Index of the source |
| `obj.mode` | int | Modulation mode |
| `obj.value` | double | Current intensity value |
| `obj.min` | double | Minimum intensity |
| `obj.max` | double | Maximum intensity |
| `obj.clicked` | bool | Whether the mouse is down on the dragger |
| `obj.hover` | bool | Whether the mouse is hovering |
| `obj.bgColour` | int (ARGB) | Outline colour |
| `obj.itemColour` | int (ARGB) | Fill top colour |
| `obj.itemColour2` | int (ARGB) | Fill bottom colour |
| `obj.textColour` | int (ARGB) | Text colour |

### Example

```javascript
const var ft = Content.getComponent("FloatingTile1");
const var laf = Content.createLocalLookAndFeel();

laf.registerFunction("drawModulationDragBackground", function(g, obj)
{
    g.setColour(obj.itemColour);
    g.fillRoundedRectangle(obj.area, 4.0);

    g.setColour(obj.bgColour);
    g.drawRoundedRectangle(obj.area, 4.0, 1.0);

    g.setColour(obj.textColour);
    g.setFont("Arial Bold", 12.0);
    g.drawAlignedText(obj.targetName, obj.labelArea, "centred");

    if (obj.hover && obj.hoverText.length > 0)
    {
        g.setFont("Arial", 10.0);
        g.drawAlignedText(obj.hoverText, obj.area, "centredBottom");
    }
});

laf.registerFunction("drawModulationDragger", function(g, obj)
{
    var bg = obj.clicked ? obj.itemColour2 : obj.itemColour;
    g.setColour(bg);
    g.fillRoundedRectangle(obj.area, 3.0);

    if (obj.hover)
    {
        g.setColour(obj.textColour);
        g.drawRoundedRectangle(obj.area, 3.0, 1.0);
    }

    g.setColour(obj.textColour);
    g.setFont("Arial", 10.0);
    g.drawAlignedText(obj.sourceName, obj.area, "centred");
});
```

## Notes

- The Interface Designer's property editor labels these properties as `MatrixType` and `SliderType`, but the panel runtime reads them from the JSON `Data` object as `MatrixStyle` and `SliderStyle`. When configuring via `Data` use the runtime names.
- `MatrixStyle` accepts `"TableMatrix"` (default — full row/column grid) or `"SliderMatrix"` (a single slider per source). Use `SliderMatrix` when only one parameter target needs editing and you want a compact UI.
- `SliderStyle` selects the visual type of the per-cell intensity slider: `"Knob"`, `"Horizontal"` (linear bar), or `"Vertical"` (linear bar vertical).
- `TargetFilter` overrides the target ID used by the matrix. Leave it empty to use `ProcessorId`. Set it when you want the matrix to operate on a sub-target inside the connected module.
- `getModulatorDragData` is a non-drawing helper — implement it only if you need full control over where the drag popup appears. Returning `undefined` falls back to the default layout.
- Companion content type: [ModulationMatrixController]($UI.ModulationMatrixController$) for displaying / selecting modulation sources.

> [!Tip:Address columns and hide them with id selectors] Each matrix column exposes a CSS `id` selector that affects both the header cell and the cells in every row, so `#sourceindex, #targetid { display: none; }` cleanly removes columns and `#mode { width: 200px; }` resizes them. The available IDs include `#sourceindex`, `#targetid`, `#mode`, `#inverted`, and `#plotter`. Setting plain `width` on `td` resizes every column equally — use the id selectors to give each column its own width.

> [!Warning:Plotter column is intentionally not styleable via CSS] The plotter column ignores most CSS properties on purpose: rendering the realtime path through CSS would require base64-encoding the path on every update (~30fps) which adds significant CPU overhead. To customise the plotter visuals, use a LAF script function instead. The plotter also has `flex-grow: 1` set, so resetting that with `flex-grow: 0` is required before manually setting its width.

**See also:** $UI.ModulationMatrixController$ -- companion source-picker panel, $MODULES.GlobalModulatorContainer$ -- container that stores the matrix connections, $API.ScriptFloatingTile$ -- scripting API for the floating tile wrapper
