# math.table - HSC Scenario

## Node

- Factory path: `math.table`
- Source page: `scriptnode_enrichment/output/math/table.md`

## Scenario

- Title: Drawn transfer curve shaper
- Project context: A slow `core.ramp` scans through an editable lookup table so the peak display shows the exact drawn transfer curve as an output shape. This makes the node's visual data model the main teaching point.
- Teaching goal: Demonstrate how `math.table` reshapes a 0..1 ramp according to a drawn 512-point transfer curve.

## Support Nodes

- Required: [`core.ramp`, `core.peak`]
- Optional: [`math.clear`]
- Rationale: `core.ramp` provides a slow scan through the table domain, and `core.peak` shows the resulting drawn shape clearly.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: yes

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Use a slow ramp such as 1000 ms so the table shape is readable in the peak display.
- Draw a clearly non-linear response so the lookup behaviour is obvious at a glance.
- Keep the input in the 0..1 range so the example stays about table shaping rather than range correction.
