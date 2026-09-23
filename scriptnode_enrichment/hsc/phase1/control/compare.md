# control.compare - HSC Scenario

## Node

- Factory path: `control.compare`
- Source page: `scriptnode_enrichment/output/control/compare.md`

## Scenario

- Title: Minimum Filter Cutoff Guard
- Project context: A lowpass filter exposes Frequency and Minimum Frequency controls. `control.compare` runs in MAX mode and forwards whichever normalised value is higher, preventing the effective cutoff from dropping below the user-defined floor.
- Teaching goal: Demonstrate that MAX is a continuous two-input selector rather than a binary comparison result.

## Support Nodes

- Required: [`filters.svf`]
- Optional: []
- Rationale: `filters.svf` provides an audible cutoff target whose effective value clearly follows Frequency until it falls below Minimum Frequency, at which point the compare node holds the configured floor.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: no

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Connect the normalised Frequency macro to `control.compare.Left`, Minimum Frequency to Right, and the compare output to `filters.svf.Frequency`.
- Lock Comparator to MAX. Do not describe or configure the output as a boolean gate; it must return the larger continuous operand.
- Give both public controls the same displayed frequency range and inverse-map them to matching 0 to 1 compare inputs before mapping the output back to the filter's frequency range.
- Keep the SVF in LP mode with non-zero smoothing and lock Q so only cutoff guarding is demonstrated.
- Verify three states: Frequency above the minimum, Frequency below the minimum, and equal operands. Output updates only when an operand or comparator value changes.
- Avoid EQ as a secondary demonstration because it performs exact floating-point equality with no tolerance and distracts from the MAX use case.
