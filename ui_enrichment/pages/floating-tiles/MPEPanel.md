---
title: "MPEPanel"
description: "MPE configuration panel — enables MPE mode, lists MPE modulators in the project, and exposes per-target settings."
contentType: "MPEPanel"
componentType: "floating-tile"
screenshot: "/images/v2/reference/ui-components/floating-tiles/mpepanel.png"
llmRef: |
  MPEPanel (FloatingTile)
  ContentType string: "MPEPanel"
  Set via: FloatingTile.set("ContentType", "MPEPanel")

  MPE configuration surface. Detects all MPEModulator instances in the module tree and renders them in a list with per-row controls (smoothing time, target selector, intensity, default value). Includes a master MPE on/off toggle.

  JSON Properties:
    Font: Optional font override
    FontSize: Optional font size

  Customisation:
    LAF: none
    CSS: none
seeAlso: []
commonMistakes:
  - title: "MPE panel empty after enabling MPE"
    wrong: "Toggling MPE on inside the panel and expecting it to populate with rows automatically"
    right: "Add MPEModulator instances to the relevant modulator chains — the panel discovers them after the next refresh"
    explanation: "The MPE panel only shows MPE modulators that exist in the module tree. Without any MPEModulator placed (e.g. on pitch / pressure / slide chains) the panel has nothing to list."
---

![MPEPanel](/images/v2/reference/ui-components/floating-tiles/mpepanel.png)

The MPEPanel floating tile is the configuration surface for the MPE (MIDI Polyphonic Expression) system. It contains a master MPE enable toggle and a list of every MPEModulator detected in the project. Each row exposes that modulator's smoothing time, target parameter, intensity, and default value.

Add MPEModulator modules to the modulator chains you want MPE to drive (typically pitch, pressure / aftertouch, and slide / glide). The panel detects them automatically and renders one row per modulator.

> [!Warning:MPE modulators don't save their own state] Unlike every other modulator in HISE, an MPEModulator does **not** persist its parameters with the project — it relies entirely on the MPEPanel to push state into it. This means the panel must exist somewhere in the floating-tile tree (even hidden) for MPE settings to be restored when the project / preset loads.

> [!Tip:Share MPE across samplers via a Global Modulator Container] To drive several samplers from a single MPE source, place one MPEModulator in a Global Modulator Container and reference it as a global modulator in each sampler's chain. This avoids creating per-sampler MPE modulators that the user has to configure individually.

## Setup

```javascript
const var ft = Content.getComponent("FloatingTile1");

ft.set("ContentType", "MPEPanel");
ft.set("Data", JSON.stringify({
    "Font": "Arial",
    "FontSize": 14,
    "ColourData": {
        "textColour": "0xFFEEEEEE",
        "bgColour": "0xFF1A1A1A",
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
| `bgColour` | Background colour |
| `textColour` | Label / cell text colour |
| `itemColour1` | Slider / button accent colour |

## Notes

- The master MPE toggle at the top of the panel turns the engine's MPE handling on or off globally. Without it active, MPEModulators do not receive MPE channel data.
- When the modulator tree changes (a new MPEModulator added or removed), the panel rebuilds its list automatically.
- Each row's controls map directly to the corresponding MPEModulator parameters — changes made here are equivalent to setting attributes via the scripting API.
- This content type has no LAF or CSS support. For a fully custom MPE configuration UI, build it from ScriptComponents bound to the MPEModulator parameters.
- Pair the panel with a [Keyboard]($UI.Keyboard$) floating tile in MPE mode (`MPEKeyboard = true`) for an integrated MPE input + configuration page.

> [!Warning:MPE modulators only work on voice-aware modulator chains] MPEModulators rely on per-voice MIDI channel routing, so they only attach meaningfully to modulator chains inside sound generators (sampler / synth). Container-level effects (e.g. a master filter cutoff) cannot be driven by MPE per-note — use a CC modulator there, or duplicate the MPEModulator into each sampler that should react.

> [!Tip:Default MPE off in shipped presets] Several builders found that shipping with MPE enabled by default caused subtle issues with release triggers and other voice-state code. Defaulting the master MPE toggle to **off** and letting users opt in via the panel sidesteps these edge cases for non-MPE players (who form the majority of users anyway).

**See also:** $MODULES.MPEModulator$ -- per-modulator detail rendered as rows in this panel, $UI.Keyboard$ -- pair with `MPEKeyboard = true` for MPE input, $API.ScriptFloatingTile$ -- scripting API for the floating tile wrapper
