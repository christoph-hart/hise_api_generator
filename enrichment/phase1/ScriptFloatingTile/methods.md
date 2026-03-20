# ScriptFloatingTile -- Method Documentation

---

## addToMacroControl

**Signature:** `undefined addToMacroControl(Integer macroIndex)`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Minimal Example:** `{obj}.addToMacroControl(0);`

**Description:**
Assigns this component to a macro controller slot. Sets the internal `connectedMacroIndex`.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| macroIndex | Integer | no | The macro controller index | 0-7 |

---

## changed

**Signature:** `undefined changed()`
**Return Type:** `undefined`
**Call Scope:** safe
**Minimal Example:** `{obj}.changed();`

**Description:**
Triggers the control callback (either the custom one set via `setControlCallback` or the default `onControl` callback). Also notifies any registered value listeners.

**Pitfalls:**
- Cannot be called during `onInit` -- if called during `onInit`, it logs a console message and returns without executing.
- If `deferControlCallback` is set, the callback is deferred to the message thread.
- If the callback function throws an error, further script execution after the `changed()` call is aborted.

**Cross References:**
- `ScriptFloatingTile.setControlCallback`
- `ScriptFloatingTile.getValue`

---

## fadeComponent

**Signature:** `undefined fadeComponent(Integer shouldBeVisible, Integer milliseconds)`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Minimal Example:** `{obj}.fadeComponent(1, 500);`

**Description:**
Toggles visibility with a fade animation over the specified duration in milliseconds. Only triggers if the target visibility differs from the current visibility. Sets the `visible` property and sends an async fade message through the global UI animator.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| shouldBeVisible | Integer | no | Target visibility state | 1 = show, 0 = hide |
| milliseconds | Integer | no | Duration of the fade animation in milliseconds | > 0 |

**Cross References:**
- `ScriptFloatingTile.showControl`

---

## get

**Signature:** `var get(String propertyName)`
**Return Type:** `var`
**Call Scope:** safe
**Minimal Example:** `var v = {obj}.get("text");`

**Description:**
Returns the current value of the named property. If the property is set on the component's value tree, returns that value; otherwise returns the default. Reports a script error if the property does not exist.

Base properties available on all components: `text`, `visible`, `enabled`, `locked`, `x`, `y`, `width`, `height`, `min`, `max`, `defaultValue`, `tooltip`, `bgColour`, `itemColour`, `itemColour2`, `textColour`, `macroControl`, `saveInPreset`, `isPluginParameter`, `pluginParameterName`, `pluginParameterGroup`, `deferControlCallback`, `isMetaParameter`, `linkedTo`, `automationId`, `useUndoManager`, `parentComponent`, `processorId`, `parameterId`. Child component types add additional properties.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| propertyName | String | no | The name of a component property to retrieve | Must be a valid property ID for this component type |

**Cross References:**
- `ScriptFloatingTile.set`
- `ScriptFloatingTile.getAllProperties`

---

## getAllProperties

**Signature:** `Array getAllProperties()`
**Return Type:** `Array`
**Call Scope:** unsafe
**Minimal Example:** `var props = {obj}.getAllProperties();`

**Description:**
Returns an array of strings containing all active (non-deactivated) property IDs for this component. Includes both base ScriptComponent properties and any child-class-specific properties.

**Cross References:**
- `ScriptFloatingTile.get`
- `ScriptFloatingTile.set`

---

## getChildComponents

**Signature:** `Array getChildComponents()`
**Return Type:** `Array`
**Call Scope:** unsafe
**Minimal Example:** `var children = {obj}.getChildComponents();`

**Description:**
Returns an array of ScriptComponent references for all child components (components whose `parentComponent` is set to this component). Does not include the component itself in the result.

---

## getGlobalPositionX

**Signature:** `Integer getGlobalPositionX()`
**Return Type:** `Integer`
**Call Scope:** safe
**Minimal Example:** `var x = {obj}.getGlobalPositionX();`

