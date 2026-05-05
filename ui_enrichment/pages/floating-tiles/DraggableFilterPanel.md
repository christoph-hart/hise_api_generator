---
title: "DraggableFilterPanel"
description: "Interactive filter graph that lets the user drag bands directly to change frequency, gain and Q."
contentType: "DraggableFilterPanel"
componentType: "floating-tile"
screenshot: "/images/v2/reference/ui-components/floating-tiles/draggablefilterpanel.png"
llmRef: |
  DraggableFilterPanel (FloatingTile)
  ContentType string: "DraggableFilterPanel"
  Set via: FloatingTile.set("ContentType", "DraggableFilterPanel")

  Interactive filter graph: extends FilterDisplay with draggable handles for each band, an optional spectrum analyser overlay, and a context menu. Connects to a Parametric EQ or any module that supplies a draggable filter definition via Effect.setDraggableFilterData().

  JSON Properties:
    ProcessorId: ID of the connected module (CurveEQ or compatible)
    Index: Display index for the filter coefficients
    AllowFilterResizing: Allow adding / removing bands (default: true)
    AllowDynamicSpectrumAnalyser: Spectrum analyser visibility (0=off, 1=always, 2=toggleable; default: 0)
    UseUndoManager: Route changes through the control undo manager (default: false)
    ResetOnDoubleClick: Reset a band to defaults on double click (default: false)
    AllowContextMenu: Enable the right-click context menu (default: true)
    ShowLines: Draw the grid lines (default: true)
    GainRange: Vertical dB range (default: 24.0)
    PathType: One of "StrokeFullWidth", "StrokeMinimal", "FillFullWidth", "FillMinimal"
    PathMargin: Margin in pixels around the path (default: 3.0)

  Customisation:
    LAF: drawFilterDragHandle
    CSS: .filtergraph (path/background) + .filterHandle (per-band drag handles)
seeAlso: []
commonMistakes:
  - title: "No persistence for filter parameters"
    wrong: "Adding a DraggableFilterPanel and assuming the filter state will be saved with the user preset automatically"
    right: "Call Engine.addModuleStateToUserPreset() to store the connected module in the preset, or use a saveInPreset Panel that writes the data manually"
    explanation: "The DraggableFilterPanel does not own the filter data — it only edits the connected module. Parameter persistence is the responsibility of the script (typically by adding the module's state to the user preset)."
  - title: "Connecting to non-EQ modules in HISE 5+ without a JSON definition"
    wrong: "Setting ProcessorId to a module other than the Parametric EQ in HISE 5.0+ and expecting bands to appear"
    right: "Provide a JSON definition via Effect.setDraggableFilterData() on the target module before showing the panel"
    explanation: "From HISE 5.0 onwards, modules other than the Parametric EQ require an explicit draggable filter definition. Without it the panel renders an empty graph."
  - title: "Filter handle text is empty in CSS"
    wrong: "Writing `.filterHandle { content: 'Band'; }` and expecting per-band parameter values"
    right: "Use the supplied CSS variables: var(--type), var(--frequency), var(--q), var(--gain), var(--index)"
    explanation: "The handle exposes its current parameters as CSS variables. Using a static string ignores the live filter values and the band index."
---

![DraggableFilterPanel](/images/v2/reference/ui-components/floating-tiles/draggablefilterpanel.png)

The DraggableFilterPanel extends the [FilterDisplay]($UI.FilterDisplay$) with interactive drag handles for each filter band. Users can drag a band horizontally to change its frequency, vertically to change its gain, and use a modifier or scroll wheel to adjust Q. New bands can be added or removed (when `AllowFilterResizing` is enabled), and an optional spectrum analyser overlay can be shown behind the curve.

Connect the panel to a [Parametric EQ]($MODULES.CurveEq$) for the standard use case. From HISE 5.0 onwards, the panel can also be connected to other module types — but they must publish a draggable filter definition first via [Effect.setDraggableFilterData]($API.Effect.setDraggableFilterData$).

## Setup

```javascript
const var ft = Content.getComponent("FloatingTile1");

ft.set("ContentType", "DraggableFilterPanel");
ft.set("Data", JSON.stringify({
    "ProcessorId": "Parametric EQ1",
    "Index": -1,
    "AllowFilterResizing": true,
    "AllowDynamicSpectrumAnalyser": 0,
    "UseUndoManager": false,
    "ResetOnDoubleClick": true,
    "AllowContextMenu": true,
    "ShowLines": true,
    "GainRange": 24.0,
    "PathType": "StrokeFullWidth",
    "PathMargin": 3.0
}));
```

## JSON Properties

