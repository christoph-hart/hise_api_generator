# math.clip - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/math/clip.md`
- Reference: `scriptnode_enrichment/output/math/clip.md`

## Naming

- Module ID: `HardClipShaper`
- Network ID: `hard_clip_shaper`

## Graph Plan

```text
hard_clip_shaper
  SlowRamp              core.ramp
  RampOffset            math.add
  HardClipper           math.clip
  OutputPeak            core.peak
  SignalClear           math.clear
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - None
- Channel/routing setup:
  - Required channels: default stereo; a mirrored slow test ramp is sufficient
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: []

## Public Parameters

- ClipLimit -> `HardClipper.Value` matched
- Target range before connection: `[0.1, 0.6]`
- Macro range: `[0.1, 0.6]`
- Default: `0.35`

## Defaults To Omit

- `SignalClear.Value` default `0.0`

## Locked Build Values

- None

## Friction Comments To Weave In

- Before `create_parameter`: narrow the clip limit so the example always shows a visible plateau instead of silently passing the ramp through at the 1.0 default.

## Cosmetic Plan

- Main node: `HardClipper`
- Accent colour: `0xFF2F80ED`
- Supporting relevant nodes: [`SlowRamp`, `RampOffset`, `OutputPeak`]
- Supporting colour: `0xFF6F8FAF`
- Folded nodes: [`SignalClear`]
- Nodes that must stay visible: [`SlowRamp`, `HardClipper`, `OutputPeak`]

## Open Questions

- None
