# control.random - HSC Scenario

## Node

- Factory path: `control.random`
- Source page: `scriptnode_enrichment/output/control/random.md`

## Scenario

- Title: MIDI-Triggered Random Voice Pan
- Project context: A Polyphonic Script FX receives the gate state of each played voice through `control.midi`. Each gate transition asks `control.random` for a new uniformly distributed value, which places that voice at a new stereo position.
- Teaching goal: Demonstrate that Value is a change trigger whose numeric content is ignored, while using a MIDI-derived gate to produce fresh normalised random values in a polyphonic voice context.

## Support Nodes

- Required: [`control.midi`, `jdsp.jpanner`]
- Optional: []
- Rationale: `control.midi` in Gate mode supplies the changing zero and one trigger values for each voice, while `jdsp.jpanner` converts each random 0 to 1 output into an audible full-range stereo position.

## Assumptions

- Channels: default stereo
- Public control needed: no
- Raw node values acceptable: no

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Build the example in a Polyphonic Script FX module placed in a synthesiser voice effect chain; a normal Script FX cannot demonstrate independent per-voice target state.
- Set `control.midi.Mode` to Gate and connect its output to `control.random.Value`. Connect the random output to `jdsp.jpanner.Pan`, mapped from -1 to +1, and lock a constant-power pan rule.
- Gate mode emits 1 on note-on and 0 on note-off. Both are Value changes and therefore both trigger new random numbers; do not describe this as note-on-only randomisation.
- Verify note-on and note-off transitions, then play overlapping voices to confirm that each current voice receives its own target update.
- Re-sending the same gate value must not be assumed to retrigger because `control.random` reacts only to changes.
- Do not promise deterministic sequences; each random node instance has an independent seed.
