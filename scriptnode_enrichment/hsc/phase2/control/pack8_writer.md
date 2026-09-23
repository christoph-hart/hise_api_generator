# control.pack8_writer - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/control/pack8_writer.md`
- Reference: `scriptnode_enrichment/output/control/pack8_writer.md`

## Naming

- Module ID: `EightStepCutoffProgrammer`
- Network ID: `eight_step_cutoff_programmer`

## Graph Plan

```text
eight_step_cutoff_programmer
  StepWriter             control.pack8_writer
  BarClock               core.clock_ramp
  StepReader             control.cable_pack
  ProgrammedFilter       filters.svf
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - Initialize shared external SliderPack slot 0 before applying writer values.
- Channel/routing setup:
  - Required channels: default stereo
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: []

## Public Parameters

- Step1..Step8 -> `StepWriter.Value1..Value8` matched over `[0, 1]`
- Defaults: `0.15, 0.7, 0.3, 0.9, 0.25, 0.6, 0.4, 1.0`

## Defaults To Omit

- `StepWriter.Value1..Value8` defaults `0.0`

## Locked Build Values

- `StepWriter.SliderPack` and `StepReader.SliderPack` external data index = `0`
- Interface pattern = `Synth.getSliderPackProcessor("EightStepCutoffProgrammer").getSliderPack(0)`
- Writer resizes pack to `8`; Value1..Value8 map to indices `0..7`.
- `BarClock.Mode = Synced`, Multiplier = `1 Bar`, AddToSignal = `Off`, Inactive = `0`
- Clock -> reader matched `[0, 1]`; reader -> filter Frequency `[200, 8000]`
- `ProgrammedFilter.Mode = LowPass`, Q = `0.7`, Smoothing = `0.01`

## Friction Comments To Weave In

- Before data setup: script-modified sequence data requires external slot 0.
- Before writer connection: this largest fixed writer resizes the pack to exactly eight entries.
- Before verification: each Value owns one exact index and UI notification may lag the immediate control update.

## Cosmetic Plan

- Main node: `StepWriter`
- Accent colour: `0xFF8E44AD`
- Supporting relevant nodes: [`BarClock`, `StepReader`, `ProgrammedFilter`]
- Supporting colour: `0xFF7F6A91`
- Folded nodes: []
- Nodes that must stay visible: [`StepWriter`, `StepReader`, `ProgrammedFilter`]

## Open Questions

- None