Configure via the `Data` property as a JSON string, or set individual properties in the Interface Designer.

> [!Warning:Default Data only lists a few properties] The Interface Designer's `Data` field only pre-populates `ProcessorId`, `Index` and `FollowWorkspace` — the rest of the properties below (e.g. `AllowDynamicSpectrumAnalyser`, `PathType`, `GainRange`) have to be added to the JSON manually. Without them the panel falls back to the C++ defaults.

### Connection

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `ProcessorId` | String | `""` | The ID of the connected module |
| `Index` | int | `-1` | Display slot for the filter coefficients (used when the module exposes multiple) |

### Interaction

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `AllowFilterResizing` | bool | `true` | Allow the user to add / remove filter bands |
| `AllowDynamicSpectrumAnalyser` | int | `0` | Spectrum analyser overlay: `0` = off, `1` = always on, `2` = toggleable from the context menu |
| `UseUndoManager` | bool | `false` | Route parameter changes through the control undo manager |
| `ResetOnDoubleClick` | bool | `false` | Double-clicking a handle resets the band to its defaults |
| `AllowContextMenu` | bool | `true` | Show a right-click context menu (band type, reset, spectrum toggle) |

### Graph rendering

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `ShowLines` | bool | `true` | Draw the frequency / magnitude grid lines behind the curve |
| `GainRange` | float | `24.0` | Vertical range of the graph in dB |
| `PathMargin` | float | `3.0` | Padding in pixels between the graph bounds and the rendered path |
| `PathType` | String | `"StrokeFullWidth"` | Path render style — see [PathType](#pathtype) below |

### PathType

The four PathType options match those of FilterDisplay. They control whether the curve is drawn as a stroke or a fill, and whether it spans the full width of the graph or only the active band range.

![Path types](/images/custom/filterpathtypes.png)

| Value | Description |
|-------|-------------|
| `StrokeFullWidth` | Stroked outline that spans the full width |
| `StrokeMinimal` | Stroked outline that ends at the lowest / highest band frequency |
| `FillFullWidth` | Filled curve spanning the full width |
| `FillMinimal` | Filled curve that ends at the lowest / highest band frequency |

The `ColourData` object can be used to set colours for the default rendering:

| Colour ID | Description |
|-----------|-------------|
| `bgColour` | Background colour of the graph |
| `itemColour1` | Path line / fill colour |
| `itemColour2` | Spectrum analyser overlay colour |
| `itemColour3` | Grid colour |
| `textColour` | Handle text / label colour |

## LAF Customisation

The DraggableFilterPanel provides a single LAF function for drawing the band drag handles. The graph background, path, and grid rely on the FilterDisplay rendering — to fully customise them, also register the [FilterDisplay LAF functions]($UI.FilterDisplay$) on the same look and feel object.

### LAF Functions

| Function | Description |
|----------|-------------|
| `drawFilterDragHandle` | Draws a single draggable filter handle (called per band) |

### `obj` Properties

| Property | Type | Description |
|----------|------|-------------|
| `obj.id` | String | The component's ID |
| `obj.area` | Array[x,y,w,h] | The full overlay bounds |
| `obj.handle` | Array[x,y,w,h] | The bounds of this individual handle |
| `obj.index` | int | Zero-based index of the filter band |
| `obj.selected` | bool | Whether the band is currently selected |
| `obj.enabled` | bool | Whether the band is enabled |
| `obj.drag` | bool | Whether the band is currently being dragged |
| `obj.hover` | bool | Whether the mouse is over the handle |
| `obj.frequency` | double | The band's current frequency in Hz |
| `obj.Q` | double | The band's current Q (resonance) |
| `obj.gain` | double | The band's current gain in dB |
| `obj.type` | int | The band's filter type identifier |
| `obj.bgColour` | int (ARGB) | Background colour |
| `obj.itemColour1` | int (ARGB) | Line colour |
| `obj.itemColour2` | int (ARGB) | Fill colour |
| `obj.itemColour3` | int (ARGB) | Grid colour |
| `obj.textColour` | int (ARGB) | Text colour |

### Example

```javascript
const var ft = Content.getComponent("FloatingTile1");
const var laf = Content.createLocalLookAndFeel();

laf.registerFunction("drawFilterDragHandle", function(g, obj)
{
    // Pick the colour based on state
    var c = obj.itemColour1;

    if (!obj.enabled)
        c = Colours.withAlpha(c, 0.3);
    else if (obj.drag)
        c = obj.textColour;
    else if (obj.hover || obj.selected)
        c = Colours.withAlpha(obj.textColour, 0.8);

    // Draw the handle disc
    g.setColour(c);
    g.fillEllipse(obj.handle);

    // Outline when selected
    if (obj.selected)
    {
        g.setColour(obj.textColour);
        g.drawEllipse(obj.handle, 1.5);
    }

    // Band index label
    g.setColour(obj.bgColour);
    g.setFont("Arial Bold", obj.handle[3] * 0.6);
    g.drawAlignedText(String(obj.index + 1), obj.handle, "centred");
});

ft.setLocalLookAndFeel(laf);
```

## CSS Styling

DraggableFilterPanel re-uses the `.filtergraph` selector from FilterDisplay for the background and frequency response, and adds a `.filterHandle` selector for each draggable band.

### Selectors

| Selector | Description |
|----------|-------------|
| `.filtergraph` | The graph background and frequency response curve |
| `.filterHandle` | Each draggable filter handle (one per band) |

### Pseudo-states (`.filterHandle`)

| State | Description |
|-------|-------------|
| `:hover` | The mouse is over the handle |
| `:active` | The handle is currently being dragged |
| `:focus` | The band is selected |
| `:disabled` | The band is inactive |

### CSS Variables

The path background uses the same `--filterPath` variable as FilterDisplay. The handle exposes the live band parameters:

| Variable | Description |
|----------|-------------|
| `--filterPath` | Frequency response path, usable as `background-image` on `.filtergraph` |
| `--type` | Filter type string (matches the entries in `TypeList`) |
| `--frequency` | Pre-formatted frequency string (e.g. `"1.5kHz"`) |
| `--q` | Pre-formatted resonance value (one decimal place) |
| `--gain` | Pre-formatted gain value (e.g. `"-14.5 dB"`) |
| `--index` | One-based index of the band |

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
    border: 1px solid #555;
    box-sizing: border-box;
    border-radius: 3px;
}

