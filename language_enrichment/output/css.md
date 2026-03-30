---
title: CSS in HISE
description: "Cascading Style Sheets for styling HISE UI components"

guidance:
  summary: >
    Complete reference for CSS styling in HISE. Covers the CSS renderer's
    supported selectors (type, class, ID, universal, descendant), pseudo-classes
    and pseudo-elements (including HISE-specific ::before2/::after2), the full
    property set (layout, flexbox, visual, borders, shadows, typography, transforms,
    transitions), CSS variables with per-component scoping, the @font-face rule,
    the integration API (setStyleSheet, setStyleSheetClass, setStyleSheetProperty),
    the CSS debugger, and a comprehensive differences-from-standard table. The
    renderer uses a subset of CSS with flexbox layout support but no grid, no
    keyframe animations, and no media queries.
  concepts:
    - CSS
    - styling
    - ScriptLookAndFeel
    - setStyleSheet
    - setInlineStyleSheet
    - setStyleSheetClass
    - setStyleSheetProperty
    - flexbox
    - transitions
    - CSS variables
    - pseudo-classes
    - pseudo-elements
    - CSS debugger
  prerequisites:
    - hisescript
  complexity: intermediate
---

Cascading Style Sheets (CSS) provide a standardised way to control the look and feel of HISE UI components.

The CSS renderer aims to be as standard compliant as possible while operating within the constraints of a real-time audio plugin UI framework. This page documents what's supported, what's different, and how to use it.


## Getting Started

Apply CSS to components through `ScriptLookAndFeel`:

```javascript
const var laf = Content.createLocalLookAndFeel();

laf.setInlineStyleSheet("
button {
    background-color: #333333;
    color: white;
    border-radius: 5px;
    padding: 8px 16px;
    transition: background-color 0.2s ease;
}

button:hover {
    background-color: #555555;
}
");

const var btn = Content.getComponent("Button1");
btn.setLocalLookAndFeel(laf);
```

For larger stylesheets, use an external `.css` file:

```javascript
laf.setStyleSheet("MyStyles.css"); // loaded from Scripts folder
```


## Selectors

Selectors determine which components a CSS rule applies to. Every component picks up properties from all matching selectors and combines them according to CSS specificity.

### Universal Selector

Selects all elements. Overridden by any other selector — useful for global defaults like font styles.

```css
* {
    font-family: Arial;
    font-size: 14px;
}
```

### Type (Element) Selectors

Select components by their HTML-equivalent type. Available type selectors in HISE:

| Selector | HISE Component |
| --- | --- |
| `button` | Button |
| `select` | ComboBox |
| `label` | Label |
| `input` | Label text editor (when editing) |
| `div` | Panel or Floating Tile |
| `img` | Image components |
| `progress` | Progress bars |
| `scrollbar` | Scrollbar |
| `table` | Table component |
| `th` | Table header |
| `tr` | Table / ListBox rows |
| `td` | Table cells |
| `p` | Paragraph text |
| `h1`, `h2`, `h3`, `h4` | Heading levels |
| `hr` | Horizontal rule |
| `body` | Root container |

### Class Selectors

Use `.classname` syntax. Some component types have default classes:

| Default Class | Component |
| --- | --- |
| `.scriptslider` | Slider / Knob |
| `.scriptbutton` | Button |
| `.popup-menu` | Context menu container |
| `.popup-item` | Context menu item |

Add custom classes to any component from script:

```javascript
btn.setStyleSheetClass(".primary .large");
```

> [!Tip:Default class is always attached] The default class (e.g., `.scriptbutton`) stays attached even when you set custom classes. It's only removed if you explicitly clear all classes with an empty string.

### ID Selectors

Use `#componentId` to target a specific component by its Component ID. Has the highest specificity — always overrides type and class selectors.

```css
#MasterVolume {
    background: linear-gradient(to right, #444, #666);
}
```

### Descendant Selectors

Use a space between selectors to match nested components:

```css
div button {
    font-size: 12px;
}
```

> [!Warning:Limited combinator support] Only the descendant combinator (space) is supported. Child (`>`), adjacent sibling (`+`), and general sibling (`~`) combinators are not implemented.


## Pseudo-Classes

Pseudo-classes define component states. Append after any selector:

```css
button:hover { background-color: #555; }
button:active { background-color: #222; }
button:checked { background-color: #FF8800; }
```

