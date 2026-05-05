## setControlCallback

**Examples:**

```javascript:sample-map-selector
// Title: Sample map selector with combo box callback
// Context: A combo box populated from the sample map list drives sample loading.
// The callback uses value-1 to convert from 1-based combo index to 0-based array index.

const var sampleMapList = Sampler.getSampleMapList();

const var cbSampleMap = Content.addComboBox("SampleMapSelector", 0, 0);
cbSampleMap.set("items", sampleMapList.join("\n"));
cbSampleMap.set("saveInPreset", false);

inline function onSampleMapChanged(component, value)
{
    // value arrives as a float (e.g. 1.0), so convert to int for array indexing
    Console.print("Loading map index: " + (parseInt(value) - 1));
}

cbSampleMap.setControlCallback(onSampleMapChanged);
```
```json:testMetadata:sample-map-selector
{
  "testable": false,
  "skipReason": "Requires a sampler module and sample maps in the project"
}
```


