# control.xy - HSC Scenario

## Node

- Factory path: `control.xy`
- Source page: `scriptnode_enrichment/output/control/xy.md`

## Scenario

- Title: Filter And Pan XY Pad
- Project context: One two-dimensional gesture controls lowpass cutoff horizontally and stereo position vertically. The X output uses normalised target mapping, while the bipolar Y output maps directly across left and right.
- Teaching goal: Demonstrate independent output slots and the different native ranges of the X and Y axes.

## Support Nodes

- Required: [`filters.svf`, `jdsp.jpanner`]
- Optional: []
- Rationale: `filters.svf.Frequency` provides a useful unipolar destination for X, and `jdsp.jpanner.Pan` provides a native bipolar destination for Y, making axis identity and range differences explicit.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: no

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Connect output slot X to `filters.svf.Frequency` with an explicit musical cutoff range and output slot Y to `jdsp.jpanner.Pan` from -1 to +1.
- Expose both X and Y through one Interface XY pad, preserving X as 0 to 1 and Y as -1 to +1.
- Lock filter mode, Q, and non-zero smoothing, and lock a constant-power panner rule.
- Verify all four corners and the centre. Horizontal movement must not change pan and vertical movement must not change cutoff.
- Do not normalise Y a second time; its parameter is already bipolar.