**Description:**
Returns the absolute x-position relative to the interface root, computed by recursively adding parent component x-offsets.

**Cross References:**
- `ScriptFloatingTile.getGlobalPositionY`

---

## getGlobalPositionY

**Signature:** `Integer getGlobalPositionY()`
**Return Type:** `Integer`
**Call Scope:** safe
**Minimal Example:** `var y = {obj}.getGlobalPositionY();`

**Description:**
Returns the absolute y-position relative to the interface root, computed by recursively adding parent component y-offsets.

**Cross References:**
- `ScriptFloatingTile.getGlobalPositionX`

---

## getHeight

**Signature:** `Integer getHeight()`
**Return Type:** `Integer`
**Call Scope:** safe
**Minimal Example:** `var h = {obj}.getHeight();`

**Description:**
Returns the `height` property as an integer.

---

## getId

**Signature:** `String getId()`
**Return Type:** `String`
**Call Scope:** safe
**Minimal Example:** `var id = {obj}.getId();`

**Description:**
Returns the component's ID as a string (the variable name used when creating the component, e.g. `"Knob1"`).

---

## getLocalBounds

**Signature:** `Array getLocalBounds(Double reduceAmount)`
**Return Type:** `Array`
**Call Scope:** safe
**Minimal Example:** `var bounds = {obj}.getLocalBounds(0);`

**Description:**
Returns an array `[x, y, w, h]` representing the local bounds reduced by the given amount. The local bounds start at `[0, 0, width, height]`.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| reduceAmount | Double | no | The amount in pixels to inset from each edge | >= 0.0 |

---

## getValueNormalized

**Signature:** `Double getValueNormalized()`
**Return Type:** `Double`
**Call Scope:** safe
**Minimal Example:** `var v = {obj}.getValueNormalized();`

**Description:**
Returns the normalized value (0.0 to 1.0). Base implementation returns `getValue()` directly. Only meaningful on ScriptSlider, which maps the actual value back to the 0..1 range.

**Cross References:**
- `ScriptFloatingTile.setValueNormalized`
- `ScriptFloatingTile.getValue`

---

## getWidth

**Signature:** `Integer getWidth()`
**Return Type:** `Integer`
**Call Scope:** safe
**Minimal Example:** `var w = {obj}.getWidth();`

**Description:**
Returns the `width` property as an integer.

---

## grabFocus

**Signature:** `undefined grabFocus()`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Minimal Example:** `{obj}.grabFocus();`

**Description:**
Notifies z-level listeners that the component wants to grab keyboard focus. Only notifies the first listener (exclusive operation).

**Cross References:**
- `ScriptFloatingTile.loseFocus`

---

## loseFocus

**Signature:** `undefined loseFocus()`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Minimal Example:** `{obj}.loseFocus();`

**Description:**
Notifies all z-level listeners that the component wants to lose keyboard focus. Triggers the `wantsToLoseFocus()` callback on all registered `ZLevelListener` instances.

**Cross References:**
- `ScriptFloatingTile.grabFocus`

---

## sendRepaintMessage

**Signature:** `undefined sendRepaintMessage()`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Minimal Example:** `{obj}.sendRepaintMessage();`

**Description:**
Sends an asynchronous repaint message via `repaintBroadcaster`. This is useful when you've changed visual properties programmatically and need to force a UI redraw.

---

## set

**Signature:** `undefined set(String propertyName, NotUndefined value)`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Minimal Example:** `{obj}.set("text", "Hello");`

**Description:**
Sets a component property to the given value. Reports a script error if the property does not exist. During `onInit`, changes are applied without UI notification; outside `onInit`, sends change notifications to update the UI. Tracks which properties have been set by script for profiling purposes.

