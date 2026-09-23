# control.pack2_writer - HSC Scenario

## Node

- Factory path: `control.pack2_writer`
- Source page: `scriptnode_enrichment/output/control/pack2_writer.md`

## Scenario

- Title: Two-Step Filter Alternator
- Project context: Two public cutoff-level controls write a two-entry slider pack that a tempo-synchronised cable-pack reader alternates through. Editing either control updates its corresponding sequence step without directly targeting the filter.
- Teaching goal: Demonstrate fixed index mapping from Value1 and Value2 into slider-pack complex data and automatic resizing to exactly two entries.

## Support Nodes

- Required: [`core.clock_ramp`, `control.cable_pack`, `filters.svf`]
- Optional: []
- Rationale: `core.clock_ramp` scans the two-entry pattern in sync with playback; `control.cable_pack` reads the written values as discrete steps; and `filters.svf` makes both stored levels audible as alternating cutoff positions.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: no

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Assign `control.pack2_writer` and `control.cable_pack` to the same external SliderPack slot and initialise it in Interface `onInit` before setting writer values.
- Connect Value1 and Value2 to separate public Step 1 and Step 2 controls. The writer must resize the shared pack to exactly two entries on connection.
- Connect the clock ramp to cable-pack Value and the cable-pack output to an LP SVF cutoff range; keep nearest-neighbour stepping.
- Lock clock settings so one ramp cycle visits both entries predictably and keep AddToSignal disabled.
- Verify Value1 writes index 0, Value2 writes index 1, and slider-pack display updates may lag audio/control state because UI notification is asynchronous.
- Do not embed the programmable slider pack because script-side initialisation and updates require an external data slot.
