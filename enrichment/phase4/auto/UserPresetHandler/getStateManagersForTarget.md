Returns an array containing the IDs of all currently registered state managers that match a persistence target. Use this after [setStateManagerProperties()]($API.UserPresetHandler.setStateManagerProperties$) during development to verify the effective configuration.

The supported case-sensitive query strings are:

| Target | Meaning |
|--------|---------|
| `"External"` | State loaded from and automatically saved to the external XML file |
| `"UserPreset"` | State stored in user presets |
| `"PluginState"` | State stored in the DAW plugin state |

A manager using the `"Default"` target appears in both the `"UserPreset"` and `"PluginState"` results. Unknown target strings return an empty array.

The result includes all matching registered managers, including internal and dynamically registered managers that cannot be configured through `SubStates`. Do not depend on an exact array length or ordering; inspect it for the IDs relevant to your project.

```js
const var uph = Engine.createUserPresetHandler();

uph.setStateManagerProperties({
    SubStates:
    {
        MidiAutomation: "External",
        MPEData: "PluginState"
    }
});

Console.print(trace(uph.getStateManagersForTarget("External")));
Console.print(trace(uph.getStateManagersForTarget("UserPreset")));
Console.print(trace(uph.getStateManagersForTarget("PluginState")));
```