Base properties available on all components: `text`, `visible`, `enabled`, `locked`, `x`, `y`, `width`, `height`, `min`, `max`, `defaultValue`, `tooltip`, `bgColour`, `itemColour`, `itemColour2`, `textColour`, `macroControl`, `saveInPreset`, `isPluginParameter`, `pluginParameterName`, `pluginParameterGroup`, `deferControlCallback`, `isMetaParameter`, `linkedTo`, `automationId`, `useUndoManager`, `parentComponent`, `processorId`, `parameterId`. Child component types add additional properties.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| propertyName | String | no | The property identifier to set | Must be a valid property ID for this component type |
| value | NotUndefined | no | The new value for the property | Type must match the property's expected type |

**Cross References:**
- `ScriptFloatingTile.get`
- `ScriptFloatingTile.getAllProperties`

---

## setConsumedKeyPresses

**Signature:** `undefined setConsumedKeyPresses(NotUndefined listOfKeys)`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Minimal Example:** `{obj}.setConsumedKeyPresses("all");`

**Description:**
Defines which key presses this component consumes. Must be called before `setKeyPressCallback`. Accepts a string, object, or array of either.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| listOfKeys | NotUndefined | no | Key descriptions to consume -- a string, object, or array | See value descriptions and callback properties below |

**Value Descriptions:**

| Value | Description |
|-------|-------------|
| "all" | Catch all key presses exclusively (prevents parent from receiving them) |
| "all_nonexclusive" | Catch all key presses non-exclusively (parent still receives them) |

When passing individual key descriptions (as a string, object, or array of either), each key description can be:
- A string using JUCE key description format (e.g. `"A"`, `"ctrl + S"`, `"F5"`, `"shift + tab"`). Uses JUCE's `KeyPress::createFromDescription()`.
- A JSON object with the following properties:

**Callback Properties:**

| Property | Type | Description |
|----------|------|-------------|
| keyCode | int | The JUCE key code (required, must be non-zero) |
| shift | bool | Whether Shift modifier is required |
| cmd | bool | Whether Cmd/Ctrl modifier is required (also accepts "ctrl") |
| alt | bool | Whether Alt modifier is required |
| character | String | Optional character for the key press |

**Pitfalls:**
- Must be called BEFORE `setKeyPressCallback`. Reports a script error if an invalid key description is provided.

**Cross References:**
- `ScriptFloatingTile.setKeyPressCallback`

**Example:**
```javascript
// Consume all keys exclusively
panel.setConsumedKeyPresses("all");

// Consume specific keys by description string
panel.setConsumedKeyPresses(["ctrl + S", "F5", "escape"]);

// Consume specific keys by JSON object
panel.setConsumedKeyPresses([
    { "keyCode": 65, "ctrl": true },
    { "keyCode": 83, "ctrl": true }
]);
```

---

## setContentData

**Signature:** `undefined setContentData(JSON data)`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Minimal Example:** `{obj}.setContentData({"Type": "PresetBrowser"});`

**Description:**
Sets the floating tile's content by providing a complete JSON configuration object. The `"Type"` property in the JSON determines which panel type is instantiated. The entire JSON object is stored internally and passed to the underlying FloatingTile system. Calling this method forces the ContentType property to update, triggering a full content reload -- the panel is destroyed and recreated with the new configuration.

The JSON object should follow the FloatingTileContent configuration format. Colours can be specified in a `"ColourData"` sub-object using `"itemColour1"` (not `"itemColour"`). Panel-specific properties are passed alongside the standard keys.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| data | JSON | no | A JSON object with a "Type" property and optional panel-specific configuration | Must contain a "Type" property with a valid frontend panel type ID |

**Callback Properties:**

| Property | Type | Description |
|----------|------|-------------|
| Type | String | The panel type identifier (e.g. "PresetBrowser", "Keyboard"). Mandatory. |
| Font | String | Font name for text-rendering panels |
| FontSize | Number | Font size for text-rendering panels |
| ColourData | Object | Sub-object containing colour properties (bgColour, textColour, itemColour1, itemColour2, itemColour3) |

