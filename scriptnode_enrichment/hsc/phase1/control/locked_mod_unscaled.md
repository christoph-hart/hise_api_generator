# control.locked_mod_unscaled - HSC Scenario

## Node

- Factory path: `control.locked_mod_unscaled`
- Source page: `scriptnode_enrichment/output/control/locked_mod_unscaled.md`

## Scenario

- Title: Reusable Tempo Duration Source
- Project context: A locked modulation container converts a musical note division into raw milliseconds and exposes that duration through one draggable output. The external destination is a fixed delay whose DelayTime receives the millisecond value directly without normalised range conversion.
- Teaching goal: Demonstrate why `control.locked_mod_unscaled` is required when an internal source already produces values in the target parameter's native unit domain.

## Support Nodes

- Required: [`container.modchain`, `control.tempo_sync`, `core.fix_delay`]
- Optional: []
- Rationale: `container.modchain` packages the control-only source as the immediate lockable parent; `control.tempo_sync` produces raw millisecond durations; and `core.fix_delay` accepts that same native millisecond domain while crossfading safely between changed delay positions.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: yes

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Place `control.tempo_sync` and `control.locked_mod_unscaled` as immediate children of one `container.modchain`, connect the tempo output to Value, then lock that parent.
- Connect the parent's modulation dragger to `core.fix_delay.DelayTime` outside the locked block. Override the locked-mod Value range as needed to carry raw milliseconds up to the delay's 1000 ms limit.
- Enable tempo sync explicitly, expose Tempo and Multiplier on the locked container, and constrain combinations so generated durations do not exceed the target delay range.
- Keep the output unscaled throughout. Using normal `control.locked_mod` would reinterpret milliseconds as a 0 to 1 normalised value and apply the delay range again.
- Lock a non-zero `core.fix_delay.FadeTime` and remember that FadeTime is measured in samples, not milliseconds.
- Verify raw values at multiple BPM values and note divisions, including a changed host tempo while playback continues.
