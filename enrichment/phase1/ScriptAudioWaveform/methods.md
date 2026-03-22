# ScriptAudioWaveform -- Method Documentation

---

## get [inherited from ScriptComponent]

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

**Property Links:**
- Equivalent: canonical property getter API (`get("<propertyId>")`)
- Related: ScriptComponent.set

**Cross References:**
- `ScriptAudioWaveform.set`
- `ScriptAudioWaveform.getAllProperties`

---

## set [inherited from ScriptComponent]

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

**Property Links:**
- Equivalent: canonical property setter API (`set("<propertyId>", value)`)
- Related: ScriptComponent.get

**Cross References:**
- `ScriptAudioWaveform.get`
- `ScriptAudioWaveform.getAllProperties`

---

## getId [inherited from ScriptComponent]

**Signature:** `String getId()`
**Return Type:** `String`
**Call Scope:** safe
**Minimal Example:** `var id = {obj}.getId();`

**Description:**
Returns the component's ID as a string (the variable name used when creating the component, e.g. `"Knob1"`).

---

## getValue [inherited from ScriptComponent]

**Signature:** `var getValue()`
**Return Type:** `var`
**Call Scope:** safe
**Minimal Example:** `var v = {obj}.getValue();`

**Description:**
Returns the current value of the component. Uses a `SimpleReadWriteLock` for thread-safe read access. Asserts that the value is not a string (strings must not be stored as values).

**Pitfalls:**
- The stored value must not be a String. If it is, an assertion fires in debug builds.

**Cross References:**
- `ScriptAudioWaveform.setValue`
- `ScriptAudioWaveform.getValueNormalized`

**Virtual:** Overridden by ScriptLabel (returns text content), ScriptSliderPack (returns pack data), ScriptFloatingTile (returns floating tile data), ScriptedViewport (returns viewport data), ScriptMultipageDialog (returns `var()`).

---

## setValue [inherited from ScriptComponent]

**Signature:** `undefined setValue(NotUndefined newValue)`
**Return Type:** `undefined`
**Call Scope:** safe
**Minimal Example:** `{obj}.setValue(0.5);`

**Description:**
Sets the component's value. Thread-safe -- can be called from any thread; the UI update happens asynchronously. Propagates the value to all linked component targets. Triggers an async UI update via `triggerAsyncUpdate()`. Sends value listener messages.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| newValue | NotUndefined | no | The new value to set | Must not be a String |

**Pitfalls:**
- Do NOT pass a String value. Reports a script error.
- If called during `onInit`, the value will NOT be restored after recompilation (`skipRestoring` is set to true).

**Property Links:**
- Equivalent: none
- Related: linkedTo

**Interaction Notes:**
- Value propagation can forward to linked components through the `linkedTo` routing setup.

**Cross References:**
- `ScriptAudioWaveform.getValue`
- `ScriptAudioWaveform.setValueNormalized`
- `ScriptAudioWaveform.setValueWithUndo`

**Virtual:** Overridden by ScriptSlider (clamps to range), ScriptLabel, ScriptSliderPack, ScriptedViewport, ScriptFloatingTile, ScriptMultipageDialog (no-op).

---

## setValueNormalized [inherited from ScriptComponent]

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
- `ScriptAudioWaveform.getValueNormalized`
- `ScriptAudioWaveform.setValue`

**Virtual:** Overridden by ScriptSlider.

---

## getValueNormalized [inherited from ScriptComponent]

**Signature:** `Double getValueNormalized()`
**Return Type:** `Double`
**Call Scope:** safe
**Minimal Example:** `var v = {obj}.getValueNormalized();`

**Description:**
Returns the normalized value (0.0 to 1.0). Base implementation returns `getValue()` directly. Only meaningful on ScriptSlider, which maps the actual value back to the 0..1 range.

**Cross References:**
- `ScriptAudioWaveform.setValueNormalized`
- `ScriptAudioWaveform.getValue`

**Virtual:** Overridden by ScriptSlider to map the actual value back to the 0..1 range.

---

## setValueWithUndo [inherited from ScriptComponent]

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

**Property Links:**
- Equivalent: none
- Related: useUndoManager

**Interaction Notes:**
- Undo integration depends on `useUndoManager`; if disabled, undo history integration is not active.

**Cross References:**
- `ScriptAudioWaveform.setValue`

---

## setPosition [inherited from ScriptComponent]

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

