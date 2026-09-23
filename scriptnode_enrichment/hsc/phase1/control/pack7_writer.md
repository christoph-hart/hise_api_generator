# control.pack7_writer - HSC Scenario

## Node

- Factory path: `control.pack7_writer`
- Source page: `scriptnode_enrichment/output/control/pack7_writer.md`

## Scenario

- Title: Seven-Degree Pitch Pattern
- Project context: Seven public pitch-ratio controls define one octave's scale degrees in a slider pack. A tempo-locked ramp scans the entries discretely and applies the selected ratio to a MIDI-pitched oscillator, producing a repeating seven-note pattern.
- Teaching goal: Demonstrate fixed seven-value pack writing in a musically recognisable index order.

## Support Nodes

- Required: [`core.clock_ramp`, `control.cable_pack`, `core.oscillator`]
- Optional: []
- Rationale: `core.clock_ramp` supplies the repeating transport-locked playhead; `control.cable_pack` reads the seven written values as discrete scale steps; and `core.oscillator` makes each selected frequency ratio audible relative to the played base note.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: no

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Share one external SliderPack slot between writer and cable pack and initialise seven ascending scale-ratio values in Interface `onInit`.
- Connect Value1 through Value7 to separately labelled Degree controls and verify zero-based pack indices 0 through 6.
- Map the cable-pack output to an overridden continuous oscillator `Freq Ratio` range covering the intended octave, and verify fractional ratios in HISE.
- Lock oscillator waveform and gain, allow MIDI note-on to establish base pitch, and keep the clock ramp AddToSignal disabled.
- Connecting the writer must resize the pack to seven entries. Use nearest-neighbour lookup so pitch does not glide between degrees.
- The seven-step cycle is polymetric against common binary divisions; lock a cycle duration that makes this intentional and easy to hear.
- Do not embed the script-initialised slider pack.
