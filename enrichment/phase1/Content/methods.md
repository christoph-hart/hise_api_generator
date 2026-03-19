# Content -- Method Documentation

## addVisualGuide

**Signature:** `undefined addVisualGuide(var guideData, var colour)`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Call Scope Note:** Iterates screenshotListeners and may trigger repaint operations.
**Minimal Example:** `Content.addVisualGuide([100, 0], Colours.red);`

**Description:**
Adds a visual overlay guide (line or rectangle) for layout debugging. Pass a 4-element array `[x, y, w, h]` for a rectangle, a 2-element array `[0, y]` for a horizontal line at y, or `[x, 0]` for a vertical line at x. Passing any non-array value (e.g., `0`) clears all existing guides. The colour parameter sets the guide's display colour.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| guideData | Array | no | Array defining the guide shape, or non-array to clear all guides | `[x,y,w,h]` for rect, `[0,y]` for h-line, `[x,0]` for v-line |
| colour | Colour | no | Display colour for the guide | 0xAARRGGBB or Colours constant |

**Pitfalls:**
- [BUG] A 2-element array with both values non-zero (e.g., `[50, 100]`) does not create any guide -- neither the horizontal nor vertical code path matches, and the VisualGuide is added with an uninitialized type and default area.

**Cross References:**
- `Content.createScreenshot`

**Example:**
```javascript:visual-guide-types
// Title: Adding different types of visual guides
// Add a horizontal line at y=100
Content.addVisualGuide([0, 100], Colours.red);

// Add a vertical line at x=200
Content.addVisualGuide([200, 0], Colours.blue);

// Add a rectangle guide
Content.addVisualGuide([10, 10, 300, 200], 0x4400FF00);

// Clear all guides
Content.addVisualGuide(0, 0);
```
```json:testMetadata:visual-guide-types
{
  "testable": false,
  "skipReason": "Visual guides are display-only overlays with no queryable state"
}
```

## callAfterDelay

**Signature:** `undefined callAfterDelay(int milliSeconds, Function function, var thisObject)`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Call Scope Note:** Creates a WeakCallbackHolder (heap allocation) and schedules a JUCE Timer callback on the message thread.
**Minimal Example:** `Content.callAfterDelay(500, onDelayedAction);`

**Description:**
Schedules a function to execute after the specified delay in milliseconds. The callback runs on the message thread via JUCE's Timer system, which is not sample-accurate -- do not use for DSP timing. An optional third argument sets the `this` context for the callback. The callback takes no arguments.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| milliSeconds | Integer | no | Delay before execution in milliseconds | > 0 |
| function | Function | no | Callback to execute after the delay | Takes 0 arguments |
| thisObject | ScriptObject | no | Optional `this` context for the callback | -- |

**Callback Signature:** function()

**Pitfalls:**
- The callback fires on the message thread, not the audio thread. It is not sample-accurate and should not be used for musical timing.
- The third parameter (thisObject) is optional in the wrapper (defaults to empty var if only 2 args are passed).
- [BUG] The wrapper returns `isMouseDown()` instead of undefined due to a copy-paste error. The method is void but script callers receive a spurious integer (0, 1, or 2).

**Cross References:**
- `Engine.createTimerObject`

**Example:**
```javascript:delayed-action
// Title: Execute a function after a delay
Content.makeFrontInterface(600, 300);

inline function onDelayedAction()
{
    Console.print("Executed after delay");
};

Content.callAfterDelay(200, onDelayedAction);
```
```json:testMetadata:delayed-action
{
  "testable": false,
  "skipReason": "Async timer callback fires after compile response is returned; log-output verification cannot capture deferred Console.print output"
}
```

## createLocalLookAndFeel

**Signature:** `ScriptLookAndFeel createLocalLookAndFeel()`
**Return Type:** `ScriptObject`
**Call Scope:** unsafe
**Call Scope Note:** Heap-allocates a ScriptedLookAndFeel object and registers debug info listeners in backend builds.
**Minimal Example:** `var laf = Content.createLocalLookAndFeel();`

**Description:**
Creates a local Look and Feel object that can be used to customize the appearance of individual UI components. The created LAF is "local" (not global) -- it only applies to components that have it explicitly assigned via `component.setLocalLookAndFeel(laf)`. Register drawing functions on the returned object with `laf.registerFunction()`.

**Parameters:**

