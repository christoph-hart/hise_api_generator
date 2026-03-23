## addTablePoint

**Signature:** `undefined addTablePoint(Number x, Number y)`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Minimal Example:** `{obj}.addTablePoint(0.5, 0.75);`

**Description:**
Adds a new graph point to the table data. The point is appended and the table is recalculated.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| x | Number | no | Normalized x position for the new point | Intended range: 0.0-1.0 |
| y | Number | no | Normalized y value for the new point | Intended range: 0.0-1.0 |

**Pitfalls:**
- `addTablePoint()` does not clamp x / y to 0..1 in the underlying `Table` implementation, so out-of-range values can create unexpected curve shapes.

**Cross References:**
- `ScriptTable.setTablePoint`
- `ScriptTable.reset`

---

## addToMacroControl [inherited from ScriptComponent]

**Disabled:** property-deactivated
**Disabled Reason:** `ScriptTable` deactivates the `macroControl` property in `ComplexDataScriptComponent::handleDefaultDeactivatedProperties()`, so macro assignment is intentionally not part of this component's active property model.

---

## changed [inherited from ScriptComponent]

**Signature:** `undefined changed()`
**Return Type:** `undefined`
**Call Scope:** safe
**Minimal Example:** `{obj}.changed();`

**Description:**
Triggers the control callback for this component (custom callback from `setControlCallback` or default `onControl`).

**Pitfalls:**
- Calling `changed()` during `onInit` is ignored.
- If `deferControlCallback` is enabled, callback execution is deferred to the message thread.

**Cross References:**
- `ScriptTable.setControlCallback`
- `ScriptTable.getValue`

---

## fadeComponent [inherited from ScriptComponent]

**Signature:** `undefined fadeComponent(Integer shouldBeVisible, Integer milliseconds)`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Minimal Example:** `{obj}.fadeComponent(1, 250);`

**Description:**
Fades the component in or out by changing visibility with an animation.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| shouldBeVisible | Integer | no | Target visibility state | 1 = show, 0 = hide |
| milliseconds | Integer | no | Fade duration in milliseconds | > 0 |

**Cross References:**
- `ScriptTable.showControl`

---

## get [inherited from ScriptComponent]

**Signature:** `var get(String propertyName)`
**Return Type:** `var`
**Call Scope:** safe
**Minimal Example:** `var v = {obj}.get("tableIndex");`

**Description:**
Returns the current value of a ScriptTable property.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| propertyName | String | no | Property ID to query | Must be a valid ScriptTable property |

**Cross References:**
- `ScriptTable.set`
- `ScriptTable.getAllProperties`

---

## getAllProperties [inherited from ScriptComponent]

**Signature:** `Array getAllProperties()`
**Return Type:** `Array`
**Call Scope:** unsafe
**Minimal Example:** `var props = {obj}.getAllProperties();`

**Description:**
Returns all active property IDs for this component, including ScriptTable-specific properties.

**Cross References:**
- `ScriptTable.get`
- `ScriptTable.set`

---

## getChildComponents [inherited from ScriptComponent]

**Signature:** `Array getChildComponents()`
**Return Type:** `Array`
**Call Scope:** unsafe
**Minimal Example:** `var children = {obj}.getChildComponents();`

**Description:**
Returns child ScriptComponents whose `parentComponent` property references this component.

---

## getGlobalPositionX [inherited from ScriptComponent]

**Signature:** `Integer getGlobalPositionX()`
**Return Type:** `Integer`
**Call Scope:** safe
**Minimal Example:** `var x = {obj}.getGlobalPositionX();`

**Description:**
Returns the absolute x position relative to the interface root.

**Cross References:**
- `ScriptTable.getGlobalPositionY`

---

## getGlobalPositionY [inherited from ScriptComponent]

**Signature:** `Integer getGlobalPositionY()`
**Return Type:** `Integer`
**Call Scope:** safe
**Minimal Example:** `var y = {obj}.getGlobalPositionY();`

**Description:**
Returns the absolute y position relative to the interface root.

**Cross References:**
- `ScriptTable.getGlobalPositionX`

---

## getHeight [inherited from ScriptComponent]

**Signature:** `Integer getHeight()`
**Return Type:** `Integer`
**Call Scope:** safe
**Minimal Example:** `var h = {obj}.getHeight();`

