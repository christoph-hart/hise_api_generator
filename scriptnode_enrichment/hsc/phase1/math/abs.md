# math.abs - HSC Scenario

## Node

- Factory path: `math.abs`
- Source page: `scriptnode_enrichment/output/math/abs.md`

## Scenario

- Title: Folded ramp to triangle shaper
- Project context: A slow `core.ramp` is first shifted into a bipolar shape and then folded with `math.abs` so the peak display shows how absolute value can be used as a waveform-building step rather than just a numeric operation.
- Teaching goal: Demonstrate how `math.abs` folds a bipolar signal into a non-negative mirrored shape that can be used to build triangle-like transfer curves.

## Support Nodes

- Required: [`core.ramp`, `math.add`, `math.mul`, `core.peak`]
- Optional: [`math.clear`]
- Rationale: `core.ramp` provides a slow visible phasor. `math.add` and `math.mul` prepare a bipolar input so `math.abs` does something visually meaningful, and `core.peak` shows the folded output shape.

## Assumptions

- Channels: default stereo
- Public control needed: no
- Raw node values acceptable: yes

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Use a slow ramp period such as 1000 ms so the peak display clearly shows the folding action.
- The prep arithmetic should make the ramp bipolar before `math.abs`; otherwise the example is too trivial because a 0..1 ramp is already non-negative.
- If the ramp stays in the audio path, clear or otherwise terminate the artificial control signal safely.