(No parameters.)

**Cross References:**
- `ScriptLookAndFeel.registerFunction`
- `ScriptComponent.setLocalLookAndFeel`
- `Engine.createGlobalScriptLookAndFeel`
- `Content.createMarkdownRenderer`

**Example:**
```javascript:local-laf-button
// Title: Creating a local LAF for a button
Content.makeFrontInterface(600, 300);

const var btn = Content.addButton("MyButton", 10, 10);

const var laf = Content.createLocalLookAndFeel();

laf.registerFunction("drawToggleButton", function(g, obj)
{
    g.fillAll(obj.value ? Colours.green : Colours.red);
    g.setColour(Colours.white);
    g.drawAlignedText(obj.text, [0, 0, obj.area[2], obj.area[3]], "centred");
});

btn.setLocalLookAndFeel(laf);
```
```json:testMetadata:local-laf-button
{
  "testable": false,
  "skipReason": "LAF rendering requires visual component display, cannot be verified via REPL"
}
```

## createMarkdownRenderer

**Signature:** `MarkdownRenderer createMarkdownRenderer()`
**Return Type:** `ScriptObject`
**Call Scope:** unsafe
**Call Scope Note:** Heap-allocates a MarkdownObject.
**Minimal Example:** `var md = Content.createMarkdownRenderer();`

**Description:**
Creates a MarkdownRenderer object for rendering markdown text in ScriptPanel paint routines. After creation, call `setTextBounds()` to define the rendering area, then `setText()` to set the content, and pass the renderer to `Graphics.drawMarkdownText()` inside a paint routine.

**Parameters:**

(No parameters.)

**Cross References:**
- `MarkdownRenderer.setText`
- `MarkdownRenderer.setTextBounds`
- `Graphics.drawMarkdownText`
- `Content.createLocalLookAndFeel`

## createPath

**Signature:** `Path createPath()`
**Return Type:** `ScriptObject`
**Call Scope:** unsafe
**Call Scope Note:** Heap-allocates a PathObject.
**Minimal Example:** `var p = Content.createPath();`

**Description:**
Creates a new Path object for vector drawing. Use Path methods like `startNewSubPath()`, `lineTo()`, `quadraticTo()`, `cubicTo()` to define the shape, then use it with `Graphics.fillPath()` or `Graphics.drawPath()` inside paint routines. Paths can also be loaded from base64 data via `Path.loadFromData()`.

**Parameters:**

(No parameters.)

**Cross References:**
- `Path.startNewSubPath`
- `Path.lineTo`
- `Graphics.fillPath`
- `Graphics.drawPath`
- `Content.createSVG`
- `Content.createShader`

## createScreenshot

**Signature:** `undefined createScreenshot(var area, ScriptObject directory, String name)`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Call Scope Note:** Blocking operation -- waits for all screenshot listeners (shaders, etc.) to be ready, involves file I/O.
**Minimal Example:** `Content.createScreenshot(myPanel, myDir, "screenshot");`

**Description:**
Creates a PNG screenshot of a specified area and saves it to a directory. The `area` parameter can be either a ScriptComponent reference (captures that component's global bounds) or a `[x, y, w, h]` array for arbitrary coordinates. The `directory` must be a ScriptFile object pointing to a directory (created if it does not exist). The `name` parameter is the file name (`.png` extension added automatically). This method blocks until all screenshot listeners (e.g., shaders) are ready.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| area | Object | no | Component reference or [x,y,w,h] array defining the capture area | -- |
| directory | ScriptObject | no | ScriptFile pointing to a target directory | Must be a directory |
| name | String | no | Output file name (without extension) | .png added automatically |

**Pitfalls:**
- Does nothing if no screenshot listeners are registered (the `screenshotListeners` array is empty). This typically means no shaders or visual elements that support screenshots are active.

**Cross References:**
- `Content.addVisualGuide`
- `FileSystem.getFolder`

## createShader

**Signature:** `ScriptShader createShader(String fileName)`
**Return Type:** `ScriptObject`
**Call Scope:** unsafe
**Call Scope Note:** Heap-allocates a ScriptShader object and registers it as a screenshot listener.
**Minimal Example:** `var shader = Content.createShader("myShader");`

**Description:**
Creates a ScriptShader object for GLSL-based rendering in ScriptPanels. If `fileName` is not empty, the fragment shader file is loaded from the project's shader folder. Pass an empty string to create a shader without loading a file immediately. The shader is automatically registered as a screenshot listener.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| fileName | String | no | Fragment shader filename (from the project's shader folder) | Empty string to skip loading |

