# math.expr - HSC Scenario

## Node

- Factory path: `math.expr`
- Source page: `scriptnode_enrichment/output/math/expr.md`

## Scenario

- Title: Programmable scalar transform
- Project context: A scoped test chain seeds a simple value, inspects it before and after `math.expr`, and relies on the node's own graph UI to show the shaping function. The example focuses on the fact that this node is a programmable replacement for small bespoke math transforms.
- Teaching goal: Demonstrate how `math.expr` applies a user-defined SNEX formula to the signal and is best validated with simple known inputs.

## Support Nodes

- Required: [`math.add`, `analyse.specs`, `math.clear`]
- Optional: []
- Rationale: A support `math.add` seeds a known non-zero value, `analyse.specs` brackets the transform, and `math.clear` safely terminates the artificial test signal while the node's own graph handles the curve display.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: yes

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Keep the formula very small, such as a one-line reshape or clamp, so the example teaches the programmable interface rather than a complicated expression.
- Mention that the node's own graph already visualizes the transfer, so no extra ramp-driven display setup is necessary.
- Use explicit float literals in the formula where needed to avoid SNEX type mismatch confusion.
