# control.pma_unscaled - HSC Scenario

## Node

- Factory path: `control.pma_unscaled`
- Source page: `scriptnode_enrichment/output/control/pma_unscaled.md`

## Scenario

- Title: Scaled Tempo Delay In Milliseconds
- Project context: A tempo-sync source produces a raw note duration in milliseconds. `control.pma_unscaled` multiplies that native value and adds a small millisecond offset before sending the result directly to a fixed delay.
- Teaching goal: Demonstrate arithmetic in a native unit domain without normalisation, target remapping, or 0 to 1 clamping.

## Support Nodes

- Required: [`control.tempo_sync`, `core.fix_delay`]
- Optional: []
- Rationale: `control.tempo_sync` supplies raw milliseconds to the unscaled Value input, and `core.fix_delay` consumes the resulting raw milliseconds while safely crossfading between changed delay positions.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: yes

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Connect tempo-sync output to `control.pma_unscaled.Value` and PMA output directly to `core.fix_delay.DelayTime`.
- Expose Multiply over a deliberate positive range and Add as a native millisecond offset. `Value` and Add are unscaled, but Multiply is range-scaled and must have its intended control range configured before connection.
- Enable tempo sync explicitly and constrain Tempo, Multiplier, PMA Multiply, and Add combinations so output remains within the delay's 0 to 1000 ms range.
- Lock a non-zero delay FadeTime, remembering that FadeTime uses samples even though DelayTime and PMA Add use milliseconds.
- Verify the exact formula at several BPM values, including a case whose result exceeds 1.0 to prove there is no normalised clamp.
- Guard downstream limits because `control.pma_unscaled` provides no overflow protection.
