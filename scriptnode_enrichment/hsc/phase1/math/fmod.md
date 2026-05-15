# math.fmod - HSC Scenario

## Node

- Factory path: `math.fmod`
- Source page: `scriptnode_enrichment/output/math/fmod.md`

## Scenario

- Title: Wrapped ramp repeater
- Project context: A slow `core.ramp` is wrapped repeatedly with `math.fmod` and then rescaled by `math.div` so one cycle turns into several visible sub-cycles inside the peak display. The same public parameter drives both math nodes.
- Teaching goal: Demonstrate how `math.fmod` wraps a signal into repeating segments and can be paired with `math.div` to keep the wrapped result in a useful 0..1 range.

## Support Nodes

- Required: [`core.ramp`, `math.div`, `core.peak`]
- Optional: [`math.clear`]
- Rationale: `core.ramp` provides the slow visible source, `math.div` rescales the wrapped segments back into a clean range, and `core.peak` shows the resulting repetition count clearly.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: yes

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- This example should intentionally duplicate the `math.div` topology 1:1, with only the target emphasis and cosmetics changed.
- One parameter should drive both `math.fmod.Value` and `math.div.Value` so the wrap count and normalization stay aligned.
- Keep the shared control's upper range at `1.0` so the example can start from the full-ramp baseline before wrapping.
- The zero-guard behaviour of `math.fmod` should be mentioned if the parameter range approaches zero.
