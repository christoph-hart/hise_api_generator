# control.voice_bang - HSC Scenario

## Node

- Factory path: `control.voice_bang`
- Source page: `scriptnode_enrichment/output/control/voice_bang.md`

## Scenario

- Title: Pan Value Latched Per Voice
- Project context: A polyphonic synth exposes a Next Voice Pan control. Each note-on makes `control.voice_bang` send the current value to that voice's panner, so changing the control affects newly started notes without moving voices that are already sounding.
- Teaching goal: Demonstrate note-on-triggered payload delivery in a required polyphonic context.

## Support Nodes

- Required: [`core.oscillator`, `jdsp.jpanner`, `envelope.simple_ar`]
- Optional: []
- Rationale: `core.oscillator` generates each MIDI-pitched voice; `jdsp.jpanner` stores the delivered position in per-voice state; and `envelope.simple_ar` keeps notes alive long enough to compare held voices started before and after the shared Value changes.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: no

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Build the complete network in a polyphonic container. `control.voice_bang` must fail or report an error in a monophonic context.
- Connect a public Next Voice Pan parameter to Value and map voice-bang output to `jdsp.jpanner.Pan` from -1 to +1.
- Order the audio path as oscillator, panner, then simple AR, with MIDI events reaching all three relevant nodes.
- Start a long note, change Next Voice Pan, and start another overlapping note. Verify only the new voice receives the changed position.
- Changing Value alone must not send output; note-on is the trigger. All voices share the stored Value even though delivery occurs per voice.
- Lock oscillator and envelope settings so voice overlap and pan position remain the only variables.
