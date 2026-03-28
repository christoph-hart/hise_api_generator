---
title: "Viewport"
componentId: "ScriptedViewport"
componentType: "plugin-component"
screenshot: "/images/v2/reference/ui-components/viewport.png"
llmRef: |
  ScriptedViewport (UI component)
  Create via: Content.addViewport("name", x, y)
  Scripting API: $API.ScriptedViewport$

  Multi-mode viewport supporting scrollable viewport, selectable list, and interactive table modes. Mode is determined at init time: default is a plain scrollable viewport, useList enables list mode, setTableMode() enables table mode.

  Properties (component-specific):
    useList: enable list mode with selectable items
    items: newline-separated list items (for list mode)
    scrollBarThickness: scrollbar width in pixels
    autoHide: auto-hide scrollbar when not scrolling
    viewPositionX: horizontal scroll position
    viewPositionY: vertical scroll position
    fontName: font family for list item text
    fontSize: font size for list items
    fontStyle: font style for list items
    alignment: text alignment for list items

  Customisation:
    LAF (list mode): none
    LAF (table mode): drawTableRowBackground, drawTableCell, drawTableHeaderBackground, drawTableHeaderColumn
    LAF (all modes): drawScrollbar
    CSS: .scriptviewport with tr (list items), scrollbar; tr supports :hover, :active, :checked
    Filmstrip: no
seeAlso: []
commonMistakes:
  - title: "Using pixel values for viewPositionY"
    wrong: "vp.set(\"viewPositionY\", 150) — assuming pixel offset"
    right: "vp.set(\"viewPositionY\", 0.5) — use normalized 0.0-1.0 range"
    explanation: "viewPositionY is a normalized value (0.0 to 1.0), not a pixel offset. Use (targetRow + 1) / totalRows to scroll to a specific row."
  - title: "Calling setTableMode() outside onInit"
    wrong: "Calling setTableMode() or setTableColumns() in a callback"
    right: "Call setTableMode() and setTableColumns() during onInit only"
    explanation: "Table setup methods report a script error when called after initialisation. All table configuration must happen during onInit."
  - title: "Using component type names as table column Type"
    wrong: "\"Type\": \"ScriptComboBox\" in setTableColumns()"
    right: "\"Type\": \"ComboBox\" — use the short cell type name, not the component class name"
    explanation: "Table column types are short names (Text, Button, Slider, ComboBox, Image, Hidden), not ScriptComponent class names. Using the class name silently falls back to Text."
  - title: "Calling setTableColumns() before setTableMode()"
    wrong: "Calling setTableColumns() without calling setTableMode() first"
    right: "Always call setTableMode() before setTableColumns()"
    explanation: "setTableColumns() requires the internal table model to exist. Calling it before setTableMode() throws a script error because the model has not been created yet."
  - title: "Using obj.rowIndex for data access with sorting enabled"
    wrong: "data[obj.rowIndex] — display indices differ from data indices when sorted"
    right: "data[getOriginalRowIndex(obj.rowIndex)] to get the original data index"
    explanation: "When table sorting is enabled, display row indices no longer match the original data array indices. Use getOriginalRowIndex() to translate."
---

![Viewport](/images/v2/reference/ui-components/viewport.png)

ScriptedViewport is a multi-mode viewport component that supports three distinct use cases: a **plain scrollable viewport** for hosting child components, a **selectable list** for item selection, and an **interactive table** with sortable columns and editable cells.

The mode is determined at initialisation time. By default, the component is a plain scrollable viewport. Set `useList = true` for list mode with newline-separated items, or call `setTableMode()` during `onInit` for table mode with columns, row data, and interactive cell types (Text, Button, Slider, ComboBox). In list mode, the value corresponds to the selected item index. Font and alignment properties control list item rendering.

## Properties

Set properties with `ScriptedViewport.set(property, value)`.