**Pitfalls:**
- The `"Type"` property is extracted from the JSON and used to update the ContentType. If `"Type"` is missing or invalid, the floating tile may revert to the Empty panel type without error.
- Colour names in `ColourData` use `"itemColour1"` instead of `"itemColour"`. Using `"itemColour"` in the ColourData sub-object will not map correctly.

**Cross References:**
- `ScriptFloatingTile.setValue`

**Example:**
```javascript:floating-tile-content-data
// Title: Configure a floating tile as a preset browser with custom colours
const var ft = Content.addFloatingTile("FloatingTile1", 0, 0);
ft.set("width", 600);
ft.set("height", 400);
ft.setContentData({
    "Type": "PresetBrowser",
    "Font": "Oxygen Bold",
    "FontSize": 16.0,
    "ColourData": {
        "bgColour": "0xFF222222",
        "textColour": "0xFFFFFFFF",
        "itemColour1": "0xFF444444",
        "itemColour2": "0xFF666666"
    }
});
```
```json:testMetadata:floating-tile-content-data
{
  "testable": true,
  "verifyScript": [
    {"type": "REPL", "expression": "ft.get(\"ContentType\")", "value": "PresetBrowser"}
  ]
}
```

---

## setControlCallback

**Signature:** `undefined setControlCallback(Function controlFunction)`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Minimal Example:** `{obj}.setControlCallback(onMyControl);`

**Description:**
Assigns a custom inline function as the control callback, replacing the default `onControl` handler for this component. Pass `undefined` to revert to the default `onControl` callback.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| controlFunction | Function | no | An inline function with 2 parameters (component, value), or undefined to clear | Must be an inline function with exactly 2 parameters |

**Pitfalls:**
- The function MUST be declared with `inline function`. Regular function references are rejected with a script error.
- Must have exactly 2 parameters. Reports a script error if the parameter count is wrong.
- Reports an error if the script processor has a DspNetwork that is forwarding controls to parameters.
- Passing `undefined` or empty `var()` clears the custom callback, reverting to the default `onControl` callback.

**Cross References:**
- `ScriptFloatingTile.changed`

**Example:**
```javascript
inline function onMyButton(component, value)
{
    Console.print(component.getId() + ": " + value);
};

btn.setControlCallback(onMyButton);
```

---

## setKeyPressCallback

**Signature:** `undefined setKeyPressCallback(Function keyboardFunction)`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Minimal Example:** `{obj}.setKeyPressCallback(onKeyPress);`

**Description:**
Registers a callback that fires when a consumed key is pressed while this component has focus. MUST call `setConsumedKeyPresses()` BEFORE calling this method. Reports a script error if `setConsumedKeyPresses` has not been called yet.

The callback receives an event object with two possible shapes depending on whether it is a key press or a focus change event.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| keyboardFunction | Function | no | An inline function with 1 parameter (event object) | Must be an inline function |

**Callback Properties:**

Key press event object:

| Property | Type | Description |
|----------|------|-------------|
| isFocusChange | bool | Always false for key events |
| character | String | The printable character, or "" for non-printable keys |
| specialKey | bool | true if not a printable character |
| isWhitespace | bool | true if the character is whitespace |
| isLetter | bool | true if the character is a letter |
| isDigit | bool | true if the character is a digit |
| keyCode | int | The JUCE key code |
| description | String | Human-readable description of the key press |
| shift | bool | true if Shift is held |
| cmd | bool | true if Cmd/Ctrl is held |
| alt | bool | true if Alt is held |

Focus change event object:

| Property | Type | Description |
|----------|------|-------------|
| isFocusChange | bool | Always true for focus events |
| hasFocus | bool | true if the component gained focus, false if lost |

**Pitfalls:**
- MUST call `setConsumedKeyPresses()` BEFORE calling this method. Reports a script error if `setConsumedKeyPresses` has not been called yet.

**Cross References:**
- `ScriptFloatingTile.setConsumedKeyPresses`

**Example:**
```javascript
const var panel = Content.addPanel("Panel1", 0, 0);
panel.setConsumedKeyPresses("all");
panel.setKeyPressCallback(inline function(event)
{
    if (!event.isFocusChange)
        Console.print("Key: " + event.description);
});
```