**Description:**
Returns the component height in pixels.

---

## getId [inherited from ScriptComponent]

**Signature:** `String getId()`
**Return Type:** `String`
**Call Scope:** safe
**Minimal Example:** `var id = {obj}.getId();`

**Description:**
Returns the ScriptTable component ID.

---

## getLocalBounds [inherited from ScriptComponent]

**Signature:** `Array getLocalBounds(Double reduceAmount)`
**Return Type:** `Array`
**Call Scope:** safe
**Minimal Example:** `var b = {obj}.getLocalBounds(0.0);`

**Description:**
Returns `[x, y, width, height]` in local coordinates, optionally reduced by `reduceAmount`.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| reduceAmount | Double | no | Inset amount on each side | >= 0.0 |

---

## getTableValue

**Signature:** `Number getTableValue(Number inputValue)`
**Return Type:** `Number`
**Call Scope:** unsafe
**Minimal Example:** `var y = {obj}.getTableValue(0.25);`

**Description:**
Returns the interpolated table output value for a normalized input position.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| inputValue | Number | no | Normalized lookup position | Intended range: 0.0-1.0 |

**Pitfalls:**
- [BUG] If the bound data source is missing or not a `SampleLookupTable`, this method silently returns `0.0`.

**Cross References:**
- `ScriptTable.addTablePoint`
- `ScriptTable.setTablePoint`

---

## sendRepaintMessage [inherited from ScriptComponent]

**Signature:** `undefined sendRepaintMessage()`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Minimal Example:** `{obj}.sendRepaintMessage();`

**Description:**
Requests an asynchronous repaint for this component.

---

## set [inherited from ScriptComponent]

**Signature:** `undefined set(String propertyName, NotUndefined value)`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Minimal Example:** `{obj}.set("customColours", 1);`

**Description:**
Sets a ScriptTable property value.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| propertyName | String | no | Property ID to set | Must be a valid ScriptTable property |
| value | NotUndefined | no | Property value | Must match property type |

**Cross References:**
- `ScriptTable.get`
- `ScriptTable.getAllProperties`

---

## setConsumedKeyPresses [inherited from ScriptComponent]

**Signature:** `undefined setConsumedKeyPresses(NotUndefined listOfKeys)`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Minimal Example:** `{obj}.setConsumedKeyPresses("all");`

**Description:**
Defines which key presses this component should consume before `setKeyPressCallback` is used.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| listOfKeys | NotUndefined | no | Key specification string, object, or array | Must be valid key descriptions |

**Value Descriptions:**

| Value | Description |
|-------|-------------|
| "all" | Consume all keys exclusively |
| "all_nonexclusive" | Consume all keys but still allow parent handling |

**Callback Properties:**

| Property | Type | Description |
|----------|------|-------------|
| keyCode | int | JUCE key code (required for object form) |
| shift | bool | Shift modifier required |
| cmd | bool | Cmd / Ctrl modifier required (also accepts `ctrl`) |
| alt | bool | Alt modifier required |
| character | String | Optional character text |

**Cross References:**
- `ScriptTable.setKeyPressCallback`

---

## setControlCallback [inherited from ScriptComponent]

**Signature:** `undefined setControlCallback(Function controlFunction)`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Minimal Example:** `{obj}.setControlCallback(onTableControl);`

**Description:**
Sets a custom inline control callback for this component.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| controlFunction | Function | yes | Inline callback or `false` to clear custom callback | Must be inline and use 2 parameters |

**Callback Signature:** controlFunction(component: ScriptComponent, value: var)

**Pitfalls:**
- Callback must be declared as `inline function(component, value)`.
- Callback must have exactly 2 parameters.
- If processor-parameter forwarding is active, custom control callbacks are rejected.

**Cross References:**
- `ScriptTable.changed`

---

## setKeyPressCallback [inherited from ScriptComponent]

**Signature:** `undefined setKeyPressCallback(Function keyboardFunction)`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Minimal Example:** `{obj}.setKeyPressCallback(onTableKey);`

**Description:**
Registers a key/focus callback for consumed key presses on this component.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| keyboardFunction | Function | yes | Inline callback receiving a key event object | Requires prior `setConsumedKeyPresses(...)` call |

**Callback Signature:** keyboardFunction(event: Object)

