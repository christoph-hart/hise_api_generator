# control.input_toggle - HSC Scenario

## Node

- Factory path: `control.input_toggle`
- Source page: `scriptnode_enrichment/output/control/input_toggle.md`

## Scenario

- Title: Key Tracking Or Manual Cutoff
- Project context: A MIDI-aware polyphonic filter effect can derive cutoff from the incoming note frequency or from a public manual frequency control. A Key Track switch selects which stored source `control.input_toggle` forwards to the filter.
- Teaching goal: Demonstrate hard selection between two live control inputs and show that changes to the inactive source remain stored until it is selected.

## Support Nodes

- Required: [`control.midi`, `filters.svf`]
- Optional: [`container.midichain`]
- Rationale: `control.midi` in Frequency mode converts incoming notes to a normalised frequency source; `filters.svf` makes the selected cutoff audible; and an optional `container.midichain` is required only if the chosen effect host context does not already deliver MIDI events to the network.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: no

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Connect `control.midi` Frequency output to `control.input_toggle.Value1`, map a Manual Cutoff macro to Value2, and connect the toggle output to `filters.svf.Frequency`.
- Configure the filter target with the linear 0 to 20000 Hz range expected by MIDI Frequency mode, then constrain the public manual control to a useful audible subrange without changing the internal normalised domain.
- Expose Input as a two-state Key Track switch with labels MIDI and Manual. Switching is immediate, not blended.
- Keep `control.midi` in the event-processing signal path. Add `container.midichain` only for an effect context where MIDI would otherwise be disabled.
- Verify that moving Manual Cutoff while MIDI is selected does not update the filter, but its latest stored value is emitted immediately when Manual is selected.
- Keep SVF smoothing non-zero to soften hard source changes, and lock its mode and Q.
