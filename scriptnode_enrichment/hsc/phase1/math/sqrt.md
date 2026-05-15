# math.sqrt - HSC Scenario

## Node

- Factory path: `math.sqrt`
- Source page: `scriptnode_enrichment/output/math/sqrt.md`

## Scenario

- Title: Root curve shaper
- Project context: A scoped test chain seeds a non-negative value, inspects it, applies `math.sqrt`, and inspects the concave result before clearing the artificial signal.
- Teaching goal: Demonstrate how `math.sqrt` reshapes a non-negative signal into a fast-rising concave curve.

## Support Nodes

- Required: [`math.add`, `analyse.specs`, `math.clear`]
- Optional: []
- Rationale: A known non-negative seed makes the square-root transform easy to verify, `analyse.specs` shows the before and after state, and `math.clear` safely terminates the test signal.

## Assumptions

- Channels: default stereo
- Public control needed: no
- Raw node values acceptable: yes

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Keep the input non-negative because negative values produce NaN.
- The explanation should mention that this is a unipolar curve shaper, not a general bipolar processor.
- End with `math.clear` because the example intentionally uses an artificial seed value.
