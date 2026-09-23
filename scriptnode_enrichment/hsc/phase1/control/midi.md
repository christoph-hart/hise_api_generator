# control.midi - HSC Scenario

## Node

- Factory path: `control.midi`
- Source page: `scriptnode_enrichment/output/control/midi.md`

## Scenario

- Title: Velocity-Controlled Filter Brightness
- Project context: A MIDI-aware synth maps note-on velocity to the cutoff of a lowpass filter. Soft notes produce a dark tone and hard notes open the filter, while subsequent audio processing continues without polling MIDI state.
- Teaching goal: Demonstrate event-to-normalised-value conversion in Velocity mode and the requirement that `control.midi` sits in an event-processing signal path.

## Support Nodes

- Required: [`filters.svf`]
- Optional: [`container.midichain`]
- Rationale: `filters.svf` turns the normalised velocity output into an audible cutoff range; an optional `container.midichain` is needed only when the example is hosted in an effect context where MIDI events are disabled by default.

## Assumptions

- Channels: default stereo
- Public control needed: no
- Raw node values acceptable: no

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Set `control.midi.Mode` to Velocity and connect its 0 to 1 output to `filters.svf.Frequency` using a restricted musical cutoff range.
- Place the MIDI node in the serial signal path that receives events. Do not move it into a disconnected control-only branch.
- Add `container.midichain` only for Script FX or another host context that does not already deliver MIDI to children.
- Keep the SVF in LP mode with fixed Q and non-zero smoothing.
- Verify at least three note-on velocities and confirm output updates only when relevant MIDI events arrive.
- Note-off does not provide a new velocity value in this mode; do not describe the output as a gate or continuous envelope.
