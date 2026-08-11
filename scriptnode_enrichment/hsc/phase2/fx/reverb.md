# fx.reverb - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/fx/reverb.md`
- Reference: `scriptnode_enrichment/output/fx/reverb.md`

## Naming

- Module ID: `WetReverbWrapper`
- Network ID: `wet_reverb_wrapper`

## Graph Plan

```text
wet_reverb_wrapper
  RoomMix         template.dry_wet
    RoomMix_wet_path
      RoomVerb    fx.reverb
      RoomMix_wet_gain
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - Template wet-path dummy must be removed after inserting `RoomVerb` before the wet gain.
  - Reorder `RoomVerb` to index `0` and `RoomMix_wet_gain` to index `1` so the wet reverb is processed before the template's wet gain.
- Channel/routing setup:
  - Required channels: default stereo
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: []

## Public Parameters

- Mix -> `RoomMix.DryWet` matched
- Target range before connection: `[0, 1]`
- Macro range: `[0, 1]`
- Default: `0.35`
- Size -> `RoomVerb.Size` matched
- Target range before connection: `[0.1, 0.9]`
- Macro range: `[0.1, 0.9]`
- Default: `0.65`
- Damping -> `RoomVerb.Damping` matched
- Target range before connection: `[0, 1]`
- Macro range: `[0, 1]`
- Default: `0.45`

## Defaults To Omit

- `RoomVerb.Damping` default `0.5`
- `RoomVerb.Width` default `0.5`
- `RoomVerb.Size` default `0.5`

## Locked Build Values

- Do not expose `RoomVerb.Width` in the public example unless Phase 3 proves the implementation bug has been fixed.
- `RoomVerb.Size.range` = `[0.1, 0.9]`
- `RoomMix.DryWet` = `0.35`
- Preserve the template-owned dry/wet connections: `RoomMix_dry_wet_mixer.0 -> RoomMix_dry_gain.Gain` and `RoomMix_dry_wet_mixer.1 -> RoomMix_wet_gain.Gain`.

## Friction Comments To Weave In

- Before `template.dry_wet`: `fx.reverb` outputs wet signal only, so a practical insert needs an external dry/wet mixer.
- Before reordering the wet path: keep `RoomVerb` before `RoomMix_wet_gain`, because the template's wet gain must remain the last wet-path node.
- Before public parameters: `fx.reverb` is a shared monophonic reverb processor, not per-voice state.
- Before omitting Width: current exploration found `Width` writes damping, so the public example exposes the reliable room controls only.

## Cosmetic Plan

- Main node: `RoomVerb`
- Accent colour: `0xFF2F80ED`
- Supporting relevant nodes: [`RoomMix`]
- Supporting colour: `0xFF6F8FAF`
- Folded nodes: []
- Nodes that must stay visible: [`RoomMix`, `RoomVerb`]

## Open Questions

- Phase 3 should verify whether the `Width` setter bug is still present. If fixed, add Width as a public parameter and update this plan.
