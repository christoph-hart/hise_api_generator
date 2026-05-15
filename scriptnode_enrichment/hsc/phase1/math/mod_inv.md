# math.mod_inv - HSC Scenario

## Node

- Factory path: `math.mod_inv`
- Source page: `scriptnode_enrichment/output/math/mod_inv.md`

## Scenario

- Title: Modulation inverter
- Project context: A scoped test chain seeds a known 0..1 value, inverts it with `math.mod_inv`, and inspects the result. The example focuses on the unipolar inversion rather than on audio processing.
- Teaching goal: Demonstrate how `math.mod_inv` flips a 0..1 modulation signal into its 1..0 complement.

## Support Nodes

- Required: [`math.add`, `analyse.specs`, `math.clear`]
- Optional: []
- Rationale: A known seed value makes inversion obvious, `analyse.specs` shows the before and after values, and `math.clear` prevents the artificial signal from leaking to the output.

## Assumptions

- Channels: default stereo
- Public control needed: no
- Raw node values acceptable: yes

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Keep the seeded input inside the 0..1 range because this node is about modulation inversion semantics.
- The explanation should distinguish this from `math.inv`, which flips signal polarity around zero instead of around one-half.
- End with `math.clear` because the example intentionally generates a test value.
