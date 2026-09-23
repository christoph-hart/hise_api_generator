# control.minmax - HSC Scenario

## Node

- Factory path: `control.minmax`
- Source page: `scriptnode_enrichment/output/control/minmax.md`

## Scenario

- Title: Adjustable Filter Sweep Range
- Project context: A repeating normalised ramp sweeps a lowpass filter while public Minimum and Maximum controls redefine the cutoff interval at runtime. Skew changes how long the sweep spends in low frequencies without changing its endpoints.
- Teaching goal: Demonstrate normalised-to-native range mapping with runtime-adjustable bounds, skew, and unscaled output.

## Support Nodes

- Required: [`container.modchain`, `core.ramp`, `filters.svf`]
- Optional: []
- Rationale: `container.modchain` isolates ramp generation; `core.ramp` supplies the full 0 to 1 traversal needed to inspect mapping; and `filters.svf` accepts the resulting raw frequency values and makes endpoint and skew changes audible.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: yes

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Connect `core.ramp` from a modchain to `control.minmax.Value`, then connect the minmax output directly to `filters.svf.Frequency`.
- Override Minimum and Maximum ranges to a shared native frequency domain and expose them as Low Cutoff and High Cutoff. The output is unscaled, so the target must receive those exact Hz values without another range conversion.
- Expose Skew, lock Step to zero, and keep Polarity Normal for the canonical smooth sweep.
- Enforce or document Minimum <= Maximum so user controls do not create an unintended reversed range.
- Keep SVF smoothing non-zero and lock mode and Q.
- Verify both endpoints and at least one nonlinear Skew value, then optionally set a non-zero Step temporarily to demonstrate quantisation without making it part of the canonical startup state.
