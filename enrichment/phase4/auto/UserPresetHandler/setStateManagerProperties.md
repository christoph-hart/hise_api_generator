Configures where MIDI CC assignments, MPE configuration, and macro connections are saved and restored. Call this once during initialisation with a static JSON object.

By default, these states are stored in both user presets and the DAW plugin state. Use `SubStates` to choose a different persistence policy for each supported state:

| State ID | Content |
|----------|---------|
| `MidiAutomation` | MIDI CC-to-parameter assignments |
| `MPEData` | MPE mode and modulator connections |
| `macro_controls` | Macro-to-parameter connections and macro values |

Each state accepts one of these target strings:

| Target | Behaviour |
|--------|-----------|
| `"Default"` | Store in both user presets and the DAW plugin state |
| `"PluginState"` | Keep per-instance state in the DAW session without changing it during preset browsing |
| `"UserPreset"` | Treat the state as patch data without storing it in the DAW state |
| `"External"` | Automatically load and save through one external XML file |
| `"None"` | Exclude the state from automatic persistence |

You can also pass an array of targets. `["PluginState", "UserPreset"]` is equivalent to `"Default"`. `"External"` cannot be combined with a preset target.

The configuration object supports these properties:

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `SubStates` | Object | `{}` | Maps supported state IDs to target strings or arrays |
| `ExternalFile` | String | App-data `ExternalPresetData.xml` | Absolute path of the external XML file |
| `ExternalFileDefault` | Object | undefined | JSON defaults used when the external file is missing or cannot be parsed |

For production, omit `ExternalFile` to use the product's app-data directory. This location is writable and appropriate for installed plugins. A desktop path is useful only while developing and inspecting the generated XML.

If valid external XML already exists, it always takes precedence over `ExternalFileDefault`. Otherwise, defaults are applied only to states targeting `"External"`, then the XML file is created. `ExternalFileDefault.MidiAutomation` uses the exact array returned by [MidiAutomationHandler.getAutomationDataObject()]($API.MidiAutomationHandler.getAutomationDataObject$) and its update callback. `ExternalFileDefault.macro_controls` uses the array returned by [MacroHandler.getMacroDataObject()]($API.MacroHandler.getMacroDataObject$).

Each `MidiAutomation` array element supports these fields:

| Field | Type | Meaning |
|-------|------|---------|
| `Controller` | int | MIDI CC number from 0 to 127 |
| `Channel` | int | One-based MIDI channel, or `-1` for omni |
| `Processor` | String | Target processor ID |
| `Attribute` | String | Target parameter or custom automation ID |
| `MacroIndex` | int | Macro slot index, or `-1` for direct mapping |
| `Start` / `End` | double | Active mapping range |
| `FullStart` / `FullEnd` | double | Complete settable range |
| `Skew` | double | Range skew factor |
| `Interval` | double | Range step size |
| `Inverted` | bool | Whether the mapping direction is inverted |
| `Converter` | String | Encoded value-to-text converter |

Each `macro_controls` array element supports these fields:

| Field | Type | Meaning |
|-------|------|---------|
| `MacroIndex` | int | Zero-based macro slot index |
| `Processor` | String | Target processor ID |
| `Attribute` | String or int | Target parameter ID, custom automation ID, or parameter index |
| `CustomAutomation` | bool | Whether `Attribute` identifies custom automation |
| `Start` / `End` | double | Active macro range |
| `FullStart` / `FullEnd` | double | Complete parameter range |
| `Skew` | double | Range skew factor |
| `Interval` | double | Range step size |
| `Inverted` | bool | Whether the mapping direction is inverted |
| `converter` | String | Optional value-to-text converter |

This example keeps MIDI mappings in a shared external file while retaining MPE state independently for each DAW instance:

```js
const var uph = Engine.createUserPresetHandler();

uph.setStateManagerProperties({
    SubStates:
    {
        MidiAutomation: "External",
        MPEData: "PluginState"
    }
});
```

For temporary development inspection, you can override the file and query the resulting setup:

```js
const var uph = Engine.createUserPresetHandler();

// Development only. Do not ship a desktop path in an installed product.
const var EXTERNAL_FILE = FileSystem.getFolder(FileSystem.Desktop)
                                    .getChildFile("Mappings.xml")
                                    .toString(0);

uph.setStateManagerProperties({
    SubStates:
    {
        MidiAutomation: "External",
        MPEData: "PluginState"
    },
    ExternalFile: EXTERNAL_FILE
});

Console.print(trace(uph.getStateManagersForTarget("External")));
Console.print(trace(uph.getStateManagersForTarget("UserPreset")));
Console.print(trace(uph.getStateManagersForTarget("PluginState")));
```

Multiple instances using the same external path share the file, but they are not live-synchronised. Each instance reads it during initialisation and writes its complete external state after a relevant change, so the latest write wins. Use [getStateManagersForTarget()]($API.UserPresetHandler.getStateManagersForTarget$) during development to verify the effective configuration.
