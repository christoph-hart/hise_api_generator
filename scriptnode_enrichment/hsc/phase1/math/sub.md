# math.sub - HSC Scenario

## Node

- Factory path: `math.sub`
- Source page: `scriptnode_enrichment/output/math/sub.md`

## Scenario

- Title: DC subtractor
- Project context: A scoped test chain seeds a known value, inspects it, subtracts a fixed amount with `math.sub`, and inspects the shifted result before clearing the artificial signal.
- Teaching goal: Demonstrate that `math.sub` removes a constant offset from every sample in the signal.

## Support Nodes

- Required: [`math.add`, `analyse.specs`, `math.clear`]
- Optional: []
- Rationale: A seeded non-zero input makes subtraction visible, `analyse.specs` brackets the transform, and `math.clear` safely terminates the artificial test signal.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: yes

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Seed the chain before the first specs node so the subtraction result is visible.
- Use a simple subtract amount so the before and after values are easy to follow.
- End with `math.clear` because this is an intentionally artificial DC test signal.
