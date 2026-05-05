---
title: "MidiChannelList"
description: "Per-channel MIDI input filter — 16 toggle rows that enable or disable each MIDI channel."
contentType: "MidiChannelList"
componentType: "floating-tile"
screenshot: "/images/v2/reference/ui-components/floating-tiles/midichannellist.png"
llmRef: |
  MidiChannelList (FloatingTile)
  ContentType string: "MidiChannelList"
  Set via: FloatingTile.set("ContentType", "MidiChannelList")

  Lists all 16 MIDI channels with a check box per row. Disabled channels are filtered out at the engine input — modules downstream do not receive events from them.

  JSON Properties:
    Font: Optional font override
    FontSize: Optional font size

  Customisation:
    LAF: none
    CSS: none
seeAlso: []
commonMistakes:
  - title: "Disabling a channel does not silence a sub-synth"
    wrong: "Unchecking channel 2 in MidiChannelList expecting only channel 1 events to reach a specific child synth"
    right: "MidiChannelList filters MIDI at the global engine input. To route specific channels to specific child synths, use the per-module MIDI processor with Message.ignoreEvent or filter on the channel manually"
    explanation: "Disabling a channel here drops the events at the plugin input — no module receives them. It is not a routing mechanism. For per-synth channel routing add a Script Processor to each child and gate inside onNoteOn."
---

![MidiChannelList](/images/v2/reference/ui-components/floating-tiles/midichannellist.png)

The MidiChannelList floating tile shows all 16 MIDI channels as check boxes. Unchecking a channel filters its events out at the engine input — no module receives them.

Use it when the user needs a global channel filter (e.g. a multi-channel keyboard split where the plugin should only respond to a specific channel range).

## Setup

```javascript
const var ft = Content.getComponent("FloatingTile1");

ft.set("ContentType", "MidiChannelList");
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
| `textColour` | Channel label colour |
| `itemColour1` | Check box accent colour |

## Notes

- Channel filtering happens at the engine input, before any module sees the event. This is the simplest way to enforce a global channel restriction.
- The list always shows 16 rows regardless of which channels carry traffic. There is no auto-hide for unused channels.
- For per-module channel routing (e.g. send channel 1 to a sampler and channel 2 to a synth in parallel), do *not* use MidiChannelList — add a Script Processor to each child synth and gate `Message.ignoreEvent(true)` on `Message.getChannel()`.
- This content type has no LAF or CSS support. To customise rows beyond the colour set, build the UI manually with ScriptComponent buttons that toggle channel state via the scripting API.

**See also:** $UI.MidiSources$ -- per-device counterpart, $API.Message.ignoreEvent$ -- per-synth channel filtering inside scripts, $API.ScriptFloatingTile$ -- scripting API for the floating tile wrapper
