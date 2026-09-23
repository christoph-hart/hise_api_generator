# control.clone_cable - HSC Scenario

## Node

- Factory path: `control.clone_cable`
- Source page: `scriptnode_enrichment/output/control/clone_cable.md`

## Scenario

- Title: MIDI Harmonic Oscillator Bank
- Project context: A clone container holds identical sine oscillators, but each active clone must play a different integer multiple of the incoming note. `control.clone_cable` uses Harmonics mode to distribute note-derived frequencies automatically as the harmonic count changes.
- Teaching goal: Demonstrate formula-based per-clone value distribution and the MIDI-aware behaviour of Harmonics mode.

## Support Nodes

- Required: [`container.midichain`, `container.clone`, `core.oscillator`]
- Optional: []
- Rationale: `container.midichain` enables MIDI events in the Script FX context; `container.clone` provides the identical parallel oscillator chains addressed by clone index; and `core.oscillator` turns each distributed frequency into one additive partial.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: no

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Configure the clone in Parallel mode with identical child chains containing one sine `core.oscillator` each.
- Make Num Harmonics the first root macro and connect identical 1 to 16 integer ranges to `container.clone.NumClones` and `control.clone_cable.NumClones`.
- Set clone-cable Mode to Harmonics and connect its output to oscillator Frequency. The target must use the unskewed Linear 0 to 20 kHz range required by MIDI-reactive frequency modes.
- Ensure MIDI reaches the clone cable through the required `container.midichain` inside the effect context.
- Apply conservative per-clone oscillator gain so increasing Num Harmonics does not clip, and verify that partial frequencies follow integer multiples of several played notes.
- Gamma is ignored in Harmonics mode and must not be exposed as an effective control.