| Pseudo-Class | Triggered by |
| --- | --- |
| `:hover` | Mouse over component |
| `:active` | Mouse button held down |
| `:focus` | Component has keyboard focus |
| `:disabled` | Component is disabled (`set("enabled", false)`) |
| `:checked` | Button toggle state is on (`setValue(true)`) |
| `:first-child` | First child in a container |
| `:last-child` | Last child in a container |
| `:root` | Submenu items in popup menus |
| `:hidden` | Custom hidden flag |

You can also set pseudo-states manually from script:

```javascript
component.setStyleSheetPseudoState("hover");
```


## Pseudo-Elements

Style specific sub-parts of a component. The `content` property must be set for the pseudo-element to render.

```css
select::before {
    content: '';
    color: red;
}
```

| Pseudo-Element | Description |
| --- | --- |
| `::before` | Rendered before the main content |
| `::after` | Rendered after the main content |
| `::before2` | Second before element (HISE extension) |
| `::after2` | Second after element (HISE extension) |
| `::selection` | Text selection colour in text editors |


## Properties Reference

### Layout & Positioning

| Property | Values | Notes |
| --- | --- | --- |
| `display` | `flex`, `none` | Only flexbox and hidden — no `block`, `inline`, `grid` |
| `position` | `initial`, `relative`, `absolute`, `fixed` | |
| `top`, `left`, `bottom`, `right` | px, %, em, calc() | For positioned elements |
| `width`, `height` | px, %, em, vh, calc(), `auto` | |
| `min-width`, `max-width` | px, %, em, calc() | |
| `min-height`, `max-height` | px, %, em, calc() | |
| `margin` (+ directional) | 1-4 values; px, %, `auto` | See Differences section for HISE-specific behavior |
| `padding` (+ directional) | 1-4 values; px, % | |
| `box-sizing` | `content-box`, `border-box` | |
| `overflow` | Limited | Only meaningful for viewport scrolling |

### Flexbox

HISE supports a full flexbox implementation via `display: flex`:

| Property | Values |
| --- | --- |
| `flex-direction` | `row`, `row-reverse`, `column`, `column-reverse` |
| `flex-wrap` | `nowrap`, `wrap`, `wrap-reverse` |
| `justify-content` | `flex-start`, `flex-end`, `center`, `space-between`, `space-around` |
| `align-items` | `stretch`, `flex-start`, `flex-end`, `center` |
| `align-content` | `stretch`, `flex-start`, `flex-end`, `center` |
| `align-self` | `auto`, `flex-start`, `flex-end`, `center`, `stretch` |
| `flex-grow` | number | |
| `flex-shrink` | number | |
| `flex-basis` | px, %, auto | |
| `order` | integer | |
| `gap` | px | Space between flex items |

```css
div {
    display: flex;
    flex-direction: row;
    gap: 10px;
    justify-content: space-between;
    align-items: center;
}
```

### Colours & Backgrounds

```css
button {
    color: red;                           /* named colours */
    color: #FF0000;                       /* hex */
    color: 0xFFFF0000;                    /* JUCE ARGB format */
    color: rgb(255, 0, 0);               /* RGB */
    color: rgba(255, 0, 0, 0.5);         /* RGBA */
    color: hsl(0, 100%, 50%);            /* HSL */
    color: color-mix(in rgb, red 25%, transparent); /* colour mixing */
    background: linear-gradient(to right, red, yellow); /* gradient */
}
```

| Property | Values |
| --- | --- |
| `background` / `background-color` | Solid colour, `linear-gradient()`, `color-mix()` |
| `background-image` | `url()`, `linear-gradient()`, base64-encoded JUCE Path data |
| `background-size` | `fill`, `contain`, `cover`, `none`, `scale-down` |
| `background-position` | With transition support |
| `color` | Text colour |
| `opacity` | 0.0 - 1.0 |
| `cursor` | `default`, `pointer`, `wait`, `crosshair`, `text`, `copy`, `grabbing` |

### Borders

```css
button {
    border: 2px solid black;
    border-radius: 10px;
    border-radius: 10px 20px 30px 40px; /* per-corner */
    border-radius: 50%;                 /* circle */
}
```

| Property | Values |
| --- | --- |
| `border` (shorthand) | width + style + colour |
| `border-width` | px (also per-edge) |
| `border-style` | `solid`, `dotted`, `dashed`, `outset` |
| `border-color` | Any colour (also per-edge) |
| `border-radius` (+ corners) | px, %; 1/2/4 value shorthand |