**Property Links:**
- Equivalent: none
- Related: set("x", x), set("y", y), set("width", w), set("height", h)

---
## setTooltip [inherited from ScriptComponent]

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

**Property Links:**
- Equivalent: set("tooltip", tooltip)
- Related: get("tooltip")

---
## showControl [inherited from ScriptComponent]

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

**Property Links:**
- Equivalent: none
- Related: set("visible", shouldBeVisible), get("visible")

**Cross References:**
- `ScriptAudioWaveform.fadeComponent`

---

## addToMacroControl [inherited from ScriptComponent]

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

**Property Links:**
- Equivalent: none
- Related: set("macroControl", macroIndex), get("macroControl")

---
## getWidth [inherited from ScriptComponent]

**Signature:** `Integer getWidth()`
**Return Type:** `Integer`
**Call Scope:** safe
**Minimal Example:** `var w = {obj}.getWidth();`

**Description:**
Returns the `width` property as an integer.

**Property Links:**
- Equivalent: get("width")
- Related: set("width", value), setPosition(...)

---
## getHeight [inherited from ScriptComponent]

**Signature:** `Integer getHeight()`
**Return Type:** `Integer`
**Call Scope:** safe
**Minimal Example:** `var h = {obj}.getHeight();`

**Description:**
Returns the `height` property as an integer.

**Property Links:**
- Equivalent: get("height")
- Related: set("height", value), setPosition(...)

---
## getLocalBounds [inherited from ScriptComponent]

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

**Property Links:**
- Equivalent: none
- Related: get("width"), get("height")

---
## getChildComponents [inherited from ScriptComponent]

**Signature:** `Array getChildComponents()`
**Return Type:** `Array`
**Call Scope:** unsafe
**Minimal Example:** `var children = {obj}.getChildComponents();`

**Description:**
Returns an array of ScriptComponent references for all child components (components whose `parentComponent` is set to this component). Does not include the component itself in the result.

---

## changed [inherited from ScriptComponent]

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

**Property Links:**
- Equivalent: none
- Related: deferControlCallback

**Interaction Notes:**
- If `deferControlCallback` is enabled, callback execution is deferred to the message thread.

**Cross References:**
- `ScriptAudioWaveform.setControlCallback`
- `ScriptAudioWaveform.getValue`

**Virtual:** Overridden by ScriptSliderPack and ScriptPanel.

---

## getGlobalPositionX [inherited from ScriptComponent]

**Signature:** `Integer getGlobalPositionX()`
**Return Type:** `Integer`
**Call Scope:** safe
**Minimal Example:** `var x = {obj}.getGlobalPositionX();`

**Description:**
Returns the absolute x-position relative to the interface root, computed by recursively adding parent component x-offsets.

**Property Links:**
- Equivalent: none
- Related: get("x"), get("parentComponent")

**Cross References:**
- `ScriptAudioWaveform.getGlobalPositionY`

---

## getGlobalPositionY [inherited from ScriptComponent]

**Signature:** `Integer getGlobalPositionY()`
**Return Type:** `Integer`
**Call Scope:** safe
**Minimal Example:** `var y = {obj}.getGlobalPositionY();`

**Description:**
Returns the absolute y-position relative to the interface root, computed by recursively adding parent component y-offsets.

**Property Links:**
- Equivalent: none
- Related: get("y"), get("parentComponent")

**Cross References:**
- `ScriptAudioWaveform.getGlobalPositionX`

---

## setControlCallback [inherited from ScriptComponent]

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

**Property Links:**
- Equivalent: none
- Related: processorId, parameterId

**Interaction Notes:**
- If `processorId` and `parameterId` are configured for processor forwarding, this custom callback path is bypassed.

**Cross References:**
- `ScriptAudioWaveform.changed`

**Example:**
```javascript:custom-control-callback
// Title: Route a control callback to a per-component handler
const var btn = Content.addButton("Btn1", 0, 0);
btn.set("saveInPreset", false);

var callbackLog = [];

inline function onMyButton(component, value)
{
    callbackLog.push(component.getId() + ": " + value);
};

btn.setControlCallback(onMyButton);
```

```json:testMetadata:custom-control-callback
{
  "testable": true,
  "verifyScript": [
    {"type": "REPL", "expression": "btn.setValue(1) || btn.changed()", "value": false},
    {"type": "REPL", "expression": "callbackLog[0]", "value": "Btn1: 1"}
  ]
}
```

---

## getAllProperties [inherited from ScriptComponent]

