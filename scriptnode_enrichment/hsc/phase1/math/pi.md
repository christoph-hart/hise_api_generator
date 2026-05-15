# math.pi - HSC Scenario

## Node

- Factory path: `math.pi`
- Source page: `scriptnode_enrichment/output/math/pi.md`

## Scenario

- Title: Pi scaler for visible radians
- Project context: A scoped-plus-visual chain scales a known signal with `math.pi`, converts the result back into a 0..1 display range with `math.sig2mod`, and shows it on a peak display. The example is deliberately small because this node mostly exists as a support scaler for trigonometric shaping.
- Teaching goal: Demonstrate how `math.pi` multiplies a signal by `PI * Value` and is typically used to prepare signals for sine-based shaping.

## Support Nodes

- Required: [`math.add`, `math.sig2mod`, `core.peak`, `math.clear`]
- Optional: []
- Rationale: A support `math.add` seeds a known value, `math.sig2mod` converts the scaled result into a display-friendly 0..1 range for `core.peak`, and `math.clear` safely terminates the artificial signal.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: yes

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- This example should explicitly mention that `math.pi` is often a support node for `math.sin` rather than a standalone end goal.
- Because a peak display wants a modulation-style range, convert the scaled output with `math.sig2mod` before showing it.
- Keep the seeded value and multiplier simple so the scaling role is obvious.
