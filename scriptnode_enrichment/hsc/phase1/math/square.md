# math.square - HSC Scenario

## Node

- Factory path: `math.square`
- Source page: `scriptnode_enrichment/output/math/square.md`

## Scenario

- Title: Squaring curve shaper
- Project context: A scoped test chain seeds a known value, inspects it, squares it with `math.square`, and inspects the new value before clearing the artificial signal.
- Teaching goal: Demonstrate how `math.square` multiplies a signal by itself and forces the result non-negative.

## Support Nodes

- Required: [`math.add`, `analyse.specs`, `math.clear`]
- Optional: []
- Rationale: A seeded value is needed so the squaring action is visible, `analyse.specs` shows the before and after state, and `math.clear` safely terminates the artificial signal.

## Assumptions

- Channels: default stereo
- Public control needed: no
- Raw node values acceptable: yes

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Use a simple seed value such as `0.5` so the squared result is easy to reason about.
- Mention that the Value parameter has no effect on processing.
- End with `math.clear` because the example intentionally generates a static test signal.
