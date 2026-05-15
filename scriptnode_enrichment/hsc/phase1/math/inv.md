# math.inv - HSC Scenario

## Node

- Factory path: `math.inv`
- Source page: `scriptnode_enrichment/output/math/inv.md`

## Scenario

- Title: Signal polarity inverter
- Project context: A scoped test chain seeds a known value, inspects it before and after `math.inv`, and then clears the artificial signal. The example focuses only on the polarity flip.
- Teaching goal: Demonstrate that `math.inv` multiplies the signal by `-1` and inverts polarity.

## Support Nodes

- Required: [`math.add`, `analyse.specs`, `math.clear`]
- Optional: []
- Rationale: A seeded value is needed so inversion is visible, `analyse.specs` shows the before and after state, and `math.clear` safely mutes the artificial test signal.

## Assumptions

- Channels: default stereo
- Public control needed: no
- Raw node values acceptable: yes

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Seed the signal with a non-zero value before the first specs node so the inversion is visible.
- Keep the example minimal and numeric; this node does not need a broader musical story.
- End with `math.clear` because the example intentionally creates a static test signal.
