# envelope.flex_ahdsr - HSC Scenario

## Node

- Factory path: `envelope.flex_ahdsr`
- Source page: `scriptnode_enrichment/output/envelope/flex_ahdsr.md`

## Scenario

- Title: Script Envelope loop contour
- Project context: A HISE Sine Wave Generator needs a custom envelope that can behave like a standard note envelope, a one-shot trigger envelope, or a looping contour. Inside a Script Envelope module, `math.fill1` creates a constant 1.0 signal that `envelope.flex_ahdsr` reshapes according to its Mode and curve parameters.
- Teaching goal: Demonstrate how `envelope.flex_ahdsr` creates custom Script Envelope outputs with per-segment curve shaping and Trigger, Note, and Loop playback modes.

## Support Nodes

- Required: [`math.fill1`, `envelope.voice_manager`]
- Optional: []
- Rationale: `math.fill1` provides the static modulation source for the Script Envelope output. `envelope.voice_manager` receives the Gate output so the looping or note-based envelope still participates in normal voice cleanup.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: yes

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Build this as a HISE Script Envelope module assigned to a Sine Wave Generator, with `math.fill1 -> envelope.flex_ahdsr` inside the scriptnode graph.
- Include a public Mode control so users can compare Note, Trigger, and Loop without rebuilding the network.
- Avoid realtime modulation of flex envelope parameters in the example; the reference page notes limitations around modulation slots and deferred Interface scripts.
- Make it clear that Trigger mode does not hold at sustain, while Loop mode repeats until note-off and then releases.
