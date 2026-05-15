# math.mod2sig - HSC Scenario

## Node

- Factory path: `math.mod2sig`
- Source page: `scriptnode_enrichment/output/math/mod2sig.md`

## Scenario

- Title: Unipolar to bipolar converter
- Project context: A scoped test chain starts from a known unipolar control value, converts it with `math.mod2sig`, and inspects the bipolar result before clearing the signal. The example exists to show the range conversion directly.
- Teaching goal: Demonstrate how `math.mod2sig` converts a 0..1 signal into a -1..1 signal.

## Support Nodes

- Required: [`math.add`, `analyse.specs`, `math.clear`]
- Optional: []
- Rationale: A seeded unipolar input makes the conversion easy to verify, `analyse.specs` shows the before and after state, and `math.clear` safely terminates the artificial test signal.

## Assumptions

- Channels: default stereo
- Public control needed: no
- Raw node values acceptable: yes

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Use a known unipolar seed value such as `0.25` or `0.75` so the bipolar result is easy to reason about.
- Keep the example purely about range conversion; no extra musical framing is needed.
- End with `math.clear` because this is an intentionally artificial signal.
