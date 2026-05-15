# envelope.ahdsr - HSC Scenario

## Node

- Factory path: `envelope.ahdsr`
- Source page: `scriptnode_enrichment/output/envelope/ahdsr.md`

## Scenario

- Title: Script Envelope AHDSR contour
- Project context: A HISE Sine Wave Generator needs a custom envelope module instead of a built-in AHDSR. Inside a Script Envelope module, `math.fill1` creates a constant 1.0 signal that `envelope.ahdsr` shapes into the modulation output used by the audio module.
- Teaching goal: Demonstrate the standard custom-envelope pattern: generate a constant modulation signal with `math.fill1`, shape it with `envelope.ahdsr`, and use the Gate output for voice cleanup.

## Support Nodes

- Required: [`math.fill1`, `envelope.voice_manager`]
- Optional: []
- Rationale: `math.fill1` provides the static 1.0 signal that becomes the custom envelope output. `envelope.voice_manager` is required so the Gate output teaches the standard voice lifecycle pattern.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: yes

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Build this as a HISE Script Envelope module assigned to a Sine Wave Generator, not as a scriptnode oscillator patch.
- The scriptnode graph should use `math.fill1 -> envelope.ahdsr` so the envelope node shapes a constant modulation signal rather than audio.
- Connect the envelope Gate output to `envelope.voice_manager.Kill Voice`; otherwise the example demonstrates modulation fading but not proper voice termination.
