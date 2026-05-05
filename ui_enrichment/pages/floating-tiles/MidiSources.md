---
title: "MidiSources"
description: "List of all available MIDI input devices with per-device enable / disable toggles."
contentType: "MidiSources"
componentType: "floating-tile"
screenshot: "/images/v2/reference/ui-components/floating-tiles/midisources.png"
llmRef: |
  MidiSources (FloatingTile)
  ContentType string: "MidiSources"
  Set via: FloatingTile.set("ContentType", "MidiSources")

  Renders a list of every MIDI input device exposed by the OS, each with a check box to toggle whether the standalone application listens to it. No effect in plugin builds — the host owns MIDI routing there.

  JSON Properties:
    Font: Optional font override
    FontSize: Optional font size

  Customisation:
    LAF: none
    CSS: none
seeAlso: []
commonMistakes:
  - title: "MidiSources empty in plugin build"
    wrong: "Showing MidiSources in a hosted plugin and expecting users to enable inputs"
    right: "Hide MidiSources in plugin builds — only the standalone application opens MIDI devices directly"
    explanation: "Plugins receive MIDI from the host, not from the OS. The MidiSources list only has meaning when running the standalone build of the project."
---

![MidiSources](/images/v2/reference/ui-components/floating-tiles/midisources.png)

The MidiSources floating tile lists every MIDI input device exposed by the operating system and renders a check box next to each one. Toggling a check box enables or disables the device for the standalone application — the engine starts listening (or stops listening) without needing a relaunch.

In plugin builds this list is irrelevant because the host owns MIDI routing. Hide the panel for plugin targets.

## Setup

```javascript
const var ft = Content.getComponent("FloatingTile1");

ft.set("ContentType", "MidiSources");
ft.set("Data", JSON.stringify({
    "Font": "Arial",
    "FontSize": 14,
    "ColourData": {
        "textColour": "0xFFEEEEEE"
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
| `textColour` | Device label colour |
| `itemColour1` | Check box accent colour |

## Notes

- The list is rebuilt automatically when MIDI devices are connected or disconnected. No manual refresh is required.
- Inside a plugin build the panel still renders, but the toggles do not affect MIDI routing — the host decides which inputs reach the plugin. Gate visibility with `HiseDeviceSimulator.isStandalone()`.
- This content type has no LAF or CSS support. To customise the row appearance, build a settings page using ScriptComponents that read / write the same enable state via the `Settings` scripting API.

**See also:** $UI.MidiChannelList$ -- per-channel filter counterpart, $UI.CustomSettings$ -- combined settings panel that can include MIDI device selection, $API.ScriptFloatingTile$ -- scripting API for the floating tile wrapper