---

## setLocalLookAndFeel

**Signature:** `undefined setLocalLookAndFeel(ScriptObject lafObject)`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Minimal Example:** `{obj}.setLocalLookAndFeel(laf);`

**Description:**
Attaches a scripted look and feel object to this component and all its children. Pass `undefined` to clear it. The object must be a `ScriptedLookAndFeel` instance. If the object is not a valid LAF, the local look and feel is cleared.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| lafObject | ScriptObject | no | A ScriptedLookAndFeel object, or undefined to clear | Must be a ScriptedLookAndFeel instance |

**Pitfalls:**
- Propagates to ALL child components automatically -- iterates over all child ScriptComponent instances and sets their localLookAndFeel to the same object.
- If the LAF uses CSS (has a stylesheet), automatically calls `setStyleSheetClass({})` to initialize the class selector.
- When CSS mode is active, colour properties (bgColour, itemColour, itemColour2, textColour) are initialized in the property tree if not already present, and default-property-removal is disabled.

**Cross References:**
- `ScriptFloatingTile.setStyleSheetClass`
- `ScriptFloatingTile.setStyleSheetProperty`
- `ScriptFloatingTile.setStyleSheetPseudoState`

---

## setPosition

**Signature:** `undefined setPosition(Integer x, Integer y, Integer w, Integer h)`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Minimal Example:** `{obj}.setPosition(10, 10, 200, 50);`

**Description:**
Sets the component's position and size in one call. Directly sets the `x`, `y`, `width`, `height` properties on the property tree.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| x | Integer | no | X position in pixels, relative to parent | 0-900 |
| y | Integer | no | Y position in pixels, relative to parent | 0-MAX_SCRIPT_HEIGHT |
| w | Integer | no | Width in pixels | 0-900 |
| h | Integer | no | Height in pixels | 0-MAX_SCRIPT_HEIGHT |

---

## setPropertiesFromJSON

**Signature:** `undefined setPropertiesFromJSON(JSON jsonData)`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Minimal Example:** `{obj}.setPropertiesFromJSON({"visible": false, "width": 300});`

**Description:**
Sets multiple component properties at once from a JSON object. Each key in the object is treated as a property name and its value is applied via the standard property setter. This is a convenience method equivalent to calling `set()` for each key-value pair.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| jsonData | JSON | no | A JSON object where each key is a property name and each value is the property value | Keys must be valid property IDs for this component type |

**Cross References:**
- `ScriptFloatingTile.set`
- `ScriptFloatingTile.get`

---

## setStyleSheetClass

**Signature:** `undefined setStyleSheetClass(String classIds)`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Minimal Example:** `{obj}.setStyleSheetClass(".active");`

**Description:**
Sets the CSS class selectors for this component. The component's own type class (derived from the `type` property, lowercased, prefixed with `.`) is automatically prepended. Creates the `ComponentStyleSheetProperties` value tree if it does not yet exist.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| classIds | String | no | Space-separated CSS class selectors to apply | e.g. ".myClass .highlighted" |

**Cross References:**
- `ScriptFloatingTile.setStyleSheetProperty`
- `ScriptFloatingTile.setStyleSheetPseudoState`
- `ScriptFloatingTile.setLocalLookAndFeel`

**Example:**
```javascript
// Add custom classes (component type class is auto-prepended)
knob.setStyleSheetClass(".large .highlighted");
// Result: ".scriptslider .large .highlighted"
```

---

## setStyleSheetProperty

**Signature:** `undefined setStyleSheetProperty(String variableId, NotUndefined value, String type)`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Minimal Example:** `{obj}.setStyleSheetProperty("bg", Colours.red, "color");`