**Callback Properties:**

| Property | Type | Description |
|----------|------|-------------|
| isFocusChange | bool | `true` for focus events, `false` for key events |
| character | String | Printable character for key events |
| specialKey | bool | `true` for non-printable key events |
| isWhitespace | bool | Key character is whitespace |
| isLetter | bool | Key character is alphabetic |
| isDigit | bool | Key character is numeric |
| keyCode | int | JUCE key code |
| description | String | Human-readable key description |
| shift | bool | Shift pressed |
| cmd | bool | Cmd/Ctrl pressed |
| alt | bool | Alt pressed |
| hasFocus | bool | Present on focus-change events |

**Pitfalls:**
- Must call `setConsumedKeyPresses()` first or the call reports a script error.

**Cross References:**
- `ScriptTable.setConsumedKeyPresses`

---

## setLocalLookAndFeel [inherited from ScriptComponent]

**Signature:** `undefined setLocalLookAndFeel(ScriptObject lafObject)`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Minimal Example:** `{obj}.setLocalLookAndFeel(laf);`

**Description:**
Assigns a local scripted look-and-feel object to this component and its children.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| lafObject | ScriptObject | no | Local look-and-feel object, or `false` to clear it | Must be a ScriptedLookAndFeel object |

**Cross References:**
- `ScriptTable.setStyleSheetClass`
- `ScriptTable.setStyleSheetProperty`
- `ScriptTable.setStyleSheetPseudoState`

---

## setTablePoint

**Signature:** `undefined setTablePoint(Integer pointIndex, Number x, Number y, Number curve)`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Minimal Example:** `{obj}.setTablePoint(1, 0.5, 0.8, 0.5);`

**Description:**
Updates an existing graph point in the table.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| pointIndex | Integer | no | Graph point index to edit | Must reference an existing point |
| x | Number | no | New normalized x value | Clamped to 0.0-1.0 (edge points keep x) |
| y | Number | no | New normalized y value | Clamped to 0.0-1.0 |
| curve | Number | no | Curve amount toward next point | Clamped to 0.0-1.0 |

**Pitfalls:**
- [BUG] Out-of-range `pointIndex` values are silently ignored.
- The first and last points keep fixed x positions (`0` and `1`) even if another x value is supplied.

**Cross References:**
- `ScriptTable.addTablePoint`
- `ScriptTable.getTableValue`

---

## setTablePopupFunction

**Signature:** `undefined setTablePopupFunction(Function newFunction)`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Minimal Example:** `{obj}.setTablePopupFunction(onTablePopupText);`

**Description:**
Sets a custom function for drag-popup text formatting. The function receives `(x, y)` and should return display text.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| newFunction | Function | no | Popup text formatter callback, or `false` to fall back to default popup text | Should return a String-compatible value |

**Callback Signature:** newFunction(x: double, y: double)

**Pitfalls:**
- Non-function values do not throw an error; the table silently falls back to default popup text (`x | y`).

**Cross References:**
- `ScriptTable.setSnapValues`
- `ScriptTable.setMouseHandlingProperties`

**Example:**
```javascript:script-table-popup-function
// Title: Use a custom popup formatter while dragging points
const var Table1 = Content.addTable("Table1", 0, 0);

inline function onTablePopupText(x, y)
{
    return "Pos " + x + " -> " + y;
}

Table1.setTablePopupFunction(onTablePopupText);
```

```json:testMetadata:script-table-popup-function
{
  "testable": false,
  "skipReason": "Popup callback is only invoked by interactive table dragging, which is not programmatically triggerable in snippet validation"
}
```

---

## setTooltip [inherited from ScriptComponent]

**Signature:** `undefined setTooltip(String tooltip)`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Minimal Example:** `{obj}.setTooltip("Drag to edit envelope");`

**Description:**
Sets tooltip text shown on hover.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| tooltip | String | no | Tooltip text | -- |

---

## setValue [inherited from ScriptComponent]

**Signature:** `undefined setValue(NotUndefined newValue)`
**Return Type:** `undefined`
**Call Scope:** safe
**Minimal Example:** `{obj}.setValue(0.5);`

**Description:**
Sets the generic ScriptComponent value and triggers linked updates.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| newValue | NotUndefined | no | New component value | Must not be a String |

