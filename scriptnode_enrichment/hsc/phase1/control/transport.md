# control.transport - HSC Scenario

## Node

- Factory path: `control.transport`
- Source page: `scriptnode_enrichment/output/control/transport.md`

## Scenario

- Title: Playback-Only Filter Effect
- Project context: A lowpass effect fades into its processed state when the DAW starts and returns to dry when playback stops. `control.transport` supplies the exact binary host state without polling or a user parameter.
- Teaching goal: Demonstrate event-driven play/stop modulation and its use as an activation signal.

## Support Nodes

- Required: [`container.soft_bypass`, `filters.svf`]
- Optional: []
- Rationale: `container.soft_bypass` turns transport changes into click-free dry/processed transitions, and `filters.svf` provides an audible effect stage whose active state tracks playback.

## Assumptions

- Channels: default stereo
- Public control needed: no
- Raw node values acceptable: yes

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Connect transport output directly to the soft-bypass activation input and place one LP SVF inside the wrapper.
- Use a non-zero SmoothingTime and lock filter cutoff, Q, mode, and smoothing so only transport state changes the effect.
- Verify start sends 1 and activates processing, stop sends 0 and bypasses it, with no redundant output while state remains unchanged.
- Label activation polarity in the topology because the soft-bypass connection treats values at or above 0.5 as active.
- Test in a host context that supplies real transport state. Standalone behaviour without a DAW transport must not be assumed.
- In polyphonic contexts each active voice receives each state change once, but the canonical effect remains monophonic.