**Cross References:**
- `ScriptShader.setFragmentShader`
- `ScriptPanel.setShader`
- `Content.createPath`
- `Content.createSVG`

## createSVG

**Signature:** `ScriptObject createSVG(String base64Data)`
**Return Type:** `ScriptObject`
**Call Scope:** unsafe
**Call Scope Note:** Heap-allocates an SVGObject, decompresses base64/zstd data, and parses XML asynchronously.
**Minimal Example:** `var svg = Content.createSVG(svgData);`

**Description:**
Creates an SVG object from base64-encoded, zstd-compressed SVG data. The encoded string should contain the compressed SVG XML. The SVG is parsed asynchronously on the message thread. Use the returned object with `Graphics.drawSVG()` in paint routines. The SVG data is typically generated by the HISE SVG tools.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| base64Data | String | no | Base64-encoded zstd-compressed SVG XML data | Must be valid base64 |

**Pitfalls:**
- The SVG parsing happens asynchronously (SafeAsyncCall). The SVG object may not be immediately valid after creation -- the drawable is set on the message thread after XML parsing completes.

**Cross References:**
- `Graphics.drawSVG`
- `Content.createPath`
- `Content.createShader`

## getAllComponents

**Signature:** `Array getAllComponents(String regex)`
**Return Type:** `Array`
**Call Scope:** unsafe
**Call Scope Note:** Iterates all components and performs regex matching (String operations).
**Minimal Example:** `var comps = Content.getAllComponents("Knob.*");`

**Description:**
Returns an array of all component references whose names match the given regex pattern. Pass `".*"` to get all components (uses an optimized path that skips regex matching). The regex uses wildcard matching via `RegexFunctions::matchesWildcard()`.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| regex | String | no | Regex pattern to match component names | ".*" for all |

**Cross References:**
- `Content.getComponent`
- `Content.componentExists`

## addDynamicContainer

**Signature:** `ScriptDynamicContainer addDynamicContainer(String containerId, int x, int y)`
**Return Type:** `ScriptDynamicContainer`
**Call Scope:** init
**Minimal Example:** `var dc = Content.addDynamicContainer("Container1", 0, 0);`

**Description:**
Creates a ScriptDynamicContainer component (a layout container that dynamically manages child components) and adds it to the interface. Accepts either 1 argument (name only, position defaults to 0,0) or 3 arguments (name, x, y). If a component with the same name already exists, the existing component is returned and its position is optionally updated. This idempotent behavior makes the call safe across recompiles. Can only be called during onInit -- calling after initialization throws a script error.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| containerId | String | no | Unique name for the component (also used as its ID) | No whitespace |
| x | Integer | no | Horizontal position in pixels | >= 0 (clamped via jmax) |
| y | Integer | no | Vertical position in pixels | >= 0 (clamped via jmax) |

**Pitfalls:**
- Calling this method after onInit throws "Tried to add a component after onInit()". All component creation must happen during onInit.

**Cross References:**
- `Content.getComponent`
- `Content.componentExists`

## addButton

**Signature:** `ScriptButton addButton(String buttonName, int x, int y)`
**Return Type:** `ScriptButton`
**Call Scope:** init
**Minimal Example:** `var btn = Content.addButton("MyButton", 10, 10);`

**Description:**
Creates a ScriptButton (toggle button) component and adds it to the interface. Accepts either 1 argument (name only, position defaults to 0,0) or 3 arguments (name, x, y). If a component with the same name already exists, the existing component is returned and its position is optionally updated. This idempotent behavior makes the call safe across recompiles. Can only be called during onInit -- calling after initialization throws a script error.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| buttonName | String | no | Unique name for the component (also used as its ID) | No whitespace |
| x | Integer | no | Horizontal position in pixels | >= 0 (clamped via jmax) |
| y | Integer | no | Vertical position in pixels | >= 0 (clamped via jmax) |

**Pitfalls:**
- Calling this method after onInit throws "Tried to add a component after onInit()". All component creation must happen during onInit.

**Cross References:**
- `Content.getComponent`
- `Content.componentExists`

