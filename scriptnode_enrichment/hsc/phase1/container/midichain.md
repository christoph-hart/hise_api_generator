# container.midichain - HSC Scenario

## Node

- Factory path: `container.midichain`
- Source page: `scriptnode_enrichment/output/container/midichain.md`

## Scenario

- Title: MIDI-Played Synth Inside Script FX
- Project context: A Script FX network, where child DSP does not normally receive MIDI, contains a saw oscillator followed by a simple attack-release envelope. Wrapping them in `container.midichain` lets note events retune and articulate the generated tone at their exact sample offsets.
- Teaching goal: Demonstrate that `container.midichain` enables MIDI in an effect context and splits audio processing at event timestamps before dispatching events to its serial children.

## Support Nodes

- Required: [`core.oscillator`, `envelope.simple_ar`]
- Optional: []
- Rationale: `core.oscillator` responds to incoming note-on events by setting pitch and generates the saw signal; `envelope.simple_ar` responds to note-on and note-off, multiplies that signal by an attack-release contour, and makes event-aligned articulation audible.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: no

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Build and test this specifically in a Script FX or equivalent effect context where MIDI is disabled without `container.midichain`; a synthesiser context would make the wrapper unnecessary and weaken the example.
- Order `core.oscillator` before `envelope.simple_ar` so the oscillator adds its signal and the envelope then applies gain to it.
- Lock the oscillator to Saw mode. Incoming note-on sets its frequency, but MIDI does not toggle `core.oscillator.Gate`; leave Gate on and let `envelope.simple_ar` perform articulation.
- Expose Attack and Release, and set `AttackCurve` intentionally because its default is exponential rather than linear. Do not imply that this envelope has an adjustable sustain level.
- Verify note-on and note-off events with non-zero timestamps inside a host block so the output transition proves event-aligned splitting rather than mere MIDI reception.
- Do not place this midichain inside frame or resampled containers. If frame processing is later required, the valid hierarchy is `midichain -> frame container`, never the reverse.
