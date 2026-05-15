# math.map - HSC Scenario

## Node

- Factory path: `math.map`
- Source page: `scriptnode_enrichment/output/math/map.md`

## Scenario

- Title: Clamped range remapper
- Project context: A scoped test chain feeds a known unipolar value into `math.map`, then inspects how it is remapped into a different output range. The point is to show the clamped conversion rather than a larger patch.
- Teaching goal: Demonstrate how `math.map` linearly remaps one range to another while clamping values outside the input bounds.

## Support Nodes

- Required: [`math.add`, `analyse.specs`, `math.clear`]
- Optional: []
- Rationale: A support offset can seed a known input value, `analyse.specs` shows the before and after ranges, and `math.clear` prevents the artificial signal from reaching the output.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: no

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Choose simple input and output ranges so the mapping math is easy to follow at a glance.
- Make the clamping behaviour visible by seeding a value near or beyond the input edge if possible.
- Because the node is mainly about range semantics, narrow the public controls to the exact ranges the example is trying to explain.