**Description:**
Sets a CSS variable on this component that can be queried from a stylesheet. The `type` parameter determines how the value is converted to a CSS-compatible string. Creates the `ComponentStyleSheetProperties` value tree if it does not yet exist.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| variableId | String | no | The CSS variable name to set; becomes available as a CSS variable in stylesheets | -- |
| value | NotUndefined | no | The value to assign | Type must match the conversion specified by the type parameter |
| type | String | no | The unit/type conversion to apply before storing | See value descriptions below |

**Value Descriptions:**

| Value | Description |
|-------|-------------|
| "path" | Converts a Path object to a base64-encoded string (calls PathObject::toBase64()) |
| "color" | Converts an integer colour to a CSS "#AARRGGBB" string |
| "%" | Converts a number to a percentage string (0.5 becomes "50%") |
| "px" | Converts a number to a pixel value string (10 becomes "10px") |
| "em" | Converts a number to an em value string |
| "vh" | Converts a number to a viewport-height string |
| "deg" | Converts a number to a degree string |
| "" | No conversion -- stores the value as-is |

**Cross References:**
- `ScriptFloatingTile.setStyleSheetClass`
- `ScriptFloatingTile.setStyleSheetPseudoState`
- `ScriptFloatingTile.setLocalLookAndFeel`

**Example:**
```javascript
// Set a colour variable
knob.setStyleSheetProperty("track-color", 0xFFFF0000, "color");

// Set a size variable
knob.setStyleSheetProperty("track-width", 4, "px");

// Set a percentage variable
knob.setStyleSheetProperty("progress", 0.75, "%");
```

---

## setStyleSheetPseudoState

**Signature:** `undefined setStyleSheetPseudoState(String pseudoState)`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Minimal Example:** `{obj}.setStyleSheetPseudoState(":hover");`

**Description:**
Sets one or more CSS pseudo-state selectors on this component. Multiple states can be combined in one string (e.g. `":hover:active"`, `":checked:focus"`). Pass an empty string `""` to clear all pseudo-states. Automatically calls `sendRepaintMessage()` after setting the state.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| pseudoState | String | no | One or more CSS pseudo-state selectors to apply | Can combine multiple states; pass "" to clear |

**Value Descriptions:**

| Value | Description |
|-------|-------------|
| ":first-child" | First child pseudo-class (bitmask 1) |
| ":last-child" | Last child pseudo-class (bitmask 2) |
| ":root" | Root element pseudo-class (bitmask 4) |
| ":hover" | Mouse hover state (bitmask 8) |
| ":active" | Active/pressed state (bitmask 16) |
| ":focus" | Keyboard focus state (bitmask 32) |
| ":disabled" | Disabled state (bitmask 64) |
| ":hidden" | Hidden state (bitmask 128) |
| ":checked" | Checked/toggled state (bitmask 256) |

**Cross References:**
- `ScriptFloatingTile.setStyleSheetClass`
- `ScriptFloatingTile.setStyleSheetProperty`
- `ScriptFloatingTile.setLocalLookAndFeel`

---

## setTooltip

**Signature:** `undefined setTooltip(String tooltip)`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Minimal Example:** `{obj}.setTooltip("Hover text");`

**Description:**
Sets the tooltip text to display on mouse hover.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| tooltip | String | no | The tooltip text to display on mouse hover | -- |

---

## setValueNormalized

**Signature:** `undefined setValueNormalized(Double normalizedValue)`
**Return Type:** `undefined`
**Call Scope:** safe
**Minimal Example:** `{obj}.setValueNormalized(0.5);`

**Description:**
Sets the value using a normalized 0..1 range. The base implementation simply calls `setValue(normalizedValue)`. The behavior changes significantly for ScriptSlider, which maps the normalized 0..1 range to the slider's actual min/max range using its configured mode (linear, frequency, decibel, etc.).

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| normalizedValue | Double | no | A value in the range 0.0 to 1.0 | 0.0 to 1.0 |

**Cross References:**
- `ScriptFloatingTile.getValueNormalized`
- `ScriptFloatingTile.setValue`

---

## setValueWithUndo

