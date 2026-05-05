## setEffect

**Examples:**


```javascript:builder-hardcoded-master-fx
// Title: Builder API with compiled DSP networks in HardcodedMasterFX
// Context: A multi-channel instrument that programmatically builds its
// signal chain, creating HardcodedMasterFX modules and loading compiled
// scriptnode networks into them through the SlotFX interface.

const var b = Synth.createBuilder();
b.clear();

// Create a channel strip with EQ, compressor, and filter
inline function buildChannelStrip(channelIndex)
{
    local eq = b.create(
        b.Effects.HardcodedMasterFX,
        "ChannelEq " + (channelIndex + 1),
        0,
        b.ChainIndexes.FX
    );

    // Load a compiled DSP network into the HardcodedMasterFX slot
    b.get(eq, b.InterfaceTypes.SlotFX).setEffect("fourband_eq");

    // Start bypassed -- user enables per preset
    b.get(eq, b.InterfaceTypes.Effect).setBypassed(true);

    local comp = b.create(
        b.Effects.HardcodedMasterFX,
        "ChannelComp " + (channelIndex + 1),
        0,
        b.ChainIndexes.FX
    );

    b.get(comp, b.InterfaceTypes.SlotFX).setEffect("compressor");
    b.get(comp, b.InterfaceTypes.Effect).setBypassed(true);
}

buildChannelStrip(0);
buildChannelStrip(1);
b.flush();
```
```json:testMetadata:builder-hardcoded-master-fx
{
  "testable": false,
  "skipReason": "Requires compiled scriptnode networks (fourband_eq, compressor) in the project"
}
```

**Pitfalls:**
- When managing multiple SlotFX instances in an array, avoid looking up the loaded effect by its internal child name (e.g., `Synth.getEffect("SlotName_EffectType")`). The internal naming convention is an implementation detail. Always use the `Effect` handle returned directly by `setEffect()`.
