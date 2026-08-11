# math.pack - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/math/pack.md`
- Reference: `scriptnode_enrichment/output/math/pack.md`

## Naming

- Module ID: `SliderPackLookupShaper`
- Network ID: `sliderpack_lookup_shaper`

## Graph Plan

```text
sliderpack_lookup_shaper
  SlowRamp              core.ramp
  PackLookup            math.pack
  OutputPeak            core.peak
  SignalClear           math.clear
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - None
- Channel/routing setup:
  - Required channels: default stereo; the slow lookup scan can stay mirrored across both lanes
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: []

## Public Parameters

- None

## Defaults To Omit

- `OutputPeak.Value` default `0.0`
- `SignalClear.Value` default `0.0`

## Locked Build Values

- `SlowRamp.PeriodTime` = `1000`
- `PackLookup.SliderPack` external data index = `0`
- Interface `onInit` must create `const var packProcessor = Synth.getSliderPackProcessor("SliderPackLookupShaper");`
- Interface `onInit` must create `const var packData = packProcessor.getSliderPack(0);`
- SliderPack startup values = `[0.0, 0.85, 0.25, 1.0, 0.45, 0.7, 0.1, 0.55]`

## Friction Comments To Weave In

- Before the complex-data setup: this node has no automatable parameters, so the user-facing interaction is the connected SliderPack shape rather than a matched macro.
- Before `set_complex_data PackLookup.SliderPack index 0`: use an external slot because embedded complex data cannot be initialized from Interface script.

## Cosmetic Plan

- Main node: `PackLookup`
- Accent colour: `0xFF2F80ED`
- Supporting relevant nodes: [`SlowRamp`, `OutputPeak`]
- Supporting colour: `0xFF6F8FAF`
- Folded nodes: [`SignalClear`]
- Nodes that must stay visible: [`SlowRamp`, `PackLookup`, `OutputPeak`]

## Open Questions

- None