**Example:**
```javascript:add-button-basic
// Title: Creating buttons with idempotent naming
const var btn1 = Content.addButton("BypassBtn", 10, 10);
const var btn2 = Content.addButton("BypassBtn", 10, 10);
Console.assertTrue(btn1 == btn2);
```
```json:testMetadata:add-button-basic
{
  "testable": true,
  "verifyScript": {"type": "REPL", "expression": "btn1 == btn2", "value": true}
}
```

## addComboBox

**Signature:** `ScriptComboBox addComboBox(String boxName, int x, int y)`
**Return Type:** `ScriptComboBox`
**Call Scope:** init
**Minimal Example:** `var cb = Content.addComboBox("ModeSelector", 10, 10);`

**Description:**
Creates a ScriptComboBox (dropdown selector) component and adds it to the interface. Accepts either 1 argument (name only, position defaults to 0,0) or 3 arguments (name, x, y). If a component with the same name already exists, the existing component is returned and its position is optionally updated. This idempotent behavior makes the call safe across recompiles. Can only be called during onInit -- calling after initialization throws a script error.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| boxName | String | no | Unique name for the component (also used as its ID) | No whitespace |
| x | Integer | no | Horizontal position in pixels | >= 0 (clamped via jmax) |
| y | Integer | no | Vertical position in pixels | >= 0 (clamped via jmax) |

**Pitfalls:**
- Calling this method after onInit throws "Tried to add a component after onInit()". All component creation must happen during onInit.

**Cross References:**
- `Content.getComponent`
- `Content.componentExists`

## addFloatingTile

**Signature:** `ScriptFloatingTile addFloatingTile(String floatingTileName, int x, int y)`
**Return Type:** `ScriptFloatingTile`
**Call Scope:** init
**Minimal Example:** `var ft = Content.addFloatingTile("PresetBrowser", 10, 10);`

**Description:**
Creates a ScriptFloatingTile component (an embedded floating tile for preset browsers, keyboards, and other built-in widgets) and adds it to the interface. Accepts either 1 argument (name only, position defaults to 0,0) or 3 arguments (name, x, y). If a component with the same name already exists, the existing component is returned and its position is optionally updated. This idempotent behavior makes the call safe across recompiles. Can only be called during onInit -- calling after initialization throws a script error.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| floatingTileName | String | no | Unique name for the component (also used as its ID) | No whitespace |
| x | Integer | no | Horizontal position in pixels | >= 0 (clamped via jmax) |
| y | Integer | no | Vertical position in pixels | >= 0 (clamped via jmax) |

**Pitfalls:**
- Calling this method after onInit throws "Tried to add a component after onInit()". All component creation must happen during onInit.

**Cross References:**
- `Content.getComponent`
- `Content.componentExists`

## addImage

**Signature:** `ScriptImage addImage(String imageName, int x, int y)`
**Return Type:** `ScriptImage`
**Call Scope:** init
**Minimal Example:** `var img = Content.addImage("Logo", 10, 10);`

**Description:**
Creates a ScriptImage component (a static image display) and adds it to the interface. Accepts either 1 argument (name only, position defaults to 0,0) or 3 arguments (name, x, y). If a component with the same name already exists, the existing component is returned and its position is optionally updated. This idempotent behavior makes the call safe across recompiles. Can only be called during onInit -- calling after initialization throws a script error.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| imageName | String | no | Unique name for the component (also used as its ID) | No whitespace |
| x | Integer | no | Horizontal position in pixels | >= 0 (clamped via jmax) |
| y | Integer | no | Vertical position in pixels | >= 0 (clamped via jmax) |

**Pitfalls:**
- Calling this method after onInit throws "Tried to add a component after onInit()". All component creation must happen during onInit.

**Cross References:**
- `Content.getComponent`
- `Content.componentExists`

## addKnob

**Signature:** `ScriptSlider addKnob(String knobName, int x, int y)`
**Return Type:** `ScriptSlider`
**Call Scope:** init
**Minimal Example:** `var knob = Content.addKnob("Volume", 10, 10);`