**Signature:** `Array getAllProperties()`
**Return Type:** `Array`
**Call Scope:** unsafe
**Minimal Example:** `var props = {obj}.getAllProperties();`

**Description:**
Returns an array of strings containing all active (non-deactivated) property IDs for this component. Includes both base ScriptComponent properties and any child-class-specific properties.

**Cross References:**
- `ScriptAudioWaveform.get`
- `ScriptAudioWaveform.set`

---

## setKeyPressCallback [inherited from ScriptComponent]

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
- `ScriptAudioWaveform.setConsumedKeyPresses`

**Example:**
```javascript:key-press-handler
// Title: Log key presses on a focused panel
const var panel = Content.addPanel("Panel1", 0, 0);
panel.setConsumedKeyPresses("all");
panel.setKeyPressCallback(inline function(event)
{
    if (!event.isFocusChange)
        Console.print("Key: " + event.description);
});

// --- test-only ---
Console.testCallback(panel, "setKeyPressCallback", {
    "isFocusChange": false,
    "character": "A",
    "specialKey": false,
    "keyCode": 65,
    "description": "A"
});
// --- end test-only ---
```

```json:testMetadata:key-press-handler
{
  "testable": true,
  "verifyScript": {"type": "log-output", "values": ["Key: A"]}
}
```

---

## setConsumedKeyPresses [inherited from ScriptComponent]

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
- `ScriptAudioWaveform.setKeyPressCallback`

**Example:**
```javascript:consumed-key-formats
// Title: Three ways to specify consumed key presses
const var panel = Content.addPanel("Panel1", 0, 0);

// Consume all keys exclusively
panel.setConsumedKeyPresses("all");

// Consume specific keys by description string
panel.setConsumedKeyPresses(["ctrl + S", "F5", "escape"]);

// Consume specific keys by JSON object
panel.setConsumedKeyPresses([
    { "keyCode": 65, "ctrl": true },
    { "keyCode": 83, "ctrl": true }
]);

// Verify by registering a callback (would error if keys weren't consumed)
var keyLog = [];
panel.setKeyPressCallback(inline function(event)
{
    if (!event.isFocusChange)
        keyLog.push(event.keyCode);
});

// --- test-only ---
Console.testCallback(panel, "setKeyPressCallback", {
    "isFocusChange": false,
    "character": "A",
    "specialKey": false,
    "keyCode": 65,
    "description": "A"
});
// --- end test-only ---
```

```json:testMetadata:consumed-key-formats
{
  "testable": true,
  "verifyScript": {"type": "REPL", "expression": "keyLog[0]", "value": 65}
}
```

---

## loseFocus [inherited from ScriptComponent]

**Signature:** `undefined loseFocus()`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Minimal Example:** `{obj}.loseFocus();`

**Description:**
Notifies all z-level listeners that the component wants to lose keyboard focus. Triggers the `wantsToLoseFocus()` callback on all registered `ZLevelListener` instances.

**Cross References:**
- `ScriptAudioWaveform.grabFocus`

---

## grabFocus [inherited from ScriptComponent]

**Signature:** `undefined grabFocus()`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Minimal Example:** `{obj}.grabFocus();`

**Description:**
Notifies z-level listeners that the component wants to grab keyboard focus. Only notifies the first listener (exclusive operation).

**Cross References:**
- `ScriptAudioWaveform.loseFocus`

---

## setZLevel [inherited from ScriptComponent]

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

## setLocalLookAndFeel [inherited from ScriptComponent]

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
- `ScriptAudioWaveform.setStyleSheetClass`
- `ScriptAudioWaveform.setStyleSheetProperty`
- `ScriptAudioWaveform.setStyleSheetPseudoState`

---

## sendRepaintMessage [inherited from ScriptComponent]

**Signature:** `undefined sendRepaintMessage()`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Minimal Example:** `{obj}.sendRepaintMessage();`

**Description:**
Sends an asynchronous repaint message via `repaintBroadcaster`. This is useful when you've changed visual properties programmatically and need to force a UI redraw.

**Virtual:** Overridden by ScriptPanel (which calls its own `repaint()`) and ScriptDynamicContainer.

---

## fadeComponent [inherited from ScriptComponent]

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

**Property Links:**
- Equivalent: none
- Related: set("visible", shouldBeVisible), get("visible")

**Cross References:**
- `ScriptAudioWaveform.showControl`

---

