## print

**Examples:**

```javascript
// Title: Tracing a state machine during development
// Context: Console.print calls left in production code serve as
// built-in documentation of control flow. They are no-ops in
// exported plugins, so there is no reason to remove them.

inline function onExportStateChanged(newState)
{
    local NAMES = ["Idle", "Preparing", "Bouncing", "Writing", "Done"];
    Console.print("New export state: " + NAMES[newState]);

    if (newState == 2)
        Console.print("Bouncing... " + parseInt(progress * 100) + "%");

    if (newState == 4)
        Console.print("Export complete");
}
```

```javascript
// Title: Logging structured data with trace()
// Context: For arrays and objects, Console.print shows "[object Array]"
// unless you wrap the value in trace() first.

const var filters = [
    { "name": "Bass", "active": true },
    { "name": "Mid", "active": false }
];

Console.print(trace(filters));
// [{name: "Bass", active: 1}, {name: "Mid", active: 0}]

Console.print(filters);
// [object Array] -- not useful
```
