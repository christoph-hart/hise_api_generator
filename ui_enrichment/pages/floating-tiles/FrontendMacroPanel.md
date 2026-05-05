---
title: "FrontendMacroPanel"
description: "Table of macro control assignments with editable ranges, inversion and per-target rows."
contentType: "FrontendMacroPanel"
componentType: "floating-tile"
screenshot: "/images/v2/reference/ui-components/floating-tiles/frontendmacropanel.png"
llmRef: |
  FrontendMacroPanel (FloatingTile)
  ContentType string: "FrontendMacroPanel"
  Set via: FloatingTile.set("ContentType", "FrontendMacroPanel")

  Table of all macro-control assignments. Each row shows the source macro, the target parameter, an invert toggle and the macro range. Requires Engine.setFrontendMacros() to enable the macro system. Identical CSS styling to MidiLearnPanel.

  JSON Properties:
    Font: Optional font override
    FontSize: Optional font size

  Customisation:
    LAF: none (use CSS instead)
    CSS: table, th, tr, td, button, .range-slider, scrollbar
seeAlso: []
commonMistakes:
  - title: "Panel always empty"
    wrong: "Adding a FrontendMacroPanel without calling Engine.setFrontendMacros() during onInit"
    right: "Call Engine.setFrontendMacros(['Macro 1', 'Macro 2', ...]) once during onInit to enable the macro system and define the macro names"
    explanation: "Without setFrontendMacros() the macro management system is disabled and no rows can appear. The function takes the macro display names and turns the system on."
---

![FrontendMacroPanel](/images/v2/reference/ui-components/floating-tiles/frontendmacropanel.png)

The FrontendMacroPanel floating tile renders a table of all macro-control assignments in the plugin. Each row shows the source macro, the target parameter, an invert toggle, and the macro's min / max range. Users can adjust the range, flip the inversion, or delete an assignment.

Macro support has to be enabled first by calling [Engine.setFrontendMacros]($API.Engine.setFrontendMacros$) — typically once during `onInit`. Without that call the macro system stays off and the panel has nothing to display.

For full programmatic control over macro connections, use the [MacroHandler]($API.MacroHandler$) scripting API instead of (or alongside) this panel.

> [!Tip:Disable macros entirely with an empty array] To remove the "Assign Macro" entries from the right-click menu after previously enabling them, call `Engine.setFrontendMacros([])`. An empty array turns the macro management system back off — passing the names again later re-enables it.

> [!Tip:Use macros to gang multiple knobs] Beyond DAW automation, the practical use of frontend macros is "ganging" — assigning two or more controls to the same macro so they move together. Moving any one of the linked controls drives them all, which is convenient for paired wet/dry, stereo, or symmetrical parameters.

## Setup

```javascript
// In onInit, enable macros:
Engine.setFrontendMacros(["Macro 1", "Macro 2", "Macro 3", "Macro 4"]);

const var ft = Content.getComponent("FloatingTile1");

ft.set("ContentType", "FrontendMacroPanel");
ft.set("Data", JSON.stringify({
    "Font": "Arial",
    "FontSize": 14,
    "ColourData": {
        "textColour": "0xFFEEEEEE",
        "bgColour": "0xFF222222",
        "itemColour1": "0xFF7FB6FF"
    }
}));
```

## JSON Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `Font` | String | `""` | Optional font override |
| `FontSize` | float | `14.0` | Font size in points |

The `ColourData` object can be used to set colours for the default rendering:

| Colour ID | Description |
|-----------|-------------|
| `bgColour` | Background colour of the table |
| `textColour` | Header / cell text colour |
| `itemColour1` | Range slider accent colour |
| `itemColour2` | Alternate row colour |

## CSS Styling

FrontendMacroPanel uses the same CSS renderer and selector set as [MidiLearnPanel]($UI.MidiLearnPanel$). The stylesheet drives both rendering *and* layout (header / row heights, column widths).

### Selectors

| Selector | Description |
|----------|-------------|
| `table` | Table background and outer spacing (`margin` / `padding`) |
| `th` | Header cells — use `:first-child` / `:last-child` to round the edge corners |
| `tr` | Row background |
| `td` | Cell content text |
| `button` | The "invert" button — `width` controls the column size |
| `.range-slider` | The macro range sliders — `width` controls the column size |
| `scrollbar` | Scrollbar shown when rows exceed the visible area |

### Layout via CSS

- Header height = `th` font + vertical padding / margin
- Row height = `td` font + vertical padding / margin
- Column widths derive from cell text width + horizontal padding / margin. The target-ID column stretches to fill the remaining space; other columns are sized to their content or to the explicit `width` of `.range-slider` / `button`

### Example Stylesheet

See the [MidiLearnPanel CSS example]($UI.MidiLearnPanel$) — the styling is interchangeable.

## Notes

- Macro support must be turned on with `Engine.setFrontendMacros([...])` before any rows can appear. The argument array sets the display names of the macros.
- For programmatic management (adding / removing connections from script), use the [MacroHandler]($API.MacroHandler$) API. FrontendMacroPanel is the user-facing editor surface for the same data.
- Style this panel with CSS — it does **not** expose scripted LAF callbacks. The CSS rules are 100% identical to MidiLearnPanel, so a shared stylesheet drives both.
- Press **Delete** on a selected row to remove the macro assignment.

> [!Warning:Parameter column shows the component ID] The "Parameter" column displays the underlying component ID, **not** the user-facing `pluginParameterName`. There is currently no JSON / scripted way to switch this to the friendly name — changing it requires a C++ source patch in `FrontendPanelTypes.cpp`.

> [!Warning:Macro modulators don't run in container FX] Macro Modulation Sources placed at the root container (or any container without voice logic) won't process MIDI / note events the way they do inside a sampler — for example a tempo-synced LFO may free-run instead of restarting on note-on. Place macro modulators inside a sound generator (e.g. the sine wave / sampler module) when you need note-driven behaviour.

**See also:** $UI.MidiLearnPanel$ -- companion table panel sharing the CSS rules, $API.Engine.setFrontendMacros$ -- enables the macro system, $API.MacroHandler$ -- programmatic API for macro connections, $API.ScriptFloatingTile$ -- scripting API for the floating tile wrapper
