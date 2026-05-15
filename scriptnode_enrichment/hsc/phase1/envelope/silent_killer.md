# envelope.silent_killer - HSC Scenario

## Node

- Factory path: `envelope.silent_killer`
- Source page: `scriptnode_enrichment/output/envelope/silent_killer.md`

## Scenario

- Title: Silence-based Script Envelope cleanup
- Project context: A custom Script Envelope module generates its modulation signal by shaping a constant 1.0 value from `math.fill1`. Instead of using an explicit Gate output, `envelope.silent_killer` watches the generated modulation signal and resets the voice once note-off has occurred and the signal has fallen to silence.
- Teaching goal: Demonstrate how `envelope.silent_killer` can monitor a control/modulation signal for silence, not just an audible audio path.

## Support Nodes

- Required: [`math.fill1`, `envelope.simple_ar`]
- Optional: []
- Rationale: `math.fill1` provides the static 1.0 control signal, and `envelope.simple_ar` shapes it into a signal that eventually reaches silence. `envelope.silent_killer` then demonstrates fallback cleanup by watching that modulation signal.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: yes

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Build this as a Script Envelope/control-signal example; no audible audio input is required for `silent_killer`.
- Prefer a minimal topology where the generated modulation signal actually reaches digital silence after note-off; otherwise the node will not fire.
- Keep the Active control public, but do not present Threshold as a meaningful sensitivity control because the reference page says it is stored but not used by detection.
- Explain that `envelope.voice_manager` with an explicit Gate signal is preferred when such a gate is available.
