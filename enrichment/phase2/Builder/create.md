## create

**Examples:**


```javascript:conditional-build-flags
// Title: Conditional build flags for selective rebuilding
// Context: Large Builder scripts benefit from boolean flags that enable/disable
// subsections. This lets you iterate on one part of the tree without rebuilding
// everything, which speeds up development significantly.

const var BUILD_CHANNELS = 1;
const var BUILD_MASTER_FX = 1;
const var BUILD_SENDS = 0; // Disabled while working on channels

const var b = Synth.createBuilder();
b.clear();

if (BUILD_CHANNELS)
{
    for (i = 0; i < NUM_CHANNELS; i++)
        buildChannel(i);
}

if (BUILD_MASTER_FX)
{
    b.create(b.Effects.CurveEq, "MasterEQ", 0, b.ChainIndexes.FX);
    b.create(b.Effects.SimpleGain, "MasterGain", 0, b.ChainIndexes.FX);
}

if (BUILD_SENDS)
    buildSendEffects();

b.flush();
```
```json:testMetadata:conditional-build-flags
{
  "testable": false,
  "skipReason": "References undefined helper functions (buildChannel, buildSendEffects) and constants (NUM_CHANNELS) from a separate code context"
}
```
