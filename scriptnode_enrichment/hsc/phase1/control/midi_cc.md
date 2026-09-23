# control.midi_cc - HSC Scenario

## Node

- Factory path: `control.midi_cc`
- Source page: `scriptnode_enrichment/output/control/midi_cc.md`

## Scenario

- Title: Mod-Wheel Stereo Position
- Project context: MIDI CC1 controls the pan position of a stereo panner, with a centred fallback before the first controller message arrives. The example converts ordinary 7-bit controller data to a normalised modulation value and maps it across the full stereo field.
- Teaching goal: Demonstrate filtered MIDI CC listening, immediate DefaultValue output, and normalised target mapping.

## Support Nodes

- Required: [`jdsp.jpanner`]
- Optional: [`container.midichain`]
- Rationale: `jdsp.jpanner` gives the 0 to 1 CC output an audible bipolar destination; an optional `container.midichain` is required only in an effect context where MIDI delivery must be enabled explicitly.

## Assumptions

- Channels: default stereo
- Public control needed: no
- Raw node values acceptable: no

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Set CCNumber to 1, EnableMPE off, and DefaultValue to 0.5 so the target starts centred.
- Connect the normalised output to `jdsp.jpanner.Pan`, mapping 0 to -1, 0.5 to centre, and 1 to +1.
- Lock a constant-power panning rule and test CC values 0, 64, and 127.
- Keep `control.midi_cc` in an event-processing signal path; use `container.midichain` only where the host context otherwise blocks MIDI.
- Verify that unrelated CC messages do not update the target and that changing DefaultValue itself sends an immediate output.
- Do not use CCNumber values 128-131 in this example because they select special pitch, aftertouch, and note event modes rather than standard CCs.
