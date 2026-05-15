# math.tanh - HSC Scenario

## Node

- Factory path: `math.tanh`
- Source page: `scriptnode_enrichment/output/math/tanh.md`

## Scenario

- Title: Soft saturation shaper
- Project context: A slow `core.ramp` is driven into `math.tanh` so the peak display shows the rounded saturation curve. The example uses a visual transfer-function setup instead of a full distortion patch.
- Teaching goal: Demonstrate how `math.tanh` rounds signal peaks into a soft-clipped saturation curve.

## Support Nodes

- Required: [`core.ramp`, `core.peak`]
- Optional: [`math.mul`, `math.clear`]
- Rationale: `core.ramp` provides a slow visible source, `core.peak` shows the shaped output, and optional pre-drive can make the tanh curve more pronounced.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: yes

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Use a slow ramp such as 1000 ms so the soft-clipped curve is readable in the peak display.
- Add enough drive before or inside the node settings that the rounded saturation is visibly different from a straight ramp.
- Keep the example visual and minimal rather than turning it into a complete distortion effect chain.
