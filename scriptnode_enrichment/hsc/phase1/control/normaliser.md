# control.normaliser - HSC Scenario

## Node

- Factory path: `control.normaliser`
- Source page: `scriptnode_enrichment/output/control/normaliser.md`

## Scenario

- Title: Tempo Duration To Delay Mix
- Project context: A tempo-sync source sends raw milliseconds directly to a delay time and also through `control.normaliser` to the effect's Dry/Wet control. Longer rhythmic divisions therefore produce a wetter echo while shorter divisions remain subtler, despite the source and mix using different ranges.
- Teaching goal: Demonstrate how an unscaled native-unit source becomes a normalised signal that can use an unrelated target parameter range.

## Support Nodes

- Required: [`control.tempo_sync`, `template.dry_wet`, `core.fix_delay`]
- Optional: []
- Rationale: `control.tempo_sync` supplies raw millisecond values; `core.fix_delay` consumes those values directly in the wet path; and `template.dry_wet` provides the differently ranged 0 to 1 destination that exposes why a normalisation stage is required.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: no

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Connect `control.tempo_sync` directly to `core.fix_delay.DelayTime` as an unscaled millisecond path and in parallel to `control.normaliser.Value`.
- Set the normaliser Value range to the exact minimum and maximum milliseconds produced by the exposed Tempo choices, then connect its normalised output to a restricted `template.dry_wet.DryWet` range.
- Place `core.fix_delay` in the template wet branch before the required `wet_gain`, and lock a non-zero FadeTime for safe delay-time changes.
- Enable tempo sync explicitly and constrain divisions and multiplier so DelayTime stays within 0 to 1000 ms.
- Verify the shortest and longest divisions map to the intended mix endpoints and an intermediate duration maps smoothly between them.
- Do not describe the normaliser as performing unit conversion. It passes the value through while connection ranges convert source-domain position to target-domain position.
