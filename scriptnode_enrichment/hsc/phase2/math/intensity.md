# math.intensity - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/math/intensity.md`
- Reference: `scriptnode_enrichment/output/math/intensity.md`

## Naming

- Module ID: `UnityAnchoredDepth`
- Network ID: `unity_anchored_depth`

## Graph Plan

```text
unity_anchored_depth
  SlowRamp              core.ramp
  UnityDepth            math.intensity
  OutputPeak            core.peak
  SignalClear           math.clear
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - None
- Channel/routing setup:
  - Required channels: default stereo; the modulation-style ramp is mirrored on both channels
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: []

## Public Parameters

- Depth -> `UnityDepth.Value` matched
- Target range before connection: `[0.0, 1.0]`
- Macro range: `[0.0, 1.0]`
- Default: `0.4`

## Defaults To Omit

- `OutputPeak.Value` default `0.0`
- `SignalClear.Value` default `0.0`

## Locked Build Values

- None

## Friction Comments To Weave In

- Before `UnityDepth`: note that this node crossfades between unity and the input signal, so it keeps the top of the range anchored at 1.0 unlike `math.mul`.

## Cosmetic Plan

- Main node: `UnityDepth`
- Accent colour: `0xFF2F80ED`
- Supporting relevant nodes: [`SlowRamp`, `OutputPeak`]
- Supporting colour: `0xFF6F8FAF`
- Folded nodes: [`SignalClear`]
- Nodes that must stay visible: [`SlowRamp`, `UnityDepth`, `OutputPeak`]

## Open Questions

- None
