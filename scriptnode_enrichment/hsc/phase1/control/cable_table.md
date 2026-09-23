# control.cable_table - HSC Scenario

## Node

- Factory path: `control.cable_table`
- Source page: `scriptnode_enrichment/output/control/cable_table.md`

## Scenario

- Title: Linear Versus Shaped Filter Control
- Project context: A stereo comparison sends the same public Cutoff control directly to a left-channel lowpass filter and through a skewed visual table to an identical right-channel filter. Sweeping the control reveals how interpolation through `control.cable_table` creates a nonlinear response while preserving smooth movement.
- Teaching goal: Demonstrate interpolated visual remapping of a normalised control signal against an unmodified reference path.

## Support Nodes

- Required: [`container.multi`, `filters.svf`]
- Optional: []
- Rationale: `container.multi` assigns independent left and right channel slices for simultaneous comparison, and two identically configured `filters.svf` instances provide audible targets, with only the right filter receiving the table-shaped control.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: no

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Configure two mono children under `container.multi`: a left reference SVF and a right mapped SVF. Keep mode, Q, smoothing, and frequency target ranges identical.
- Connect one Cutoff macro directly to the left filter and to `control.cable_table.Value`; connect the table output to the right filter.
- Initialise a monotonic skewed curve through an external Table data slot and Interface `onInit` setup. Do not embed the programmable table because embedded complex data cannot be changed from script.
- Use a curve that preserves 0 and 1 endpoints while clearly spending more travel in the low-frequency region. Linear interpolation must remain enabled by the node's normal lookup behaviour.
- Verify matched left/right output at both endpoints and divergent cutoff movement at intermediate control positions.
- If stereo source content is not matched, use a duplicated mono test source for verification so source differences are not mistaken for mapping differences.
