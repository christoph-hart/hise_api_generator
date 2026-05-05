---
title: "CustomSettings"
description: "Audio device, performance and engine settings panel — exposes any subset of standalone-app preferences to the user."
contentType: "CustomSettings"
componentType: "floating-tile"
screenshot: "/images/v2/reference/ui-components/floating-tiles/customsettings.png"
llmRef: |
  CustomSettings (FloatingTile)
  ContentType string: "CustomSettings"
  Set via: FloatingTile.set("ContentType", "CustomSettings")

  Settings panel that lets the end user change audio device, buffer size, sample rate, voice limit, scale factor, streaming mode and other engine-level preferences. Each setting is opt-in via a boolean property — set true to expose the row, false to hide it.

  JSON Properties (each true/false to show/hide row):
    Driver, Device, Output, BufferSize, SampleRate, GlobalBPM, ScaleFactor, GraphicRendering,
    StreamingMode, SustainCC, VoiceAmount, ClearMidiCC, SampleLocation, DebugMode
    ScaleFactorList: Array of available zoom factors (e.g. [0.5, 1.0, 1.25, 1.5])

  Customisation:
    LAF: none
    CSS: none
seeAlso: []
commonMistakes:
  - title: "Audio settings shown in a plugin build"
    wrong: "Showing Driver / Device / BufferSize / SampleRate rows in a hosted plugin build (VST/AU/AAX)"
    right: "Hide the audio device rows for plugin builds — the host owns the audio device. Show them only in standalone builds"
    explanation: "Driver, Device, BufferSize, SampleRate and Output have no effect when running as a plugin — the host controls those. Showing them confuses users. Use HiseDeviceSimulator.isStandalone() to gate visibility at scripting time."
  - title: "ScaleFactor visible without ScaleFactorList"
    wrong: "Setting ScaleFactor to true without specifying ScaleFactorList — user gets a default zoom range"
    right: "Set ScaleFactorList to the zoom levels you want to support, e.g. [0.75, 1.0, 1.25, 1.5]"
    explanation: "The ScaleFactor combobox reads its options from ScaleFactorList. Without it, only the built-in defaults appear, which may not match the resolutions your interface was designed for."
---

![CustomSettings](/images/v2/reference/ui-components/floating-tiles/customsettings.png)

The CustomSettings floating tile is the standard settings panel for standalone HISE applications and exposed plugin preferences. It renders a vertical stack of rows — one per opt-in setting — letting the end user change audio device configuration, voice limits, scaling, streaming mode, and other engine-level options.

Every row is opt-in: set its property to `true` to show it, `false` to hide it. This way you can build a settings page tailored to your project (e.g. only zoom + voice amount in a plugin build, full audio + zoom + streaming in a standalone build).

## Setup

```javascript
const var ft = Content.getComponent("FloatingTile1");

ft.set("ContentType", "CustomSettings");
ft.set("Data", JSON.stringify({
    "Driver": true,
    "Device": true,
    "Output": true,
    "BufferSize": true,
    "SampleRate": true,
    "ScaleFactor": true,
    "ScaleFactorList": [0.75, 1.0, 1.25, 1.5],
    "VoiceAmount": true,
    "StreamingMode": true,
    "ClearMidiCC": true,
    "SampleLocation": true,
    "DebugMode": false,
    "GraphicRendering": true,
    "SustainCC": true,
    "GlobalBPM": false
}));
```

## JSON Properties

Each visibility property is a boolean — set it to `true` to show the corresponding row in the settings panel.

### Audio device

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `Driver` | bool | `false` | Show the audio driver type (ASIO, WDM, CoreAudio, …) |
| `Device` | bool | `false` | Show the audio device selector |
| `Output` | bool | `false` | Show the output channel selector for multi-channel devices |
| `BufferSize` | bool | `false` | Show the audio buffer size selector |
| `SampleRate` | bool | `false` | Show the supported sample rates |

### Engine

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `VoiceAmount` | bool | `false` | Show the voice limit per sound generator |
| `StreamingMode` | bool | `false` | Show the SSD / HD streaming mode toggle (for older drives) |
| `GraphicRendering` | bool | `false` | Show the software / OpenGL renderer toggle |
| `SustainCC` | bool | `false` | Show the sustain pedal CC remap (default CC64) |
| `GlobalBPM` | bool | `false` | Show a manual BPM input (replaces "Sync to host" in standalone builds) |

### UI / project

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `ScaleFactor` | bool | `false` | Show the UI zoom selector |
| `ScaleFactorList` | Array | `[]` | Zoom factors offered by the selector — e.g. `[0.5, 1.0, 1.5]` |
| `SampleLocation` | bool | `false` | Show the sample folder location and a "Relocate" button |
| `ClearMidiCC` | bool | `false` | Show a "Clear MIDI CC" button that resets all MIDI learn assignments |
| `DebugMode` | bool | `false` | Show a "Toggle Debug" button that creates a log file for support |

> [!Warning:Zoom auto-caps at 85% on small screens] If the host screen height is smaller than the interface height at 100% (minus the OS toolbar), HISE silently drops the scale factor to 85% so the UI is not clipped. Plan your default interface size around 1080p so users with smaller monitors do not see an unexpected zoom level.

> [!Warning:Settings.setZoomLevel() has no effect in onInit] The XML zoom value in app data is read **after** onInit, so calling `Settings.setZoomLevel()` from there is overwritten by the persisted value. Drive zoom from a UI control callback (e.g. a panel or combobox) so the call happens once the engine is fully initialised.

The `ColourData` object can be used to set colours for the default rendering:

| Colour ID | Description |
|-----------|-------------|
| `bgColour` | Background colour |
| `textColour` | Label and value text colour |
| `itemColour1` | Combobox / toggle accent colour |

## Notes

- The audio-device rows (`Driver`, `Device`, `Output`, `BufferSize`, `SampleRate`) only have meaning in a standalone build. Hide them in plugin builds by gating with `HiseDeviceSimulator.isStandalone()` and only setting them to `true` for the standalone target.
- `ScaleFactorList` is required for `ScaleFactor` to be useful. Without it, the combobox falls back to a default range that may not match the resolutions your interface was authored against.
- `SampleLocation` shows the current sample folder and lets the user pick a new one. After relocation HISE prompts for a relaunch — handle this gracefully in the UI.
- This content type uses no LAF callbacks. To skin the panel beyond the colour data, build your own settings page using ScriptComponents and the `Settings` scripting API.

> [!Tip:Always include the audio driver rows in standalone builds] Standalone projects without `Driver` / `Device` / `Output` exposed have no recovery path when the saved audio settings are invalid (e.g. driver removed, sample rate unsupported) — users get an "audio device could not be opened" dialog with no way to fix it. Always show these rows in standalone builds, even if you hide them in plugin builds.

> [!Tip:Discover styleable element names with trace()] CustomSettings buttons (Sample Location, Relocate, etc.) can be skinned via the `Popup` LAF callbacks, but their `obj.text` strings are case-sensitive and not documented. Add `Console.print(trace(obj));` inside your LAF function and trigger the button to log every property — this reveals the exact `obj.text` string to match against.

**See also:** $API.Engine$ -- engine API used by individual setting rows, $API.Settings$ -- programmatic access to the same settings data, $API.ScriptFloatingTile$ -- scripting API for the floating tile wrapper