### Shadows

```css
button {
    box-shadow: 5px 5px 15px rgba(0,0,0,0.3);
    box-shadow: inset 2px 2px 5px rgba(0,0,0,0.5); /* inner shadow */
    text-shadow: 2px 2px 5px rgba(0,0,0,0.3);
}
```

Multiple comma-separated shadows are supported for both `box-shadow` and `text-shadow`.

### Typography

| Property | Values |
| --- | --- |
| `font-family` | System fonts, custom fonts via `@font-face`, `monospace`, `sans-serif` |
| `font-size` | px, em, %, calc() |
| `font-weight` | `normal`/`400`, `bold`/`700`, `500`-`900` |
| `font-stretch` | Horizontal scale factor |
| `letter-spacing` | px |
| `text-align` | `left`/`start`, `right`/`end`, `center` |
| `vertical-align` | `top`, `bottom`, `middle` |
| `text-transform` | `none`, `capitalize`, `uppercase`, `lowercase` |
| `content` | String for `::before`/`::after` pseudo-elements |
| `caret-color` | TextEditor caret colour |

### Transforms

```css
button:hover {
    transform: scale(1.05) rotate(2deg);
}
```

Supported transform functions: `translate(x,y)`, `translateX`, `translateY`, `scale(x,y)`, `scaleX`, `scaleY`, `rotate(angle)`, `rotateX`, `rotateY`, `skew(x,y)`, `skewX`, `skewY`.

Not supported: `matrix()`, `translateZ`, `scaleZ`, `rotateZ` (no 3D transforms).

### Transitions

```css
button {
    background-color: red;
    transition: background-color 0.5s ease;
}

button:hover {
    background-color: yellow;
}
```

Format: `property duration [timing-function] [delay]`. Use `all` to transition every property.

Supported timing functions: `linear`, `ease`, `ease-in`, `ease-out`, `ease-in-out`, `cubic-bezier(p1x, p1y, p2x, p2y)`, `steps(n, start|end)`.

All visual properties (colours, gradients, shadows, transforms, opacity) can be transitioned.

### Expressions

CSS expressions allow dynamic value calculation:

```css
button {
    width: calc(100% - 20px);
    font-size: clamp(12px, 2em, 24px);
    height: min(100px, 50%);
    width: max(200px, 30%);
}
```

Supported units: `px`, `%`, `em`, `vh`, `deg`.


## CSS Variables

CSS variables enable dynamic styling from script. Every component automatically has its colour properties available as variables:

- `--bgColour`
- `--textColour`
- `--itemColour`
- `--itemColour2`

Additionally, `--name` is automatically set to the component's name.

```css
button {
    background-color: var(--bgColour);
    color: var(--textColour);
}
```

### Setting Variables from Script

**Global** (applies to all components using this LAF):

```javascript
laf.setStyleSheetProperty("myValue", "16px", "");
```

**Per-component** (overrides global for one component):

```javascript
btn.setStyleSheetProperty("icon", "path-data-here", "");
```

Use variables in CSS with `var(--propertyName)`:

```css
button::before {
    content: '';
    background-image: var(--icon);
}
```


## Custom Fonts

Load custom fonts with `@font-face`:

```css
@font-face {
    font-family: MyFont;
    src: url('{PROJECT_FOLDER}Fonts/CustomFont.ttf');
}

button {
    font-family: MyFont;
}
```

The `src` is optional if you've already loaded the font with `Engine.loadFontAs()`. System fonts can be used directly by name without `@font-face`.

Stylesheets can also import other CSS files:

```css
@import url('shared-styles.css');
```


## Integration API

### ScriptLookAndFeel Methods

| Method | Description |
| --- | --- |
| `laf.setStyleSheet(filename)` | Load a `.css` file from the Scripts folder |
| `laf.setInlineStyleSheet(cssString)` | Apply CSS from a string literal |
| `laf.setStyleSheetProperty(id, value, type)` | Set a global CSS variable for all components using this LAF |

### Component Methods

| Method | Description |
| --- | --- |
| `component.setStyleSheetClass(classIds)` | Set CSS class selectors (e.g., `".primary .large"`) |
| `component.setStyleSheetPseudoState(state)` | Manually set pseudo-class state |
| `component.setStyleSheetProperty(id, value, type)` | Set a CSS variable on a specific component |

