# envelope.voice_manager - HSC Scenario

## Node

- Factory path: `envelope.voice_manager`
- Source page: `scriptnode_enrichment/output/envelope/voice_manager.md`

## Scenario

- Title: Gate-based voice cleanup
- Project context: A HISE Sine Wave Generator is controlled by a custom Script Envelope module. Inside the Script Envelope, `math.fill1` is shaped by `envelope.ahdsr`, and the AHDSR Gate output is wired into `voice_manager` so the voice stops after the generated envelope has released.
- Teaching goal: Demonstrate that `envelope.voice_manager` does not shape audio; it kills the current voice when a connected gate source drives Kill Voice below 0.5.

## Support Nodes

- Required: [`math.fill1`, `envelope.ahdsr`]
- Optional: []
- Rationale: `math.fill1` provides the constant Script Envelope signal, and `envelope.ahdsr` provides the Gate modulation source that makes `voice_manager` useful.

## Assumptions

- Channels: default stereo
- Public control needed: no
- Raw node values acceptable: yes

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Build this as a Script Envelope assigned to a HISE Sine Wave Generator so the generated control signal has an audible target outside scriptnode.
- The example must show the modulation connection from the envelope Gate output to `Kill Voice`; leaving `Kill Voice` at its default value never kills a voice.
- Do not route audio through `voice_manager`; it is a control/lifecycle node, not an audio processor.
- A useful verification step is to use a long release and confirm active voices drop only after the Gate goes low.
