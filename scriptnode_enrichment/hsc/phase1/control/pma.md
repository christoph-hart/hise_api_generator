# control.pma - HSC Scenario

## Node

- Factory path: `control.pma`
- Source page: `scriptnode_enrichment/output/control/pma.md`

## Scenario

- Title: Inverted Tremolo With Gain Floor
- Project context: A normalised ramp is inverted and scaled so gain moves from unity down to a configurable floor rather than reaching silence. `control.pma` performs the multiply-add transformation before a linear audio multiplier.
- Teaching goal: Demonstrate normalised scaling, offset, inversion, and final 0 to 1 clamping with the PMA formula.

## Support Nodes

- Required: [`container.modchain`, `core.ramp`, `math.mul`]
- Optional: []
- Rationale: `container.modchain` isolates the ramp from audio; `core.ramp` provides an obvious 0 to 1 input; and `math.mul` exposes the transformed PMA result directly as gain without extra unit conversion.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: no

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Connect the modchain ramp output to `control.pma.Value` and the PMA output to `math.mul.Value`.
- Lock Add to 1.0 and expose Multiply as a negative Depth control from 0 to -1. A moderate default such as -0.75 creates a 0.25 gain floor.
- Keep all source and target ranges normalised. The output clamp must prevent values outside 0 to 1.
- Verify Value endpoints against the exact formula and show that Multiply 0 produces constant unity gain.
- Keep `core.ramp` inside the modchain because it otherwise adds a DC-rich signal to the audio path.
- Changing Value, Multiply, and Add separately causes separate output updates; initialise locked values before starting the ramp connection.
