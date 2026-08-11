---
id: math.pack.sliderpack-lookup-shaper
node: math.pack
domain: scriptnode
category: dsp-network
title: SliderPack lookup shaper
summary: Uses math.pack with an external SliderPack slot seeded from Interface onInit to create a visible lookup shape.
useCase: Use this when a lookup response should come from editable SliderPack step data rather than scalar parameters.
difficulty: intermediate
networkName: sliderpack_lookup_shaper
moduleType: ScriptFX
moduleId: SliderPackLookupShaper
tags:
  - sliderpack
  - lookup
  - external-data
  - stepped-shape
aliases:
  - SliderPack lookup table
  - pack shaper
relatedNodes:
  - math.pack
  - core.ramp
  - core.peak
  - math.clear
parameters:
  PackLookup.SliderPack: External SliderPack slot index 0 initialized from Interface onInit.
  SlowRamp.PeriodTime: Slow scan period used to make the pack lookup visible.
---

scriptnode example: math.pack

SliderPack lookup shaper.
Use this to demonstrate `math.pack` reading deterministic external SliderPack data as a lookup table.

Graph:
```text
sliderpack_lookup_shaper
  SlowRamp              core.ramp
  PackLookup            math.pack
  OutputPeak            core.peak
  SignalClear           math.clear
```

Host:
  Module: `SliderPackLookupShaper`
  Type: `ScriptFX`
  Network: `sliderpack_lookup_shaper`
  Routing: default stereo
  Builder setup: `add ScriptFX as "SliderPackLookupShaper"`, then set its network to `sliderpack_lookup_shaper`.

Support nodes:
  Required: `core.ramp`, `core.peak`, `math.clear`

Key rules:
  - Use external SliderPack data index `0`; embedded complex data cannot be initialized from Interface script.
  - Initialize the SliderPack in Interface `onInit` with `Synth.getSliderPackProcessor("SliderPackLookupShaper").getSliderPack(0)`.
  - Set the slider count before writing the deterministic values.

Public controls:
  - None. The public interaction is the external SliderPack shape.

HISE CLI build commands:
```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id SliderPackLookupShaper --agent
hise-cli builder set --module SliderPackLookupShaper --network sliderpack_lookup_shaper --agent
hise-cli dsp add --module SliderPackLookupShaper --type core.ramp --id SlowRamp --agent
hise-cli dsp set --module SliderPackLookupShaper --node SlowRamp --param PeriodTime --value 1000 --agent
hise-cli dsp add --module SliderPackLookupShaper --type math.pack --id PackLookup --agent
hise-cli dsp set-complex-data --module SliderPackLookupShaper --node PackLookup --type SliderPack --index 0 --agent
hise-cli dsp add --module SliderPackLookupShaper --type core.peak --id OutputPeak --agent
hise-cli dsp add --module SliderPackLookupShaper --type math.clear --id SignalClear --agent
hise-cli script set --module-id Interface --callback onInit --stdin --agent <<'HISESCRIPT'
Content.makeFrontInterface(600, 600);

const var packProcessor = Synth.getSliderPackProcessor("SliderPackLookupShaper");
const var packData = packProcessor.getSliderPack(0);

packData.setNumSliders(8);
packData.setAllValues([0.0, 0.85, 0.25, 1.0, 0.45, 0.7, 0.1, 0.55]);
HISESCRIPT
```
