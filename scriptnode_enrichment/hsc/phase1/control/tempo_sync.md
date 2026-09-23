# control.tempo_sync - HSC Scenario

## Node

- Factory path: `control.tempo_sync`
- Source page: `scriptnode_enrichment/output/control/tempo_sync.md`

## Scenario

- Title: Host-Synchronised Echo Time
- Project context: A delay effect derives its wet-path delay time from a musical note division and the current host BPM. Disabling sync switches the same output to a manual millisecond value for standalone or free-time operation.
- Teaching goal: Demonstrate conversion from musical tempo values to raw milliseconds and the Enabled-controlled unsynchronised fallback.

## Support Nodes

- Required: [`template.dry_wet`, `core.fix_delay`]
- Optional: []
- Rationale: `core.fix_delay` consumes the tempo-sync node's raw millisecond output directly and safely crossfades delay-time changes, while `template.dry_wet` combines its delayed-only wet branch with the original signal.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: no

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Put `core.fix_delay` before `wet_gain` in the template wet branch and connect `control.tempo_sync` output directly to DelayTime without normalising it.
- Expose Tempo, Multiplier, Sync Enabled, Unsynced Time, and Mix. Enabled defaults off in the node, so set it on intentionally for the canonical startup state.
- Constrain note division and multiplier combinations to durations no greater than the delay's 1000 ms maximum at the supported BPM range.
- Lock a non-zero FadeTime to prevent clicks when tempo or division changes; FadeTime itself is measured in samples.
- Verify output updates when host BPM changes, remains in raw milliseconds, and switches to UnsyncedTime when Enabled is off.
- The dry/wet template uses a linear crossfade and must retain its wet gain node.
