# math.rect - HSC Scenario

## Node

- Factory path: `math.rect`
- Source page: `scriptnode_enrichment/output/math/rect.md`

## Scenario

- Title: Threshold rectifier
- Project context: A scoped test chain seeds a normalized signal, passes it through `math.rect`, and inspects how the output becomes a hard 0 or 1 depending on the fixed threshold at `0.5`.
- Teaching goal: Demonstrate how `math.rect` converts a continuous normalized signal into a binary gate.

## Support Nodes

- Required: [`math.add`, `analyse.specs`, `math.clear`]
- Optional: []
- Rationale: A seeded normalized input makes the thresholding action visible, `analyse.specs` shows the transition to binary output, and `math.clear` safely terminates the artificial signal.

## Assumptions

- Channels: default stereo
- Public control needed: no
- Raw node values acceptable: yes

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Seed the signal on either side of `0.5` so the fixed threshold behavior is obvious.
- Mention that the threshold is hardcoded and cannot be changed.
- End with `math.clear` because this is a deliberately artificial gate test.
