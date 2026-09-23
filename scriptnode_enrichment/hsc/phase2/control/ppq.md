# control.ppq - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/control/ppq.md`
- Reference: `scriptnode_enrichment/output/control/ppq.md`

## Naming

- Module ID: `PhrasePositionStartPan`
- Network ID: `phrase_position_start_pan`

## Graph Plan

```text
phrase_position_start_pan
  PhrasePosition         control.ppq
  StartPositionPan       jdsp.jpanner
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - Use a host with real transport and a centered mono source duplicated to stereo.
- Channel/routing setup:
  - Required channels: default stereo
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: [host start, seek, and loop events required]

## Public Parameters

- None

## Defaults To Omit

- `PhrasePosition.Multiplier` default `1`

## Locked Build Values

- `PhrasePosition.Tempo` = `1/4`
- `PhrasePosition.Multiplier` = `4`
- Effective position window = `1 bar`
- `PhrasePosition` output -> `StartPositionPan.Pan` range = `[-1, 1]`
- `StartPositionPan.Rule` = `ConstantPower`

## Friction Comments To Weave In

- Before `PhrasePosition`: PPQ is a snapshot on transport start and position jumps, not a continuously moving ramp.
- Before verification: a stopped ruler move emits only when playback starts again.
- Before topology: do not substitute clock_ramp because continuous output would contradict the example.

## Cosmetic Plan

- Main node: `PhrasePosition`
- Accent colour: `0xFF8E44AD`
- Supporting relevant nodes: [`StartPositionPan`]
- Supporting colour: `0xFF7F6A91`
- Folded nodes: []
- Nodes that must stay visible: [`PhrasePosition`, `StartPositionPan`]

## Open Questions

- None
