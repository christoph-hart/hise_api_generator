# math.div - HSC Scenario

## Node

- Factory path: `math.div`
- Source page: `scriptnode_enrichment/output/math/div.md`

## Scenario

- Title: Wrapped ramp normalizer
- Project context: A slow `core.ramp` is wrapped repeatedly with `math.fmod` and then rescaled by `math.div` so the output returns to a clean 0..1 range while showing more repeated segments per cycle. The same public parameter drives both math nodes.
- Teaching goal: Demonstrate how `math.div` can act as the normalization companion to a wrapped signal so repeated segments fit back into a display-friendly 0..1 range.

## Support Nodes

- Required: [`core.ramp`, `math.fmod`, `core.peak`]
- Optional: [`math.clear`]
- Rationale: `core.ramp` provides the slow visible source, `math.fmod` creates the repeated wrapped segments, and `core.peak` shows the normalized result after division.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: yes

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- This example should intentionally duplicate the `math.fmod` topology 1:1, with only the target emphasis and cosmetics changed.
- One parameter should drive both `math.fmod.Value` and `math.div.Value` so the wrap count and normalization stay aligned.
- Keep the shared control's upper range at `1.0` so the example can start from the unwrapped full-ramp state.
- Keep the divisor positive at all times, because zero or negative values turn `math.div` into silence.
