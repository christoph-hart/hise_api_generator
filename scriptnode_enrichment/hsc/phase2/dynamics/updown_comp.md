# dynamics.updown_comp - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/dynamics/updown_comp.md`
- Reference: `scriptnode_enrichment/output/dynamics/updown_comp.md`

## Naming

- Module ID: `DualThresholdLeveler`
- Network ID: `dual_threshold_leveler`

## Graph Plan

```text
dual_threshold_leveler
  VocalLeveler          dynamics.updown_comp
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - None
- Channel/routing setup:
  - Required channels: fixed stereo only; this example must stay exactly two channels
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: [node is fixed stereo and should not be adapted to mono or wider layouts]

## Public Parameters

- LowThreshold -> `VocalLeveler.LowThreshold` matched
- Target range before connection: `[-60, -30]`
- Macro range: `[-60, -30]`
- Default: `-42`
- HighThreshold -> `VocalLeveler.HighThreshold` matched
- Target range before connection: `[-18, -6]`
- Macro range: `[-18, -6]`
- Default: `-10`
- HighRatio -> `VocalLeveler.HighRatio` matched
- Target range before connection: `[1.5, 8]`
- Macro range: `[1.5, 8]`
- Default: `3`
- RMSMode -> `VocalLeveler.RMS` matched
- Target range before connection: `[Off, On]`
- Macro range: `[Off, On]`
- Default: `On`

## Defaults To Omit

- `VocalLeveler.Attack` default `50`
- `VocalLeveler.Release` default `50`

## Locked Build Values

- None

## Friction Comments To Weave In

- Before `create_parameter`: keep a visible gap between low and high thresholds so the unity zone is obvious.
- Before the stereo setup notes: keep this example strictly stereo, because the node is not intended for mono or wider multichannel layouts.

## Cosmetic Plan

- Main node: `VocalLeveler`
- Accent colour: `0xFFE67E22`
- Supporting relevant nodes: []
- Supporting colour: `0xFF8F7766`
- Folded nodes: []
- Nodes that must stay visible: [`VocalLeveler`]

## Open Questions

- None
