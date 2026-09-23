# analyse.oscilloscope - HSC Scenario

## Node

- Factory path: `analyse.oscilloscope`
- Source page: `scriptnode_enrichment/output/analyse/oscilloscope.md`

## Scenario

- Title: MIDI-aware dynamic oscilloscope
- Project context: A Script FX uses a MIDI processing container to generate a note-driven oscillator and displays it with an oscilloscope whose buffer length can be changed while the graph runs.
- Teaching goal: Demonstrate the dynamic BufferLength behaviour of analyse.oscilloscope in a MIDI-aware signal path.

## Support Nodes

- Required: [`container.midichain`, `math.clear`, `core.oscillator`, `core.gain`]
- Optional: []
- Rationale: `container.midichain` delivers sample-accurate note-on events to both the oscillator and oscilloscope. `math.clear` removes the incoming Script FX audio before the additive oscillator, and `core.gain` keeps the generated test tone at a safe listening level.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: yes

## User Input Needed

- Required: false
- Questions:
  - Resolved: rely on the oscilloscope's automatic MIDI note-on cycle synchronisation instead of adding a competing manual BufferLength control.

## Notes For Phase 2

- Keep the oscillator and oscilloscope in the same MIDI chain so each note-on retunes the oscillator and resizes the display to one cycle.
- Clear the Script FX input before `core.oscillator`, which adds rather than replaces audio.
- Do not add a manual BufferLength control; it would be overwritten by the next MIDI note-on and obscure the node's defining feature.
