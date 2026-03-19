<!-- Diagram triage:
  - No class-level or method-level diagrams specified in the JSON.
-->

# Content

Content is the root factory for the HiseScript UI system. It provides methods to create all visual components (buttons, knobs, sliders, labels, panels, etc.), factory methods for drawing utilities (paths, SVGs, shaders, markdown renderers, look-and-feel objects), and configuration methods for the interface itself (size, tooltips, key press handling, value popups).

The typical workflow starts with `Content.makeFrontInterface()` as the very first line of the interface script, followed by component creation with the various `addXXX()` methods, and then styling and configuration:

1. **Component creation** - `addKnob`, `addButton`, `addPanel`, and the other `addXXX()` methods build the interface.
2. **Drawing utilities** - `createLocalLookAndFeel`, `createPath`, `createSVG`, `createShader`, and `createMarkdownRenderer` produce reusable objects for custom visuals.
3. **Interface configuration** - `setValuePopupData`, `setKeyPressCallback`, `setSuspendTimerCallback`, and the size methods configure global interface behaviour.
4. **Runtime queries** - `getComponent`, `getAllComponents`, `getCurrentTooltip`, `getScreenBounds`, and the mouse/keyboard state methods provide runtime information.

```js
Content.makeFrontInterface(900, 600);
const var knob1 = Content.addKnob("Volume", 10, 10);
const var btn1 = Content.addButton("Bypass", 150, 10);
```

> Content enforces a strict two-phase lifecycle. All component creation (`addXXX()` calls) must happen during `onInit` - calling them afterwards throws a script error. Conversely, async utilities like `callAfterDelay` and `showModalTextInput` only work after `onInit` completes. The `addXXX()` methods are idempotent: if a component with the same name already exists, the existing component is returned, so re-running `onInit` on recompile never creates duplicates. `setHeight` and `setWidth` can be called after `onInit` to dynamically resize the interface; use `Broadcaster.attachToInterfaceSize()` to respond to size changes.

## Common Mistakes

- **Wrong:** `Content.addButton("Btn1", 10, 20)` in onControl
  **Right:** `Content.addButton("Btn1", 10, 20)` in onInit
  *Component creation is only allowed during onInit. Calling addXXX after initialisation throws a script error.*

- **Wrong:** `Content.getComponent("Knob1")` inside a timer callback
  **Right:** `const var knob1 = Content.getComponent("Knob1");` at init, use `knob1` in callback
  *`getComponent` performs a linear search through all components. Calling it repeatedly in callbacks wastes CPU. Cache the reference once at init time.*

- **Wrong:** Creating paths inside paint routines
  **Right:** `const var icon = Content.createPath();` at init scope
  *`createPath` allocates a new object. Creating paths inside paint routines causes allocation on every repaint. Create once, reuse everywhere.*

- **Wrong:** Scattering LAF objects across many files without structure
  **Right:** Organise LAFs in dedicated files by component type (e.g., `SliderLAF.js`, `ButtonLAF.js`)
  *As the number of LAF objects grows (20+), keeping them organised by visual component type makes maintenance practical.*
