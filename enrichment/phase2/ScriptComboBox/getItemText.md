## getItemText

**Examples:**

```javascript:load-sample-map-by-text
// Title: Load a sample map by selected item text
// Context: The combo box items match sample map names exactly, so getItemText()
// provides the string needed by loadSampleMap() without any index conversion.

const var mapList = Sampler.getSampleMapList();

const var cbMap = Content.addComboBox("MapSelector", 0, 0);
cbMap.set("items", mapList.join("\n"));
cbMap.set("saveInPreset", false);

inline function onMapChanged(component, value)
{
    Console.print("Selected map: " + component.getItemText());
}

cbMap.setControlCallback(onMapChanged);
```
```json:testMetadata:load-sample-map-by-text
{
  "testable": false,
  "skipReason": "Requires a sampler module and loaded sample maps to produce meaningful output"
}
```


**Pitfalls:**
- When `useCustomPopup` is enabled, submenu prefixes are stripped from the returned text. An item stored as `"Filters::LowPass"` returns `"LowPass"`, not the full path. If you need the full path for lookup purposes, maintain a parallel data array indexed by `parseInt(value) - 1` instead of relying on `getItemText()`.