**Description:**
Creates a ScriptSlider component (rotary knob or linear slider, depending on the `mode` property) and adds it to the interface. Despite the method name, this creates a ScriptSlider object -- the name `addKnob` reflects the default rotary appearance. Accepts either 1 argument (name only, position defaults to 0,0) or 3 arguments (name, x, y). If a component with the same name already exists, the existing component is returned and its position is optionally updated. This idempotent behavior makes the call safe across recompiles. Can only be called during onInit -- calling after initialization throws a script error.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| knobName | String | no | Unique name for the component (also used as its ID) | No whitespace |
| x | Integer | no | Horizontal position in pixels | >= 0 (clamped via jmax) |
| y | Integer | no | Vertical position in pixels | >= 0 (clamped via jmax) |

**Pitfalls:**
- Calling this method after onInit throws "Tried to add a component after onInit()". All component creation must happen during onInit.

**Cross References:**
- `Content.getComponent`
- `Content.componentExists`

**Example:**
```javascript:add-knob-basic
// Title: Creating knobs and accessing the returned reference
Content.makeFrontInterface(600, 300);
const var vol = Content.addKnob("VolKn", 10, 10);
vol.setRange(0.0, 1.0, 0.01);
vol.set("defaultValue", 0.75);
```
```json:testMetadata:add-knob-basic
{
  "testable": true,
  "verifyScript": {"type": "REPL", "expression": "vol.getRange().max", "value": 1.0}
}
```

## addLabel

**Signature:** `ScriptLabel addLabel(String label, int x, int y)`
**Return Type:** `ScriptLabel`
**Call Scope:** init
**Minimal Example:** `var lbl = Content.addLabel("StatusText", 10, 10);`

**Description:**
Creates a ScriptLabel component (a text input/display label) and adds it to the interface. Accepts either 1 argument (name only, position defaults to 0,0) or 3 arguments (name, x, y). If a component with the same name already exists, the existing component is returned and its position is optionally updated. This idempotent behavior makes the call safe across recompiles. Can only be called during onInit -- calling after initialization throws a script error.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| label | String | no | Unique name for the component (also used as its ID) | No whitespace |
| x | Integer | no | Horizontal position in pixels | >= 0 (clamped via jmax) |
| y | Integer | no | Vertical position in pixels | >= 0 (clamped via jmax) |

**Pitfalls:**
- Calling this method after onInit throws "Tried to add a component after onInit()". All component creation must happen during onInit.

**Cross References:**
- `Content.getComponent`
- `Content.componentExists`

## addMultipageDialog

**Signature:** `ScriptMultipageDialog addMultipageDialog(String dialogId, int x, int y)`
**Return Type:** `ScriptMultipageDialog`
**Call Scope:** init
**Minimal Example:** `var dlg = Content.addMultipageDialog("InstallerDialog", 10, 10);`

**Description:**
Creates a ScriptMultipageDialog component (a multi-page dialog for installers, setup wizards, etc.) and adds it to the interface. Accepts either 1 argument (name only, position defaults to 0,0) or 3 arguments (name, x, y). If a component with the same name already exists, the existing component is returned and its position is optionally updated. This idempotent behavior makes the call safe across recompiles. Can only be called during onInit -- calling after initialization throws a script error.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| dialogId | String | no | Unique name for the component (also used as its ID) | No whitespace |
| x | Integer | no | Horizontal position in pixels | >= 0 (clamped via jmax) |
| y | Integer | no | Vertical position in pixels | >= 0 (clamped via jmax) |

**Pitfalls:**
- Calling this method after onInit throws "Tried to add a component after onInit()". All component creation must happen during onInit.

**Cross References:**
- `Content.getComponent`
- `Content.componentExists`

## addPanel

**Signature:** `ScriptPanel addPanel(String panelName, int x, int y)`
**Return Type:** `ScriptPanel`
**Call Scope:** init
**Minimal Example:** `var pnl = Content.addPanel("BackgroundPanel", 0, 0);`

**Description:**
Creates a ScriptPanel component (a drawable panel with paint routines and mouse callbacks) and adds it to the interface. ScriptPanel is the most versatile component type -- it supports custom paint routines, mouse/key event callbacks, animation timers, drag-and-drop, and child component parenting. Accepts either 1 argument (name only, position defaults to 0,0) or 3 arguments (name, x, y). If a component with the same name already exists, the existing component is returned and its position is optionally updated. This idempotent behavior makes the call safe across recompiles. Can only be called during onInit -- calling after initialization throws a script error.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| panelName | String | no | Unique name for the component (also used as its ID) | No whitespace |
| x | Integer | no | Horizontal position in pixels | >= 0 (clamped via jmax) |
| y | Integer | no | Vertical position in pixels | >= 0 (clamped via jmax) |