## setStyleSheetProperty [inherited from ScriptComponent]

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
- `ScriptAudioWaveform.setStyleSheetClass`
- `ScriptAudioWaveform.setStyleSheetPseudoState`
- `ScriptAudioWaveform.setLocalLookAndFeel`

**Example:**
```javascript:css-variable-types
// Title: Set CSS variables with different unit types
const var knob = Content.addKnob("Knob1", 0, 0);
const var laf = Content.createLocalLookAndFeel();
knob.setLocalLookAndFeel(laf);

// Set a colour variable
knob.setStyleSheetProperty("track-color", 0xFFFF0000, "color");

// Set a size variable
knob.setStyleSheetProperty("track-width", 4, "px");

// Set a percentage variable
knob.setStyleSheetProperty("progress", 0.75, "%");
```

```json:testMetadata:css-variable-types
{
  "testable": true,
  "verifyScript": {"type": "REPL", "expression": "knob.getWidth()", "value": 128}
}
```

---

## setStyleSheetClass [inherited from ScriptComponent]

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
- `ScriptAudioWaveform.setStyleSheetProperty`
- `ScriptAudioWaveform.setStyleSheetPseudoState`
- `ScriptAudioWaveform.setLocalLookAndFeel`

**Example:**
```javascript:css-class-selectors
// Title: Assign CSS class selectors to a component
const var knob = Content.addKnob("Knob1", 0, 0);
const var laf = Content.createLocalLookAndFeel();
knob.setLocalLookAndFeel(laf);

// Add custom classes (component type class is auto-prepended)
knob.setStyleSheetClass(".large .highlighted");
// Result: ".scriptslider .large .highlighted"
```

```json:testMetadata:css-class-selectors
{
  "testable": true,
  "verifyScript": {"type": "REPL", "expression": "knob.getWidth()", "value": 128}
}
```

---

## setStyleSheetPseudoState [inherited from ScriptComponent]

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
- `ScriptAudioWaveform.setStyleSheetClass`
- `ScriptAudioWaveform.setStyleSheetProperty`
- `ScriptAudioWaveform.setLocalLookAndFeel`

---

## updateValueFromProcessorConnection [inherited from ScriptComponent]

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

**Property Links:**
- Equivalent: none
- Related: get("processorId"), get("parameterId"), setValue(...)

**Cross References:**
- `ScriptAudioWaveform.setValue`

---

## setPropertiesFromJSON [inherited from ScriptComponent]

**Disabled:** redundant
**Disabled Reason:** This method is declared in the ScriptComponent header but is NOT registered as a direct API method on component instances. It is exposed on the Content object as `Content.setPropertiesFromJSON(componentName, jsonData)`.

---

## getRangeStart

**Signature:** `Integer getRangeStart()`
**Return Type:** `Integer`
**Call Scope:** safe
**Minimal Example:** `var start = {obj}.getRangeStart();`

**Description:**
Returns the start position (in samples) of the currently selected sample range on the waveform display. If no audio data is loaded or the cached audio file reference is invalid, returns `0`. The range is typically set by user interaction with the draggable SampleArea edges or programmatically via the underlying MultiChannelAudioBuffer.

**Property Links:**
- Equivalent: none
- Related: enableRange

**Cross References:**
- `ScriptAudioWaveform.getRangeEnd`

---

## getRangeEnd

**Signature:** `Integer getRangeEnd()`
**Return Type:** `Integer`
**Call Scope:** safe
**Minimal Example:** `var end = {obj}.getRangeEnd();`

**Description:**
Returns the end position (in samples) of the currently selected sample range on the waveform display. If no audio data is loaded or the cached audio file reference is invalid, returns `0`. The range is typically set by user interaction with the draggable SampleArea edges or programmatically via the underlying MultiChannelAudioBuffer.

**Property Links:**
- Equivalent: none
- Related: enableRange

**Cross References:**
- `ScriptAudioWaveform.getRangeStart`

---

## referToData

**Signature:** `undefined referToData(ScriptObject audioData)`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Minimal Example:** `{obj}.referToData(myAudioFile);`

**Description:**
Connects this waveform component to an external audio data source. After calling this method, the waveform displays the audio data from the referenced source instead of its own internal buffer. Accepts three argument types:

