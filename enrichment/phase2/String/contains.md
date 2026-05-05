## contains

**Examples:**


```javascript:dispatch-by-id-content
// Title: Dispatch logic based on component ID content
// Context: A single callback handles multiple component types by
// checking which keyword the ID contains, combined with
// getTrailingIntValue for the index.

inline function onComboBoxChanged(component, value)
{
    local id = component.get("id");
    local idx = id.getTrailingIntValue() - 1;
    
    if (id.contains("Unisono"))
        SynthGroups[idx].setAttribute(SynthGroups[idx].VoiceAmount, value);
    else if (id.contains("FilterType"))
        Filters[idx].setAttribute(Filters[idx].Type, value);
    else if (id.contains("Waveform"))
        WaveDisplays[idx].loadFile(waveforms[value - 1]);
}
```
```json:testMetadata:dispatch-by-id-content
{
  "testable": false,
  "skipReason": "Requires SynthGroups, Filters, and WaveDisplays module arrays that cannot be created standalone"
}
```
