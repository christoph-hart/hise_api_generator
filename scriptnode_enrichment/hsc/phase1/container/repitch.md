# container.repitch - HSC Scenario

## Node

- Factory path: `container.repitch`
- Source page: `scriptnode_enrichment/output/container/repitch.md`

## Scenario

- Title: Repitched Reverb Space
- Project context: A 100-percent-wet algorithmic reverb is wrapped in a resampling container and blended with the original stereo signal. Moving Repitch Factor changes the effective sample rate seen by the reverb, shifting its delay structure and perceived room length without directly changing the reverb Size parameter.
- Teaching goal: Demonstrate how `container.repitch` alters sample-rate-dependent child behaviour rather than pitch-shifting the final mixed signal like a conventional pitch effect.

## Support Nodes

- Required: [`template.dry_wet`, `fx.reverb`]
- Optional: []
- Rationale: `fx.reverb` provides an obviously sample-rate-dependent network of comb and allpass delays whose colour and tail respond to resampling; `template.dry_wet` restores the unprocessed signal because the reverb itself outputs only wet audio.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: yes

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Put `container.repitch` in the wet branch of `template.dry_wet`, place `fx.reverb` inside it, and retain the template's `wet_gain` after the repitch container.
- Expose `RepitchFactor` over its logarithmically centred 0.5 to 2.0 range and Mix over 0 to 1. Lock reverb Size, Damping, and Width so only resampling changes the wet character during the demonstration.
- Use Cubic interpolation for the canonical clean example. Linear and None may be auditioned as explicit quality or artefact comparisons, not changed silently.
- Explain and verify the factor direction by ear because an effects-only child can make the apparent response shift seem inverted relative to a generator placed inside the container.
- Keep the context mono or stereo. More than two channels would pass through unchanged without warning; for multichannel use, separate repitch instances would be needed under `container.multi`.
- Do not nest this under a frame container. Also avoid claiming that gain or static waveshaping children would respond, because sample-rate-independent processing is unchanged by Repitch Factor.