**Pitfalls:**
- String values are rejected with a script error.
- Values set during `onInit` are not restored after recompilation.

**Cross References:**
- `ScriptTable.getValue`
- `ScriptTable.setValueWithUndo`

---

## setValueNormalized [inherited from ScriptComponent]

**Signature:** `undefined setValueNormalized(Double normalizedValue)`
**Return Type:** `undefined`
**Call Scope:** safe
**Minimal Example:** `{obj}.setValueNormalized(0.5);`

**Description:**
Sets the value using normalized input through the base ScriptComponent path.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| normalizedValue | Double | no | Normalized value | 0.0-1.0 |

**Cross References:**
- `ScriptTable.getValueNormalized`
- `ScriptTable.setValue`

---

## setValueWithUndo [inherited from ScriptComponent]

**Signature:** `undefined setValueWithUndo(NotUndefined newValue)`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Minimal Example:** `{obj}.setValueWithUndo(0.5);`

**Description:**
Sets the component value using the undo manager.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| newValue | NotUndefined | no | New value to apply with undo support | Must not be a String |

**Pitfalls:**
- Do not call from control callbacks. This API is intended for explicit undoable user actions.

**Cross References:**
- `ScriptTable.setValue`

---

## setZLevel [inherited from ScriptComponent]

**Signature:** `undefined setZLevel(String zLevel)`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Minimal Example:** `{obj}.setZLevel("Front");`

**Description:**
Sets rendering z-level relative to sibling components.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| zLevel | String | no | Z-level selector | Must be a valid value |

**Value Descriptions:**

| Value | Description |
|-------|-------------|
| "Back" | Render behind siblings |
| "Default" | Use default layer order |
| "Front" | Render in front of default siblings |
| "AlwaysOnTop" | Keep component above all siblings |

---

## showControl [inherited from ScriptComponent]

**Signature:** `undefined showControl(Integer shouldBeVisible)`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Minimal Example:** `{obj}.showControl(1);`

**Description:**
Shows or hides the component.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| shouldBeVisible | Integer | no | Visibility toggle | 1 = show, 0 = hide |

**Cross References:**
- `ScriptTable.fadeComponent`

---

## updateValueFromProcessorConnection [inherited from ScriptComponent]

**Signature:** `undefined updateValueFromProcessorConnection()`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Minimal Example:** `{obj}.updateValueFromProcessorConnection();`

**Description:**
Reads the currently connected processor parameter and forwards it into `setValue()`.

**Pitfalls:**
- If no valid processor/parameter connection is configured, this call silently does nothing.

**Cross References:**
- `ScriptTable.setValue`

---

## setMouseHandlingProperties

**Signature:** `undefined setMouseHandlingProperties(JSON propertyObject)`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Minimal Example:** `{obj}.setMouseHandlingProperties({"allowSwap": true, "snapWidth": 8.0});`

**Description:**
Configures table drag interaction behavior by forwarding a property object to the internal `TableEditor::MouseDragProperties` parser.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| propertyObject | JSON | no | Mouse-drag configuration object | Uses known property keys listed below |

**Callback Properties:**

| Property | Type | Description |
|----------|------|-------------|
| syncStartEnd | bool | Mirror y value between first and last point while dragging edges |
| allowSwap | bool | Allow point crossing on the x axis |
| fixLeftEdge | double | Lock first point y value (`>-0.5` enables lock) |
| fixRightEdge | double | Lock last point y value (`>-0.5` enables lock) |
| snapWidth | double | Snap capture width in pixels |
| numSteps | int | Build evenly spaced snap grid (`-1` keeps current grid) |
| midPointSize | int | Midpoint handle size |
| dragPointSize | int | Regular drag point size |
| endPointSize | int | Edge point size |
| useMouseWheelForCurve | bool | Enable wheel-based curve editing |
| margin | double | Editor margin in pixels |
| closePath | bool | Close path shape for area fill |

**Cross References:**
- `ScriptTable.setSnapValues`
- `ScriptTable.setTablePoint`
- `ScriptTable.setTablePopupFunction`

**Example:**
```javascript:script-table-mouse-drag-properties
// Title: Configure snap, edge locks, and drag behavior
const var Table1 = Content.addTable("Table1", 0, 0);

Table1.setMouseHandlingProperties({
    "allowSwap": false,
    "syncStartEnd": true,
    "numSteps": 8,
    "snapWidth": 6.0,
    "fixLeftEdge": 0.0,
    "fixRightEdge": 1.0
});
```

