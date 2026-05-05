## createTimerObject

**Examples:**


```javascript:deferred-sample-map-loading
// Title: Deferred sample map loading to avoid audio thread hitches
// Context: Loading a sample map synchronously from a UI callback
// causes an audio dropout. This timer-based polling pattern defers
// the load to the message thread with a short check interval.

const var sampler = Synth.getSampler("Sampler1");
const var sampleMaps = Sampler.getSampleMapList();

reg lastMapIndex = 0;
reg currentMapIndex = 0;

const var loadTimer = Engine.createTimerObject();

loadTimer.setTimerCallback(function()
{
    if (lastMapIndex != currentMapIndex)
    {
        sampler.loadSampleMap(sampleMaps[currentMapIndex]);
        lastMapIndex = currentMapIndex;
    }
});

// 50ms polling gives near-instant response without busy-waiting
loadTimer.startTimer(50);

// Call this from a combo box callback to request a load
inline function onInstrumentChanged(component, value)
{
    if (value)
        currentMapIndex = parseInt(value - 1);
};
```
```json:testMetadata:deferred-sample-map-loading
{
  "testable": false,
  "skipReason": "Requires a Sampler module named 'Sampler1' in the module tree with loaded sample maps."
}
```
