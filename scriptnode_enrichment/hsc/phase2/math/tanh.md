# math.tanh - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/math/tanh.md`
- Reference: `scriptnode_enrichment/output/math/tanh.md`

## Naming

- Module ID: `SoftSaturationShaper`
- Network ID: `soft_saturation_shaper`

## Graph Plan

```text
soft_saturation_shaper
  SlowRamp              core.ramp
  SoftClipper           math.tanh
  OutputPeak            core.peak
  SignalClear           math.clear
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - None
- Channel/routing setup:
  - Required channels: default stereo; a mirrored slow transfer-curve signal is enough
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: []

## Public Parameters

- Drive -> `SoftClipper.Value` matched
- Target range before connection: `[0.4, 1.0]`
- Macro range: `[0.4, 1.0]`
- Default: `0.75`

## Defaults To Omit

- `OutputPeak.Value` default `0.0`
- `SignalClear.Value` default `0.0`

## Locked Build Values

- None

## Friction Comments To Weave In

- Before `create_parameter`: keep the drive range high enough that the displayed curve is visibly rounded instead of nearly linear.

## Cosmetic Plan

- Main node: `SoftClipper`
- Accent colour: `0xFF2F80ED`
- Supporting relevant nodes: [`SlowRamp`, `OutputPeak`]
- Supporting colour: `0xFF6F8FAF`
- Folded nodes: [`SignalClear`]
- Nodes that must stay visible: [`SlowRamp`, `SoftClipper`, `OutputPeak`]

## Open Questions

- None