### Component-specific properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| *`useList`* | bool | `false` | Enable list mode. When true, the viewport displays `items` as a selectable list instead of acting as a scrollable container. |
| *`items`* | String | `""` | Newline-separated list of items, used in list mode. Each line becomes a selectable row. |
| *`scrollBarThickness`* | int | `16` | Scrollbar width in pixels. Can be overridden by the CSS `scrollbar { width: ... }` property. |
| *`autoHide`* | bool | `true` | Auto-hide the scrollbar when the content is not being scrolled. |
| *`viewPositionX`* | int | `0` | Horizontal scroll position. |
| *`viewPositionY`* | int | `0` | Vertical scroll position. In list/table modes, this is a normalized 0.0-1.0 value. |
| *`fontName`* | String | `"Arial"` | Font family for list item text. |
| *`fontSize`* | double | `13` | Font size for list items in pixels. |
| *`fontStyle`* | String | `"plain"` | Font style for list items: `"plain"`, `"bold"`, `"italic"`, or `"bold italic"`. |
| *`alignment`* | String | `"centred"` | Text alignment for list items: `"left"`, `"right"`, `"centred"`, `"centredTop"`, `"centredBottom"`, `"topLeft"`, `"topRight"`, `"bottomLeft"`, `"bottomRight"`. |

### Common properties

| Property | Description |
|----------|-------------|
| `x`, `y`, `width`, `height` | Position and size in pixels, relative to parent |
| `text`, `tooltip` | Display text and hover tooltip |
| `visible`, `enabled`, `locked` | Display and interaction state |
| `bgColour`, `itemColour`, `itemColour2`, `textColour` | Colour properties |
| `defaultValue` | Default selected item index |
| `parentComponent` | Parent component for layout nesting |
| `saveInPreset`, `useUndoManager`, `deferControlCallback` | Preset persistence, undo, and callback deferral |
| `isPluginParameter`, `pluginParameterName`, `pluginParameterGroup`, `automationID` | DAW automation |
| `isMetaParameter`, `linkedTo` | Parameter linking |
| `processorId`, `parameterId` | Module parameter connection |

### Deactivated properties

The following properties are deactivated for ScriptedViewport and have no effect:

`macroControl`, `min`, `max`.

## CSS Styling

CSS is primarily useful in list mode (`useList = true`). Use the `.scriptviewport` class selector for the component background, `tr` for list item rows, and `scrollbar` for the scrollbar thumb.

> [!Tip:CSS is the only way to style list items] There is no LAF function for list mode item rendering. Use CSS `tr` selectors with `:hover`, `:active`, and `:checked` pseudo-states for full visual control. For per-item differentiation (e.g., different alpha on specific text), switch to table mode which offers `drawTableCell` LAF with access to row data.

### Selectors

| Selector | Type | Description |
|----------|------|-------------|
| `.scriptviewport` | Class | Default class selector for the viewport background |
| `#Viewport1` | ID | Targets a specific viewport by component name |

### Sub-selectors

| Selector | Description |
|----------|-------------|
| `tr` | Individual list item rows (in list mode) |
| `scrollbar` | The scrollbar thumb |

### Pseudo-states

#### List items (`tr`)

| State | Description |
|-------|-------------|
| `:hover` | Mouse is over the list item |
| `:active` | Mouse button is pressed on the item |
| `:checked` | The item is selected |

#### Scrollbar (`scrollbar`)

| State | Description |
|-------|-------------|
| `:hover` | Mouse is over the scrollbar |
| `:active` | Scrollbar is being dragged |

### CSS Variables

| Variable | Description |
|----------|-------------|
| `--bgColour` | Background colour from the `bgColour` property |
| `--itemColour` | From the `itemColour` property |
| `--itemColour2` | From the `itemColour2` property |
| `--textColour` | Text colour from the `textColour` property |

### Example Stylesheet

```javascript
const var vp = Content.addViewport("Viewport1", 10, 10);

vp.set("useList", true);
vp.set("height", 200);
vp.set("bgColour", 0);
vp.set("items", "Item1\nItem2\nItem3\nItem4\nItem5\nItem6\nItem7\nItem8\nItem9\n");

const var laf = Content.createLocalLookAndFeel();

laf.setInlineStyleSheet("
/** Style the items in the list. */
tr
{
	background-color: orange;
	color: black;
	text-align: left;
	padding: 10px;
	margin: 2px;
	border-radius: 5px;
	box-shadow: 0px 0px 2px black;
}

tr:hover
{
	background-color: color-mix(in rgba, orange 60%, white);
	transition: background-color 0.3s ease-in-out;
}

/** On mouse down. */
tr:active
{
	background: color-mix(in rgba, orange 40%, white);
	margin: 3px;
}

/** If the row is selected. */
tr:checked
{
	background: red;
	font-weight: bold;
	border: 3px solid rgba(255, 255,255, 0.4);
}

/** Style the scrollbar. */
scrollbar
{
	background-color: orange;
	/** Defining the width overrides the scrollbarThickness property. */
	width: 16px;
	margin: 3px;
	border-radius: 5px;
}

scrollbar:hover
{
	background-color: color-mix(in rgba, orange 60%, white);
	transition: background-color 0.3s ease-in-out;
}
");

vp.setLocalLookAndFeel(laf);
```