CSS styling is applied through the look-and-feel system. The CSS selector, supported pseudo-classes, and available pseudo-elements for each component type are documented in the $UI.Components$ reference — each component's page includes its CSS integration details.

> [!Tip:Independent CSS scopes] Each `ScriptLookAndFeel` instance has its own independent CSS scope. The universal selector `*` only applies to components assigned to that specific LAF — not all components in the interface.


## CSS Debugger

Right-click a CSS-styled component and select **Show CSS debugger** to inspect its styles. The debugger shows:

1. **Component stylesheet** — the combined set of properties from all matching selectors, with the component's full selector chain (e.g., `button #Button1 .scriptbutton .primary`)
2. **Inherited style sheets** — all matching selectors in reverse cascade order, with overridden properties commented out
3. **Overlay modes** — visualize margin/padding boxes (like Chrome DevTools) or highlight all CSS-styled components

The debugger also supports **edit mode**: modify CSS directly and press F5 to live-reload.


## Differences from Standard CSS

HISE's CSS deviations fall into three categories, each driven by a different design rationale.

### Absolute Positioning Model

HISE UI components use absolute positioning as their default layout model — every component has explicit `x`, `y`, `width`, `height` coordinates set from the component properties. CSS layout features that assume a flow-based document model don't apply. Flexbox is supported for the specific use case of positioning sub-elements within a single component (e.g., cells within a preset browser, rows in a matrix table), but it's the exception rather than the default.

| Feature | Standard CSS | HISE CSS |
| --- | --- | --- |
| `margin` | Creates space between elements in document flow | Controls gap between component bounds and drawn background — no effect on siblings |
| Child/sibling combinators (`>`, `+`, `~`) | Select based on DOM tree relationships | Not supported — component hierarchy doesn't map to DOM parent-child nesting |
| `display: grid` | Grid-based layout | Not supported — use flexbox for sub-component layout, absolute positioning otherwise |
| `display: block` / `inline` | Flow layout | Not supported — only `flex` and `none` |
| `z-index` | Controls stacking order | Not supported — paint order follows the component tree |
| `float` / `clear` | Document flow wrapping | Not supported |
| `visibility` vs `display` | Two separate properties | Only `display: none` — toggle visibility from script |

### Web-Specific Features

Some standard CSS features exist specifically for web browser rendering — responsive layouts across screen sizes, 3D GPU-accelerated rendering, and device-adaptive styling. These don't apply to a fixed-size plugin UI rendered in a DAW host.

| Feature | Standard CSS | HISE CSS |
| --- | --- | --- |
| Media queries (`@media`) | Responsive breakpoints | Not supported — handle responsive logic from script if needed |
| 3D transforms (`translateZ`, `matrix()`, `rotateZ`) | GPU-accelerated 3D | Not supported — 2D transforms cover plugin UI needs |
| `@keyframes` animations | Declarative animation sequences | Not supported — use script-driven timers for animation |
| Advanced pseudo-classes (`:nth-child()`, `:not()`, `:has()`) | Complex selector logic | Not supported — the 10 supported states cover audio plugin UI needs |
| Attribute selectors (`[attr=value]`) | Select by HTML attributes | Not supported |
| `inherit` / `initial` / `unset` | True cascade inheritance | Simplified — mapped to defaults |
| `!important` | Full cascade weight system | Simplified binary priority |

### HISE-Specific Extensions

These additions improve integration with existing HISE concepts — the JUCE colour format used throughout the codebase, the Path object system for vector graphics, and extra pseudo-elements for complex component styling that needs more than two decorative layers.

| Feature | Standard CSS | HISE CSS |
| --- | --- | --- |
| `0xAARRGGBB` colour format | Not supported | Supported — matches the JUCE/HISE colour format used in `Colour()` constructors |
| `::before2` / `::after2` | Not available | Extra pseudo-elements for components needing more than two decorative layers |
| `background-image` with Path data | `url()` only | Also accepts base64-encoded JUCE Path data — embed vector graphics directly in CSS |
| `color-mix()` | Partial browser support | Supported — useful for deriving colours from CSS variables |




## What's Next

**See also:** $UI.Components$ -- per-component CSS selectors and states, $API.ScriptLookAndFeel.setStyleSheet$ -- apply CSS from file, $API.ScriptLookAndFeel.setInlineStyleSheet$ -- apply CSS from string, $LANG.hisescript$ -- the scripting language used alongside CSS
