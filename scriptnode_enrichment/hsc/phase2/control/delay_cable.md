# control.delay_cable - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/control/delay_cable.md`
- Reference: `scriptnode_enrichment/output/control/delay_cable.md`

## Naming

- Module ID: `StaggeredOscillatorGates`
- Network ID: `staggered_oscillator_gates`

## Graph Plan

```text
staggered_oscillator_gates
  GateTimer              control.timer
  DelayedGate            control.delay_cable
  FixedOscillators       container.no_midi
    ImmediateTone        core.oscillator
    DelayedTone          core.oscillator
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - HISE development use only; do not present the timer-based example as export-safe.
- Channel/routing setup:
  - Required channels: default stereo
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: [development-only timer constraint]

## Public Parameters

- DelaySamples -> `DelayedGate.DelayTimeSamples` matched
- Target range before connection: `[0, 22050]`, step `1`
- Macro range: `[0, 22050]`, step `1`
- Default: `4410`
- Interval -> `GateTimer.Interval` matched
- Target range before connection: `[100, 1000]`
- Macro range: `[100, 1000]`
- Default: `500`

## Defaults To Omit

- `DelayedGate.Value` default `0.0`
- `DelayedGate.DelayTimeSamples` default `0`

## Locked Build Values

- `GateTimer.Mode` property = `Toggle`
- `GateTimer.Interval` = `500`
- `GateTimer` output -> `ImmediateTone.Gate` matched
- `GateTimer` output -> `DelayedGate.Value` unscaled
- `DelayedGate` output -> `DelayedTone.Gate` unscaled
- `ImmediateTone.Mode` = `Sine`, Frequency = `220`, Gain = `0.2`
- `DelayedTone.Mode` = `Sine`, Frequency = `330`, Gain = `0.2`

## Friction Comments To Weave In

- Before `DelayedGate`: delay is counted in samples during processing, and zero still delivers on the next callback.
- Before queue-overwrite verification: only one value is pending; a newer change replaces it and resets the counter.
- Before builder setup: control.timer has a documented crash risk outside HISE development use.

## Cosmetic Plan

- Main node: `DelayedGate`
- Accent colour: `0xFF8E44AD`
- Supporting relevant nodes: [`GateTimer`, `ImmediateTone`, `DelayedTone`]
- Supporting colour: `0xFF7F6A91`
- Folded nodes: [`FixedOscillators`]
- Nodes that must stay visible: [`GateTimer`, `DelayedGate`, `ImmediateTone`, `DelayedTone`]

## Open Questions

- None