.filterHandle
{
    content: var(--index);
    background: rgba(255, 255, 255, 0.6);
    color: #111;
    border-radius: 50%;
    font-size: 10px;
    text-align: center;
    vertical-align: middle;
    transition: background 0.1s;
}

.filterHandle:hover
{
    background: rgba(255, 255, 255, 0.85);
}

.filterHandle:focus
{
    background: white;
    box-shadow: 0 0 6px rgba(255, 255, 255, 0.6);
}

.filterHandle:active
{
    background: #ffd24a;
}

.filterHandle:disabled
{
    background: rgba(255, 255, 255, 0.2);
    color: rgba(0, 0, 0, 0.4);
}
");

ft.setLocalLookAndFeel(laf);
```

> [!Tip:Showing live frequency in the handle] Set `content: var(--frequency)` on `.filterHandle` to render the current frequency string (e.g. `"1.5kHz"`) as the handle label. Switch to `var(--gain)` or `var(--q)` based on the modifier key by changing the `content` value in a pseudo-state rule.

## Notes

> [!Warning:Disabled parent Panel can hard-crash on click] Interacting with a DraggableFilterPanel that lives inside a Panel currently set to disabled has been reported to hard-crash HISE and the host (Cubase, Logic). Hide the parent Panel via `visible` instead of `enabled` if you need to gate access to the EQ.

> [!Tip:Persist all EQs in one loop] If your project has more than one Parametric EQ, iterate the IDs and register each one's state with the user preset in `onInit`: `for (id in Synth.getIdList("Parametriq EQ")) Engine.addModuleStateToUserPreset(id);`. This keeps the persistence code stable when modules are added or renamed.

- DraggableFilterPanel does not store any data of its own. Parameter persistence is handled by the connected module — the most reliable approach is `Engine.addModuleStateToUserPreset()`, which saves the entire module state with the user preset.
- `AllowDynamicSpectrumAnalyser` controls whether the spectrum analyser overlay is shown. With `1` it is always visible, with `2` the user can toggle it from the context menu. The colour of the spectrum is taken from `itemColour2` in the connected module's colour data.
- `ResetOnDoubleClick` only affects double-clicks on a handle. Right-clicking still opens the context menu (when enabled) regardless of this setting.
- The `obj.type` value in the LAF callback corresponds to the index in the connected module's `TypeList`. For a Parametric EQ this maps to LowPass, HighPass, LowShelf, HighShelf, Peak, etc.

**See also:** $UI.FilterDisplay$ -- read-only filter graph counterpart, $MODULES.CurveEq$ -- multi-band parametric EQ source, $API.Effect.setDraggableFilterData$ -- defines draggable filter metadata for non-EQ modules, $API.Engine.addModuleStateToUserPreset$ -- preferred persistence path for filter parameters
