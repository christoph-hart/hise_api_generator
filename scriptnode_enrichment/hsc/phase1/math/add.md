# math.add - HSC Scenario

## Node

- Factory path: `math.add`
- Source page: `scriptnode_enrichment/output/math/add.md`

## Scenario

- Title: DC offset adder
- Project context: A tiny scoped test chain seeds a known value, inspects it with `analyse.specs`, adds a fixed offset with `math.add`, inspects the shifted value again, and then clears the artificial signal.
- Teaching goal: Demonstrate that `math.add` applies a constant DC offset to every sample in the signal.

## Support Nodes

- Required: [`math.add`, `analyse.specs`, `math.clear`]
- Optional: []
- Rationale: A first `math.add` node can seed a non-zero input before the target node, `analyse.specs` brackets the transform, and `math.clear` prevents the artificial DC signal from reaching the output.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: yes

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Seed the chain with a known value before the first `analyse.specs`, otherwise the example starts at zero and is less informative.
- Keep the target `math.add` value simple, such as `0.3`, so the before and after values are obvious.
- End with `math.clear` because this is an intentionally artificial DC test signal.