**Signature:** `undefined setValueWithUndo(NotUndefined newValue)`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Minimal Example:** `{obj}.setValueWithUndo(0.5);`

**Description:**
Sets the value through the undo manager, creating an `UndoableControlEvent`.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| newValue | NotUndefined | no | The new value to set with undo support | Must not be a String |

**Pitfalls:**
- Do NOT call this from `onControl` callbacks. It is intended for user-initiated value changes that should be undoable.

**Cross References:**
- `ScriptFloatingTile.setValue`

---

## setZLevel

**Signature:** `undefined setZLevel(String zLevel)`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Minimal Example:** `{obj}.setZLevel("AlwaysOnTop");`

**Description:**
Sets the depth level for this component among its siblings. Reports a script error if the value is not one of the four valid strings (case-sensitive). Notifies all z-level listeners when the level changes.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| zLevel | String | no | The depth level for this component among its siblings | Must be one of the four valid values (case-sensitive) |

**Value Descriptions:**

| Value | Description |
|-------|-------------|
| "Back" | Renders behind all sibling components |
| "Default" | Normal rendering order |
| "Front" | Renders in front of normal siblings |
| "AlwaysOnTop" | Always renders on top of all siblings |

---

## showControl

**Signature:** `undefined showControl(Integer shouldBeVisible)`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Minimal Example:** `{obj}.showControl(1);`

**Description:**
Sets the `visible` property with change message notification.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| shouldBeVisible | Integer | no | Whether the component should be visible | 1 = show, 0 = hide |

**Cross References:**
- `ScriptFloatingTile.fadeComponent`

---

## updateValueFromProcessorConnection

**Signature:** `undefined updateValueFromProcessorConnection()`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Minimal Example:** `{obj}.updateValueFromProcessorConnection();`

**Description:**
Reads the current attribute value from the connected processor (set via the `processorId` and `parameterId` properties) and calls `setValue()` with that value. Does nothing if no processor connection is established.

Special parameter index values for the `parameterId` property:
- `-2`: Reads modulation intensity from a Modulation processor
- `-3`: Reads bypass state (1.0 if bypassed, 0.0 if not)
- `-4`: Reads inverted bypass state (0.0 if bypassed, 1.0 if not)
- `>= 0`: Reads the attribute at the given parameter index

**Cross References:**
- `ScriptFloatingTile.setValue`

---

## getValue

**Signature:** `var getValue()`
**Return Type:** `var`
**Call Scope:** safe
**Minimal Example:** `var v = {obj}.getValue();`

**Description:**
Returns the current value of the floating tile. Unlike the ScriptComponent base implementation, this override is a direct field read with no `SimpleReadWriteLock` and no string assertion. The value is whatever was last set via `setValue()` or through the component's internal state.

**Cross References:**
- `ScriptFloatingTile.setValue`
- `ScriptFloatingTile.getValueNormalized`

---

## setValue

**Signature:** `undefined setValue(NotUndefined newValue)`
**Return Type:** `undefined`
**Call Scope:** safe
**Minimal Example:** `{obj}.setValue(0.5);`

**Description:**
Sets the floating tile's value. Unlike the ScriptComponent base implementation, this override is a direct field assignment with no validation, no `triggerAsyncUpdate()`, no linked-component propagation, and no value-listener notification. The value is simply stored.

When the `updateAfterInit` property is `true` (the default), the component wrapper responds to value changes by triggering a complete content reload -- the entire floating tile panel is destroyed and recreated with the current JSON configuration. Set `updateAfterInit` to `false` to prevent this reload behavior.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| newValue | NotUndefined | no | The new value to set | -- |

**Pitfalls:**
- When `updateAfterInit` is true (default), every `setValue()` call triggers a full content reload of the embedded panel. This is expensive and should not be called frequently at runtime.

**Cross References:**
- `ScriptFloatingTile.getValue`
- `ScriptFloatingTile.setContentData`
- `ScriptFloatingTile.setValueNormalized`
- `ScriptFloatingTile.setValueWithUndo`
