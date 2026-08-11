# fx.phase_delay - HSC Scenario

## Node

- Factory path: `fx.phase_delay`
- Source page: `scriptnode_enrichment/output/fx/phase_delay.md`

## Scenario

- Title: PhaseFX-style swept allpass phaser
- Project context: A synth or guitar insert needs a close scriptnode recreation of HISE's PhaseFX module. The network feeds a small amount of the previous allpass-cascade output back into the cascade, sweeps all `fx.phase_delay` stages together, then sums the shifted output with the dry signal for the characteristic resonant phaser notches.
- Teaching goal: Demonstrate that `fx.phase_delay` is the allpass building block in a feedback phaser topology, not a complete PhaseFX replacement by itself.

## Support Nodes

- Required: [`template.feedback_delay`, `template.dry_wet`, `core.ramp`, `control.bipolar`, `fx.phase_delay`]
- Optional: [`core.gain`]
- Rationale: The feedback template supplies the safe feedback routing needed to approximate PhaseFX resonance, the dry/wet template supplies the final insert-style mix, multiple `fx.phase_delay` nodes form the allpass cascade, and the modulation support nodes sweep their shared Frequency value.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: yes

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Do not demonstrate `fx.phase_delay` inline as a standalone processor; PhaseFX-style behaviour needs both feedback around the allpass cascade and a dry path for audible notch cancellation.
- Model the HISE PhaseFX signal path: feedback is applied before the allpass cascade, all allpass stages share the same swept frequency, the cascade output is summed with the dry signal, then the result is dry/wet mixed.
- Keep the feedback amount below unity. HISE PhaseFX scales its Feedback parameter internally for safety, so Phase 2 should use a conservative public feedback range.
- Use a narrowed Frequency range for the swept stages so `matched` parameter connections remain readable and musically useful.
- Keep the number of stages small enough that the screenshot remains understandable, but large enough to show why multiple allpass stages are chained for a phaser.