**Pitfalls:**
- Calling this method after onInit throws "Tried to add a component after onInit()". All component creation must happen during onInit.

**Cross References:**
- `Content.getComponent`
- `Content.componentExists`

## addSliderPack

**Signature:** `ScriptSliderPack addSliderPack(String sliderPackName, int x, int y)`
**Return Type:** `ScriptSliderPack`
**Call Scope:** init
**Minimal Example:** `var sp = Content.addSliderPack("EQBands", 10, 10);`

**Description:**
Creates a ScriptSliderPack component (an array of sliders for multi-value editing like EQ bands or step sequencers) and adds it to the interface. Accepts either 1 argument (name only, position defaults to 0,0) or 3 arguments (name, x, y). If a component with the same name already exists, the existing component is returned and its position is optionally updated. This idempotent behavior makes the call safe across recompiles. Can only be called during onInit -- calling after initialization throws a script error.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| sliderPackName | String | no | Unique name for the component (also used as its ID) | No whitespace |
| x | Integer | no | Horizontal position in pixels | >= 0 (clamped via jmax) |
| y | Integer | no | Vertical position in pixels | >= 0 (clamped via jmax) |

**Pitfalls:**
- Calling this method after onInit throws "Tried to add a component after onInit()". All component creation must happen during onInit.

**Cross References:**
- `Content.getComponent`
- `Content.componentExists`

## addTable

**Signature:** `ScriptTable addTable(String tableName, int x, int y)`
**Return Type:** `ScriptTable`
**Call Scope:** init
**Minimal Example:** `var tbl = Content.addTable("VelocityCurve", 10, 10);`

**Description:**
Creates a ScriptTable component (a curve editor for mapping tables) and adds it to the interface. Accepts either 1 argument (name only, position defaults to 0,0) or 3 arguments (name, x, y). If a component with the same name already exists, the existing component is returned and its position is optionally updated. This idempotent behavior makes the call safe across recompiles. Can only be called during onInit -- calling after initialization throws a script error.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| tableName | String | no | Unique name for the component (also used as its ID) | No whitespace |
| x | Integer | no | Horizontal position in pixels | >= 0 (clamped via jmax) |
| y | Integer | no | Vertical position in pixels | >= 0 (clamped via jmax) |

**Pitfalls:**
- Calling this method after onInit throws "Tried to add a component after onInit()". All component creation must happen during onInit.

**Cross References:**
- `Content.getComponent`
- `Content.componentExists`

## addViewport

**Signature:** `ScriptedViewport addViewport(String viewportName, int x, int y)`
**Return Type:** `ScriptedViewport`
**Call Scope:** init
**Minimal Example:** `var vp = Content.addViewport("ScrollArea", 10, 10);`

**Description:**
Creates a ScriptedViewport component (a scrollable viewport for child content) and adds it to the interface. Accepts either 1 argument (name only, position defaults to 0,0) or 3 arguments (name, x, y). If a component with the same name already exists, the existing component is returned and its position is optionally updated. This idempotent behavior makes the call safe across recompiles. Can only be called during onInit -- calling after initialization throws a script error.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| viewportName | String | no | Unique name for the component (also used as its ID) | No whitespace |
| x | Integer | no | Horizontal position in pixels | >= 0 (clamped via jmax) |
| y | Integer | no | Vertical position in pixels | >= 0 (clamped via jmax) |

**Pitfalls:**
- Calling this method after onInit throws "Tried to add a component after onInit()". All component creation must happen during onInit.

**Cross References:**
- `Content.getComponent`
- `Content.componentExists`

## addWebView

**Signature:** `ScriptWebView addWebView(String webviewName, int x, int y)`
**Return Type:** `ScriptWebView`
**Call Scope:** init
**Minimal Example:** `var wv = Content.addWebView("HelpView", 10, 10);`

**Description:**
Creates a ScriptWebView component (an embedded web browser view) and adds it to the interface. Accepts either 1 argument (name only, position defaults to 0,0) or 3 arguments (name, x, y). If a component with the same name already exists, the existing component is returned and its position is optionally updated. This idempotent behavior makes the call safe across recompiles. Can only be called during onInit -- calling after initialization throws a script error.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| webviewName | String | no | Unique name for the component (also used as its ID) | No whitespace |
| x | Integer | no | Horizontal position in pixels | >= 0 (clamped via jmax) |
| y | Integer | no | Vertical position in pixels | >= 0 (clamped via jmax) |

