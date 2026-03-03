## clear

**Examples:**

```javascript
// Title: Isolating output before a batch operation
// Context: Clear the console before a multi-step operation so its
// output is easy to read without scrolling past prior noise.

inline function onBatchExportButtonControl(component, value)
{
    if (!value) return;

    Console.clear();
    Console.print("Starting batch export of " + presetList.length + " presets...");

    for (i = 0; i < presetList.length; i++)
    {
        Console.print("Exporting: " + presetList[i].Name);
        // ... export logic
    }

    Console.print("Batch export complete");
}
```
