# control.pack2_writer - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/control/pack2_writer.md`
- Reference: `scriptnode_enrichment/output/control/pack2_writer.md`

## Naming

- Module ID: `TwoStepFilterAlternator`
- Network ID: `two_step_filter_alternator`

## Graph Plan

```text
two_step_filter_alternator
  StepWriter             control.pack2_writer
  StepClock              core.clock_ramp
  StepReader             control.cable_pack
  AlternatingFilter      filters.svf
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - Initialize shared external SliderPack slot 0 in Interface `onInit` before applying writer values.
- Channel/routing setup:
  - Required channels: default stereo
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: []

## Public Parameters

- Step1 -> `StepWriter.Value1` matched; target and macro range `[0, 1]`; default `0.2`
- Step2 -> `StepWriter.Value2` matched; target and macro range `[0, 1]`; default `0.8`

## Defaults To Omit

- `StepWriter.Value1` default `0.0`
- `StepWriter.Value2` default `0.0`

## Locked Build Values

- `StepWriter.SliderPack` and `StepReader.SliderPack` external data index = `0`
- Interface `onInit`: `const var stepProcessor = Synth.getSliderPackProcessor("TwoStepFilterAlternator");`
- Interface `onInit`: `const var stepData = stepProcessor.getSliderPack(0);`
- Writer connection resizes pack to exactly `2`; Value1 -> index 0, Value2 -> index 1.
- `StepClock.Mode = Synced`, Multiplier = `1/2`, AddToSignal = `Off`, Inactive = `0`
- `StepClock` output -> `StepReader.Value` matched; reader output -> filter Frequency `[250, 7000]`
- `AlternatingFilter.Mode = LowPass`, Smoothing = `0.01`

## Friction Comments To Weave In

- Before data setup: external slot 0 is required for deterministic script initialization.
- Before writer connection: the writer automatically resizes the shared pack to exactly two entries.
- Before verification: pack display notification is asynchronous even though control state updates immediately.

## Cosmetic Plan

- Main node: `StepWriter`
- Accent colour: `0xFF8E44AD`
- Supporting relevant nodes: [`StepClock`, `StepReader`, `AlternatingFilter`]
- Supporting colour: `0xFF7F6A91`
- Folded nodes: []
- Nodes that must stay visible: [`StepWriter`, `StepReader`, `AlternatingFilter`]

## Open Questions

- None
