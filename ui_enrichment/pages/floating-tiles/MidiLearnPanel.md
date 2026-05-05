---
title: "MidiLearnPanel"
description: "Table of MIDI-CC learn assignments with editable range, inversion and delete-row support."
contentType: "MidiLearnPanel"
componentType: "floating-tile"
screenshot: "/images/v2/reference/ui-components/floating-tiles/midilearnpanel.png"
llmRef: |
  MidiLearnPanel (FloatingTile)
  ContentType string: "MidiLearnPanel"
  Set via: FloatingTile.set("ContentType", "MidiLearnPanel")

  Table of all MIDI-CC learned parameters. Columns: CC #, target parameter, inverted toggle, min, max. Rows can be edited (range, invert) or deleted. A control becomes eligible for learning when its enableMidiLearn property is true.

  JSON Properties:
    Font: Optional font override
    FontSize: Optional font size

  Customisation:
    LAF: none (use CSS instead)
    CSS: table, th, tr, td, button, .range-slider, scrollbar
seeAlso: []
commonMistakes:
  - title: "Control never appears in MidiLearnPanel"
    wrong: "Right-clicking a knob to MIDI-learn and getting nothing in the panel"
    right: "Set the control's enableMidiLearn property to true — only opt-in components are eligible for MIDI learn"
    explanation: "Without enableMidiLearn the right-click context menu does not show the Learn entry, so no assignment is created."
  - title: "Styling MidiLearnPanel with LAF callbacks"
    wrong: "Trying to register drawTable / drawCell LAF callbacks for MidiLearnPanel"
    right: "Use CSS — register a stylesheet on the FloatingTile and target table / th / tr / td / button / .range-slider"
    explanation: "MidiLearnPanel does not provide scripted LAF callbacks. The CSS renderer is the supported way to fully restyle it (rendering and layout)."
---

![MidiLearnPanel](/images/v2/reference/ui-components/floating-tiles/midilearnpanel.png)

The MidiLearnPanel floating tile renders a table of every MIDI-CC learn assignment in the plugin. Each row shows the CC number, the target parameter ID, an "invert" toggle, and the min / max range. Rows can be edited inline or deleted.

A control is eligible for MIDI learn when its `enableMidiLearn` property is `true`. Once learned, the assignment appears as a row here and can be tweaked or removed by the end user.

> [!Warning:setControllerNumbersInPopup disables Learn] Calling `MidiAutomationHandler.setControllerNumbersInPopup()` removes the right-click "MIDI Learn" entry entirely — only the explicit "Assign CC" list remains. This is intentional (to prevent learning unlisted CCs) but is easy to mistake for a regression after restricting the popup list.

> [!Tip:Validate learned CCs with an update callback] Use `Engine.createMidiAutomationHandler().setUpdateCallback(fn)` to inspect each new assignment as it lands in the panel. This is the supported way to warn users when they pick a CC the plugin reserves internally — without giving up the standard MIDI Learn flow.

## Setup

```javascript
const var ft = Content.getComponent("FloatingTile1");

ft.set("ContentType", "MidiLearnPanel");
ft.set("Data", JSON.stringify({
    "Font": "Arial",
    "FontSize": 14,
    "ColourData": {
        "textColour": "0xFFEEEEEE",
        "bgColour": "0xFF222222",
        "itemColour1": "0xFF7FB6FF",
        "itemColour2": "0x22FFFFFF"
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

MidiLearnPanel ships with a CSS renderer that supports full layout customisation. Register a CSS look-and-feel on the floating tile and target the table elements directly. The styling is identical to [FrontendMacroPanel]($UI.FrontendMacroPanel$) — the same selectors and rules apply to both.

### Selectors

| Selector | Description |
|----------|-------------|
| `table` | The table background — also uses `margin` / `padding` for outer spacing |
| `th` | Header cells. Use `:first-child` / `:last-child` to style edge corners |
| `tr` | Row background |
| `td` | Cell content (text in the first two columns) |
| `button` | The "invert" button. Width controls the column size |
| `.range-slider` | The min / max range sliders. Width controls the column size |
| `scrollbar` | Scrollbar that appears when rows exceed the visible area |

### Layout via CSS

The stylesheet also drives layout:

- Header height is taken from `th` (font height + vertical padding/margin)
- Row height is taken from `td`
- Column widths are derived from cell text width + horizontal padding/margin. The second column (target ID) stretches to fill remaining space; other columns are sized to their text or the `.range-slider` / `button` width

### Example Stylesheet

```javascript
const var ft = Content.getComponent("FloatingTile1");
const var laf = Content.createLocalLookAndFeel();

laf.setInlineStyleSheet("
table
{
    background: #222;
    color: white;
    margin: 4px;
}

th
{
    background: #333;
    padding: 4px 10px;
    font-weight: bold;
}

th:first-child { border-top-left-radius: 3px; }
th:last-child  { border-top-right-radius: 3px; }

tr
{
    background: #2a2a2a;
    padding: 2px 0;
}

tr:hover
{
    background: #3a3a3a;
}

td
{
    padding: 4px 10px;
}

button
{
    width: 60px;
    background: #555;
    border-radius: 3px;
}

.range-slider
{
    width: 120px;
}

scrollbar
{
    width: 8px;
    background: #444;
}
");

ft.setLocalLookAndFeel(laf);
```

## Notes

- A row appears here only after a CC has been MIDI-learned to a component with `enableMidiLearn = true`. The list is read-only with respect to *adding* new entries — those come from the right-click learn flow.
- The "Invert" button flips the CC range so that `0` maps to the parameter's max and `127` to its min.
- Press the **Delete** key on a selected row to remove the assignment, or use the row's context menu.
- This panel does **not** expose scripted LAF callbacks. Use the CSS renderer for any custom appearance beyond the colour data.

> [!Warning:Global LAF hides table headers] Declaring a global look-and-feel object can wipe the column headers from the default-rendered MidiLearnPanel. Either register the LAF locally on the floating tile only, or switch to the CSS renderer (which is unaffected) to keep the headers visible.

> [!Warning:FX plugins need DAW MIDI routing] In a compiled FX (audio effect) plugin most DAWs do **not** forward MIDI to the plugin by default — so right-clicking a knob may show no Learn entry and incoming CCs do nothing. The user has to enable MIDI input on the FX channel in their DAW (the location varies: FL Studio, Studio One and Logic each hide it in different places).

**See also:** $UI.FrontendMacroPanel$ -- companion table panel sharing the CSS rules, $API.Engine.createMidiAutomationHandler$ -- programmatic access to the MIDI automation handler, $API.ScriptFloatingTile$ -- scripting API for the floating tile wrapper
