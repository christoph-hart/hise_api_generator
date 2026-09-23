# control.pack5_writer - HSC Scenario

## Node

- Factory path: `control.pack5_writer`
- Source page: `scriptnode_enrichment/output/control/pack5_writer.md`

## Scenario

- Title: Five-Step Accent Pattern
- Project context: Five independent accent controls write a five-entry slider pack. A transport-synchronised ramp scans the pack through `control.cable_pack` and applies the discrete values to signal gain, creating an intentionally uneven five-step rhythmic cycle.
- Teaching goal: Demonstrate five fixed writer inputs and their use as separately automatable sources for slider-pack sequence data.

## Support Nodes

- Required: [`core.clock_ramp`, `control.cable_pack`, `math.mul`]
- Optional: []
- Rationale: `core.clock_ramp` supplies the repeated normalised playhead; `control.cable_pack` reads the five written entries without interpolation; and `math.mul` converts the resulting accent values directly into audible level steps.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: no

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Share one external SliderPack slot between `control.pack5_writer` and `control.cable_pack`, initialised in Interface `onInit` before writer values are applied.
- Expose Value1 through Value5 as five Accent controls and verify they write indices 0 through 4.
- Connecting the writer must resize the pack to exactly five entries. Keep cable-pack nearest-neighbour lookup so no intermediate gain values are created.
- Connect the cable-pack output to `math.mul.Value` over 0 to 1 and use a safe non-zero default pattern.
- Configure the clock ramp to visit all five zones in one cycle with AddToSignal disabled. Document that a five-step cycle may be polymetric against ordinary binary bar divisions.
- Do not embed the programmable pack, and account for asynchronous slider-pack display updates during verification.