**Pitfalls:**
- Calling this method after onInit throws "Tried to add a component after onInit()". All component creation must happen during onInit.

**Cross References:**
- `Content.getComponent`
- `Content.componentExists`

## componentExists

**Signature:** `bool componentExists(String name)`
**Return Type:** `bool`
**Call Scope:** safe
**Minimal Example:** `var exists = Content.componentExists("MyKnob");`

**Description:**
Checks whether a component with the given name exists on the interface. Returns `true` if a component has been created with that name via any `addXXX()` method, `false` otherwise. This is safe to call at any time (not restricted to onInit). Useful for conditional logic when scripts need to handle interfaces with optional components.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| name | String | no | The component name to check | Case-sensitive |

**Cross References:**
- `Content.getComponent`
- `Content.getAllComponents`

**Example:**
```javascript:component-exists-check
// Title: Conditional component access
Content.makeFrontInterface(600, 300);
const var knob = Content.addKnob("CExKnob1", 10, 10);
const var found = Content.componentExists("CExKnob1");
const var missing = Content.componentExists("NonExistent");
```
```json:testMetadata:component-exists-check
{
  "testable": true,
  "verifyScript": [
    {"type": "REPL", "expression": "found", "value": true},
    {"type": "REPL", "expression": "missing", "value": false}
  ]
}
```

## setPropertiesFromJSON

**Signature:** `void setPropertiesFromJSON(String name, var jsonData)`
**Return Type:** `void`
**Call Scope:** unsafe
**Minimal Example:** `Content.setPropertiesFromJSON("MyKnob", {"text": "Volume", "width": 128, "height": 48});`

**Description:**
Sets multiple properties on a component identified by name using a JSON object. Each key in the JSON object must match a valid component property name (e.g., `text`, `width`, `height`, `x`, `y`, `visible`, `enabled`). This is a Content-level method that takes the component name as the first argument -- unlike `ScriptComponent.setPropertiesFromJSON()` which is called on the component reference directly.

If the named component does not exist, a script error is thrown.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| name | String | no | The name of the target component | Must exist |
| jsonData | JSON | no | Object with property name/value pairs | Keys must be valid property names |

**Pitfalls:**
- If a property key in the JSON does not match any valid property of the target component, it is silently ignored.

**Cross References:**
- `Content.getComponent`
- `Content.componentExists`

**Example:**
```javascript:set-props-from-json
// Title: Bulk-setting component properties
Content.makeFrontInterface(600, 300);
Content.addKnob("SPKnob1", 10, 10);
Content.setPropertiesFromJSON("SPKnob1", {
  "text": "Volume",
  "width": 128,
  "height": 48,
  "min": 0.0,
  "max": 1.0
});
const var ref = Content.getComponent("SPKnob1");
```
```json:testMetadata:set-props-from-json
{
  "testable": true,
  "verifyScript": [
    {"type": "REPL", "expression": "ref.get(\"width\")", "value": 128},
    {"type": "REPL", "expression": "ref.get(\"text\")", "value": "Volume"}
  ]
}
```

## storeAllControlsAsPreset

**Signature:** `void storeAllControlsAsPreset(String fileName, var automationData)`
**Return Type:** `void`
**Call Scope:** unsafe
**Minimal Example:** `Content.storeAllControlsAsPreset("myPreset.xml", undefined);`

**Description:**
Saves all component control values to an XML data file. This is the counterpart to `restoreAllControlsFromPreset()`. The `fileName` is resolved relative to the `UserPresets` folder. The second argument `automationData` is a ValueTree that, when provided, filters which controls are included based on plugin parameter automation data. Pass `undefined` to store all controls.

In exported plugins (USE_FRONTEND), the filename is matched against the embedded preset list -- the file path does not need to reference an actual disk file.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| fileName | String | no | The preset file name (relative to UserPresets) | Should end in .xml |
| automationData | var | no | Optional automation filter data (pass `undefined` for all controls) | ValueTree or undefined |

**Pitfalls:**
- The file is written relative to the UserPresets directory. Using absolute paths or paths outside this directory may not work as expected.

**Cross References:**
- `Content.restoreAllControlsFromPreset`