```json:testMetadata:script-table-mouse-drag-properties
{
  "testable": false,
  "skipReason": "Behavior is user-interaction dependent (dragging and wheel edits) and cannot be deterministically triggered in snippet validation"
}
```

---

## setPosition [inherited from ScriptComponent]

**Signature:** `undefined setPosition(Integer x, Integer y, Integer w, Integer h)`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Minimal Example:** `{obj}.setPosition(10, 10, 220, 80);`

**Description:**
Sets x, y, width, and height in one call.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| x | Integer | no | X position | 0-900 |
| y | Integer | no | Y position | 0-MAX_SCRIPT_HEIGHT |
| w | Integer | no | Width | 0-900 |
| h | Integer | no | Height | 0-MAX_SCRIPT_HEIGHT |

---

## setPropertiesFromJSON [inherited from ScriptComponent]

**Disabled:** redundant
**Disabled Reason:** This method is declared in `ScriptComponent` but not directly exposed on component instances in this API path. Use `Content.setPropertiesFromJSON(componentId, jsonData)` instead.

---

## setSnapValues

**Signature:** `undefined setSnapValues(Array snapValueArray)`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Minimal Example:** `{obj}.setSnapValues([0.0, 0.25, 0.5, 0.75, 1.0]);`

**Description:**
Sets x-axis snap targets for drag operations.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| snapValueArray | Array | no | Normalized snap x positions | Values should be in 0.0-1.0 |

**Pitfalls:**
- [BUG] Passing a non-array reports an error, but the method still updates internal state before wrapper-side validation, which can make debugging mixed setups confusing.

**Cross References:**
- `ScriptTable.setMouseHandlingProperties`
- `ScriptTable.setTablePopupFunction`

---

## setStyleSheetClass [inherited from ScriptComponent]

**Signature:** `undefined setStyleSheetClass(String classIds)`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Minimal Example:** `{obj}.setStyleSheetClass(".envelope .active");`

**Description:**
Sets CSS class selectors for this component. The component type class is prepended automatically.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| classIds | String | no | Space-separated CSS classes | eg. `.envelope .active` |

**Cross References:**
- `ScriptTable.setStyleSheetProperty`
- `ScriptTable.setStyleSheetPseudoState`

---

## setStyleSheetProperty [inherited from ScriptComponent]

**Signature:** `undefined setStyleSheetProperty(String variableId, NotUndefined value, String type)`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Minimal Example:** `{obj}.setStyleSheetProperty("line-colour", Colours.red, "color");`

**Description:**
Sets a CSS variable value on this component with optional unit conversion.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| variableId | String | no | CSS variable identifier | -- |
| value | NotUndefined | no | Value to store | Must match conversion mode |
| type | String | no | Conversion mode | See value descriptions |

**Value Descriptions:**

| Value | Description |
|-------|-------------|
| "path" | Convert Path object to base64 string |
| "color" | Convert colour value to CSS `#AARRGGBB` |
| "%" | Convert number to percent string |
| "px" | Convert number to pixel string |
| "em" | Convert number to em string |
| "vh" | Convert number to viewport-height string |
| "deg" | Convert number to degree string |
| "" | Store value without conversion |

**Cross References:**
- `ScriptTable.setStyleSheetClass`
- `ScriptTable.setStyleSheetPseudoState`

---

## setStyleSheetPseudoState [inherited from ScriptComponent]

**Signature:** `undefined setStyleSheetPseudoState(String pseudoState)`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Minimal Example:** `{obj}.setStyleSheetPseudoState(":hover:active");`

**Description:**
Sets CSS pseudo-state flags for this component and triggers repaint.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| pseudoState | String | no | Combined pseudo-state string | Empty string clears all states |

**Value Descriptions:**

| Value | Description |
|-------|-------------|
| ":first-child" | First-child selector |
| ":last-child" | Last-child selector |
| ":root" | Root selector |
| ":hover" | Hover state |
| ":active" | Active state |
| ":focus" | Focus state |
| ":disabled" | Disabled state |
| ":hidden" | Hidden state |
| ":checked" | Checked state |

