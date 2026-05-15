# math.mul - HSC Scenario

## Node

- Factory path: `math.mul`
- Source page: `scriptnode_enrichment/output/math/mul.md`

## Scenario

- Title: Scalar gain multiplier
- Project context: A scoped test chain seeds a known value, inspects it, scales it with `math.mul`, and inspects the result again before clearing the signal. This keeps the example focused on raw gain scaling.
- Teaching goal: Demonstrate that `math.mul` multiplies the signal by a scalar value and is the most direct raw gain node in the factory.

## Support Nodes

- Required: [`math.add`, `analyse.specs`, `math.clear`]
- Optional: []
- Rationale: A support `math.add` seeds a non-zero value so multiplication is visible, `analyse.specs` shows the scaling, and `math.clear` safely mutes the artificial test signal.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: yes

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Seed the chain before the first specs node so the multiply result is not trivially zero.
- Use a simple multiplier such as `0.5` so the output is easy to verify.
- Mention in the explanation that this is raw linear scaling, not decibel gain control.