## LAF Customisation (Table Mode)

In table mode, register LAF functions to fully control the rendering of table rows, cells, headers, and the scrollbar. In list mode, CSS is the primary styling mechanism (no table LAF functions apply). The `drawScrollbar` function applies to all modes.

### LAF Functions

| Function | Mode | Description |
|----------|------|-------------|
| `drawTableRowBackground` | Table | Draws the background of each table row (hover, selection states) |
| `drawTableCell` | Table | Draws the content of each text cell |
| `drawTableHeaderBackground` | Table | Draws the header bar background |
| `drawTableHeaderColumn` | Table | Draws individual column headers (including sort indicators) |

> [!Warning:setTableSortFunction requires Sortable in setTableMode metadata] Clicking column headers does nothing unless `"Sortable": true` is set in the `setTableMode()` metadata object. Without it, `setTableSortFunction()` is registered but never called, and no visual feedback occurs on header click.
| `drawScrollbar` | All | Draws the scrollbar thumb |

> **Note:** The `obj` property details for each table LAF function are documented in the scripting API reference for `ScriptedViewport.setLocalLookAndFeel()`. A complete table visual override requires registering all four table functions plus `drawScrollbar` on a single LAF object.

## Notes

- **Three modes:** Plain viewport (default), list mode (`useList = true`), and table mode (`setTableMode()`). Choose the mode at init time — it cannot be changed later.
- **List mode** displays `items` as selectable rows. The value is the selected item index. Use CSS with `tr` selectors to style individual rows. Row height in list mode is fixed at 30px and cannot be changed via properties or CSS — use table mode with configurable `RowHeight` if you need different row heights.
- **List mode colour roles** (without CSS): `bgColour` = component background, `itemColour` = selected item background, `itemColour2` = selected item outline, `textColour` = item text colour.
- **Table mode** enables sortable columns with interactive cell types (Text, Button, Slider, ComboBox). Call `setTableMode()`, then `setTableColumns()`, then `setTableCallback()` during `onInit`. Update data with `setTableRowData()`.
- **Broadcaster as table callback.** You can pass a Broadcaster directly to `setTableCallback()` instead of an inline function. The Broadcaster receives the event object as its message, enabling fan-out to multiple listeners (e.g., one for loading, another for favorites, a third for preview playback).
- **Plain viewport mode** creates a large scrollable canvas (4000×4000) internally. Parent child panels inside it for virtual scrolling over arbitrarily tall content. Note that child panels with mouse callbacks can intercept scrollbar click events — if the scrollbar becomes unresponsive, check for overlapping child panel mouse areas.
- **`viewPositionY` is normalized** in list/table modes (0.0-1.0 range). Use `(targetRow + 1) / totalRows` to scroll to a specific row.
- **Scrollbar width** can be set via the `scrollBarThickness` property or overridden by CSS `scrollbar { width: ... }`. Use `scrollBarThickness = 8` to `10` for a minimal scrollbar.
- **`autoHide`** hides the scrollbar when content is not being scrolled. Set to `false` to keep it always visible.
- **Font properties** (`fontName`, `fontSize`, `fontStyle`, `alignment`) affect list item rendering. These have no effect in plain viewport mode.
- **CSS uses `.scriptviewport`** as the class selector, not the `table` HTML tag. The `table` tag is reserved in CSS for the HTML table element and is not used here.
- **Table setup sequence:** `setTableMode()` → `setTableColumns()` → `setTableCallback()` → `setTableRowData()`. All setup calls except `setTableRowData()` must happen during `onInit`.

**See also:** {placeholder — populated during cross-reference post-processing}
