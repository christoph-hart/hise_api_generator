# math.sin - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/math/sin.md`
- Reference: `scriptnode_enrichment/output/math/sin.md`

## Naming

- Module ID: `RampToSineConverter`
- Network ID: `ramp_to_sine_converter`

## Graph Plan

```text
ramp_to_sine_converter
  SlowRamp              core.ramp
  RadianScale           math.pi
  SineShape             math.sin
  DisplayRange          math.sig2mod
  OutputPeak            core.peak
  SignalClear           math.clear
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - None
- Channel/routing setup:
  - Required channels: default stereo; the same slow phase signal drives both lanes
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: []

## Public Parameters

- None

## Defaults To Omit

- `SineShape.Value` default `2.0`
- `DisplayRange.Value` default `0.0`
- `OutputPeak.Value` default `0.0`
- `SignalClear.Value` default `0.0`

## Locked Build Values

- None

## Friction Comments To Weave In

- Before `RadianScale`: keep `math.pi` at the full-cycle setting so one 0..1 ramp produces one sine cycle.
- Before `DisplayRange`: convert the bipolar sine output to 0..1 before the peak display.

## Cosmetic Plan

- Main node: `SineShape`
- Accent colour: `0xFF2F80ED`
- Supporting relevant nodes: [`RadianScale`, `DisplayRange`, `OutputPeak`]
- Supporting colour: `0xFF6F8FAF`
- Folded nodes: [`SignalClear`]
- Nodes that must stay visible: [`SlowRamp`, `RadianScale`, `SineShape`, `DisplayRange`, `OutputPeak`]

## Open Questions

- None