- A `ScriptAudioFile` object (from `Engine.createAndRegisterAudioFile()` or `registerAtParent()`) -- connects to the audio file handle's data
- Another `ScriptAudioWaveform` component -- shares the same data source as that component
- The integer `-1` -- resets to the component's own internal audio buffer

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| audioData | ScriptObject | no | A ScriptAudioFile handle, another ScriptAudioWaveform, or -1 to reset | Must be a valid data reference or -1 |

**Pitfalls:**
- [BUG] Passing an object that is neither a ScriptAudioFile, a ComplexDataScriptComponent, nor `-1` silently does nothing -- no error is reported and the data source is unchanged.

**Property Links:**
- Equivalent: none
- Related: processorId, sampleIndex source binding

**Cross References:**
- `ScriptAudioWaveform.registerAtParent`

**Example:**
```javascript:referToData-audio-file
// Title: Connect waveform to a ScriptAudioFile handle
const var wf = Content.addAudioWaveform("Waveform1", 0, 0);
const var af = Engine.createAndRegisterAudioFile(0);
wf.referToData(af);
```

```json:testMetadata:referToData-audio-file
{
  "testable": true,
  "verifyScript": [
    {"type": "REPL", "expression": "af.getNumSamples()", "value": 0},
    {"type": "REPL", "expression": "wf.getRangeEnd()", "value": 0}
  ]
}
```

---

## registerAtParent

**Signature:** `ScriptObject registerAtParent(Integer index)`
**Return Type:** `ScriptObject`
**Call Scope:** unsafe
**Minimal Example:** `var af = {obj}.registerAtParent(0);`

**Description:**
Registers this component's internal audio data with the parent script processor at the given slot index, making it accessible from scriptnode or external code. Returns a `ScriptAudioFile` handle that can be used to programmatically load, query, and manipulate the audio data. The returned handle references the same audio buffer as this waveform component.

If the parent processor is not a `ProcessorWithDynamicExternalData`, returns an undefined value.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| index | Integer | no | The slot index to register at in the parent processor | >= 0 |

**Cross References:**
- `ScriptAudioWaveform.referToData`

**Example:**
```javascript:registerAtParent-usage
// Title: Register waveform data at parent and get audio file handle
const var wf = Content.addAudioWaveform("Waveform1", 0, 0);
const var af = wf.registerAtParent(0);
```

```json:testMetadata:registerAtParent-usage
{
  "testable": true,
  "verifyScript": {"type": "REPL", "expression": "af.getNumSamples()", "value": 0}
}
```

---

## setDefaultFolder

**Signature:** `undefined setDefaultFolder(ScriptObject newDefaultFolder)`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Minimal Example:** `{obj}.setDefaultFolder(FileSystem.getFolder(FileSystem.Documents));`

**Description:**
Sets the default root directory for the file browser that opens when the user clicks on the waveform to load an audio file. The argument must be a `File` object obtained from `FileSystem.getFolder()` or similar File API calls. Passing a string path instead of a File object causes a script error.

This only affects AudioFile mode. In Sampler mode (when connected to a ModulatorSampler), the file browser is not used.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| newDefaultFolder | ScriptObject | no | A File object representing the target directory | Must be a ScriptFile object |

**Pitfalls:**
- Passing a string path instead of a File object causes a script error: "newDefaultFolder must be a File object". Use `FileSystem.getFolder()` or equivalent to obtain a File object.
- If no audio file is loaded (the cached audio file is null), the call silently does nothing.

**Cross References:**
- `ScriptAudioWaveform.referToData`
- `FileSystem.getFolder`

---

## setPlaybackPosition

**Signature:** `undefined setPlaybackPosition(Double normalisedPosition)`
**Return Type:** `undefined`
**Call Scope:** safe
**Minimal Example:** `{obj}.setPlaybackPosition(0.5);`

**Description:**
Moves the playback cursor displayed on the waveform to the given normalized position. The position is a value from 0.0 to 1.0 representing the fraction of the current sample range. The position is converted to a sample index relative to the current range length and sent as an asynchronous display change message through the ComplexDataUIUpdater.

This is a display-only method -- it does not affect actual audio playback. It is used to visually indicate the current playback position by driving the waveform's playback indicator from script (e.g. from a timer callback tracking a player's position).

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| normalisedPosition | Double | no | The playback position as a fraction of the current range | 0.0 to 1.0 |

**Pitfalls:**
- If no audio data is loaded (the cached audio file is null), the call silently does nothing.

**Cross References:**
- `ScriptAudioWaveform.getRangeStart`
- `ScriptAudioWaveform.getRangeEnd`

---
