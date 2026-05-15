# math.fill1 - HSC Scenario

## Node

- Factory path: `math.fill1`
- Source page: `scriptnode_enrichment/output/math/fill1.md`

## Scenario

- Title: Envelope seed DC source
- Project context: A HISE Script Envelope needs a constant control signal of `1.0` that can later be shaped by an envelope node. `math.fill1` provides that seed signal so the example demonstrates why this node exists beyond simple testing.
- Teaching goal: Demonstrate how `math.fill1` creates the constant DC source used as the starting point for custom envelope shaping.

## Support Nodes

- Required: [`envelope.simple_ar`, `math.clear`]
- Optional: [`envelope.voice_manager`]
- Rationale: An envelope node gives the constant `1.0` signal an immediately recognizable purpose, and `math.clear` safely terminates the artificial control signal if needed.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: yes

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Frame this as a Script Envelope style control-signal example, not as an audio oscillator patch.
- The example should make clear that `math.fill1` discards any incoming signal and replaces it with a constant `1.0`.
- End the chain safely if the shaped control signal remains in the audio path.
