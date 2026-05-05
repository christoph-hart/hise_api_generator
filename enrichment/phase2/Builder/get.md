## get

**Examples:**

```javascript:typed-refs-routing-slotfx
// Title: Typed references for routing, DSP networks, and bypass control
// Context: After creating processors with create(), use get() to obtain typed
// references for operations that need specific interfaces. The most common are
// RoutingMatrix (multi-channel routing), SlotFX (loading DSP networks), and
// Effect (bypass/attribute control).

const var b = Synth.createBuilder();
b.clear();

var container = b.create(b.SoundGenerators.SynthChain,
    "Channel 1", 0, b.ChainIndexes.Direct);
var synth = b.create(b.SoundGenerators.SilentSynth,
    "Synth 1", container, b.ChainIndexes.Direct);

// RoutingMatrix: configure multi-channel audio routing
var matrix = b.get(synth, b.InterfaceTypes.RoutingMatrix);
matrix.setNumChannels(6);
matrix.addConnection(2, 0);
matrix.addConnection(3, 1);

// SlotFX: load a compiled DSP network into a HardcodedFX
var fx = b.create(b.Effects.HardcodedMasterFX,
    "MyEffect", container, b.ChainIndexes.FX);
b.get(fx, b.InterfaceTypes.SlotFX).setEffect("my_dsp_network");

// Effect: control bypass state
b.get(fx, b.InterfaceTypes.Effect).setBypassed(true);

b.flush();
```
```json:testMetadata:typed-refs-routing-slotfx
{
  "testable": false,
  "skipReason": "Requires a compiled DSP network ('my_dsp_network') for setEffect() call"
}
```


**Pitfalls:**
- The `interfaceType` must match the module's actual type. A common mistake is using `b.InterfaceTypes.Effect` on a SlotFX module when you need `b.InterfaceTypes.SlotFX` for `setEffect()` calls. You can chain multiple `get()` calls on the same build index with different interface types to access both interfaces.
