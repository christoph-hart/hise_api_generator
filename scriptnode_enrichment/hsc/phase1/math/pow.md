# math.pow - HSC Scenario

## Node

- Factory path: `math.pow`
- Source page: `scriptnode_enrichment/output/math/pow.md`

## Scenario

- Title: Exponent curve shaper
- Project context: A scoped test chain seeds a unipolar value, inspects it, applies `math.pow`, and inspects the reshaped output before clearing the artificial signal. The example focuses on curve bending rather than sound design.
- Teaching goal: Demonstrate how `math.pow` reshapes a non-negative signal by raising it to a power.

## Support Nodes

- Required: [`math.add`, `analyse.specs`, `math.clear`]
- Optional: []
- Rationale: A known non-negative seed is required so the curve change is visible, `analyse.specs` shows the before and after state, and `math.clear` safely terminates the test signal.

## Assumptions

- Channels: default stereo
- Public control needed: no
- Raw node values acceptable: yes

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Keep the input non-negative, because negative values can produce NaN for fractional exponents.
- The explanation should mention that this is a unipolar curve shaper rather than a general bipolar audio processor.
- End with `math.clear` because the example intentionally uses a static test value.
