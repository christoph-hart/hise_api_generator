## assertTrue

**Examples:**

```javascript
// Title: Guard clauses in a data-binding utility
// Context: Validate preconditions at the start of utility functions
// that access panel data properties. Each assertion targets a specific
// failure mode that would otherwise produce a cryptic error downstream.

inline function setProperty(panel, name, value)
{
    Console.assertTrue(isDefined(panel));
    Console.assertTrue(isDefined(name));
    Console.assertTrue(panel.get("type") == "ScriptPanel");
    Console.assertTrue(isDefined(panel.data[name]));

    panel.data[name] = value;
}
```

```javascript
// Title: Unreachable code marker
// Context: In a lookup function that must always find a match,
// Console.assertTrue(false) marks the unreachable path. If the
// loop exits without returning, the assertion fires immediately.

inline function findNameByKey(key)
{
    for (entry in DATA_LIST)
        if (entry.Key == key)
            return entry.Name;

    // If we get here, the key was not in DATA_LIST - a programming error
    Console.assertTrue(false);
    return "";
}
```

```javascript
// Title: Validating a whitelist of allowed keys
// Context: When a function accepts a string key that must be one of
// a known set, assertTrue with indexOf catches typos at the call site.

inline function changeSetting(key, value)
{
    Console.assertTrue(["AutoPlay", "Volume", "Quality"].indexOf(key) != -1);

    settings[key] = value;
    getSettingsFile().writeObject(settings);
}
```