**Cross References:**
- `ScriptTable.setStyleSheetClass`
- `ScriptTable.setStyleSheetProperty`

---

## getValue [inherited from ScriptComponent]

**Signature:** `var getValue()`
**Return Type:** `var`
**Call Scope:** safe
**Minimal Example:** `var v = {obj}.getValue();`

**Description:**
Returns the current component value from ScriptComponent's generic value store.

**Cross References:**
- `ScriptTable.setValue`
- `ScriptTable.getValueNormalized`

---

## getValueNormalized [inherited from ScriptComponent]

**Signature:** `Double getValueNormalized()`
**Return Type:** `Double`
**Call Scope:** safe
**Minimal Example:** `var v = {obj}.getValueNormalized();`

**Description:**
Returns the normalized value from ScriptComponent's base value path.

**Cross References:**
- `ScriptTable.setValueNormalized`
- `ScriptTable.getValue`

---

## getWidth [inherited from ScriptComponent]

**Signature:** `Integer getWidth()`
**Return Type:** `Integer`
**Call Scope:** safe
**Minimal Example:** `var w = {obj}.getWidth();`

**Description:**
Returns the component width in pixels.

---

## grabFocus [inherited from ScriptComponent]

**Signature:** `undefined grabFocus()`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Minimal Example:** `{obj}.grabFocus();`

**Description:**
Requests keyboard focus for this component via z-level listeners.

**Cross References:**
- `ScriptTable.loseFocus`

---

## loseFocus [inherited from ScriptComponent]

**Signature:** `undefined loseFocus()`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Minimal Example:** `{obj}.loseFocus();`

**Description:**
Requests focus release from z-level listeners.

**Cross References:**
- `ScriptTable.grabFocus`

---

## referToData

**Signature:** `undefined referToData(ScriptObject tableData)`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Minimal Example:** `{obj}.referToData(otherTable);`

**Description:**
Rebinds this ScriptTable to another table data source. Accepts a `ScriptTableData` handle, another complex-data component with table data, or `-1` to return to its internal owned table.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| tableData | ScriptObject | no | External table source handle, compatible component, or reset token | `ScriptTableData`, compatible complex-data component, or `-1` |

**Pitfalls:**
- [BUG] Passing an unsupported argument type silently does nothing and keeps the previous data source.

**Cross References:**
- `ScriptTable.registerAtParent`

**Example:**
```javascript:script-table-refer-to-data
// Title: Share table data between two ScriptTable components
const var TableA = Content.addTable("TableA", 0, 0);
const var TableB = Content.addTable("TableB", 0, 80);

const var sharedData = TableA.registerAtParent(0);
TableB.referToData(sharedData);
```

```json:testMetadata:script-table-refer-to-data
{
  "testable": false,
  "skipReason": "Requires a ProcessorWithDynamicExternalData parent context to guarantee ScriptTableData registration in validator snippets"
}
```

---

## registerAtParent

**Signature:** `ScriptObject registerAtParent(Integer index)`
**Return Type:** `ScriptObject`
**Call Scope:** unsafe
**Minimal Example:** `var td = {obj}.registerAtParent(0);`

**Description:**
Registers this component's owned table at the parent processor's external-data slot and returns a `ScriptTableData` handle for that slot.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| index | Integer | no | External table slot index at the parent processor | >= 0 |

**Pitfalls:**
- [BUG] If the parent is not a `ProcessorWithDynamicExternalData`, this method returns `undefined` without a script error.

**Cross References:**
- `ScriptTable.referToData`

**Example:**
```javascript:script-table-register-at-parent
// Title: Register ScriptTable data and keep handle for external access
const var Table1 = Content.addTable("Table1", 0, 0);
const var tableData = Table1.registerAtParent(0);
```

```json:testMetadata:script-table-register-at-parent
{
  "testable": false,
  "skipReason": "Requires ProcessorWithDynamicExternalData host support that is not guaranteed in generic snippet validation"
}
```

---

## reset

**Signature:** `undefined reset()`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Minimal Example:** `{obj}.reset();`

**Description:**
Resets the table data to a default linear ramp from `(0, 0)` to `(1, 1)`.

**Cross References:**
- `ScriptTable.addTablePoint`
- `ScriptTable.setTablePoint`
