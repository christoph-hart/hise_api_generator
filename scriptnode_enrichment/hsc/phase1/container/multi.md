# container.multi - HSC Scenario

## Node

- Factory path: `container.multi`
- Source page: `scriptnode_enrichment/output/container/multi.md`

## Scenario

- Title: Per-Channel Stereo Panner
- Project context: A stereo signal is divided into independent left and right channel slices. A two-output crossfader drives one multiplier in each slice with complementary gains, turning a single Pan control into channel-specific level processing.
- Teaching goal: Demonstrate that `container.multi` assigns non-overlapping channel ranges to its children rather than copying and summing the same channels.

## Support Nodes

- Required: [`control.xfader`, `math.mul`]
- Optional: []
- Rationale: `control.xfader` converts the shared Pan position into two complementary coefficients, while one `math.mul` child per channel applies the corresponding coefficient only to the slice assigned by `container.multi`.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: no

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Configure exactly two children under `container.multi`; child 0 contains the left-channel `math.mul` and child 1 contains the right-channel `math.mul`.
- Place one two-output `control.xfader` before the multi container in the parent serial chain and connect its first and second outputs to the left and right multiplier values respectively.
- Expose a bipolar Pan macro and map it to `control.xfader.Value` from 0 to 1. Label the public endpoints left, centre, and right rather than exposing the raw normalised domain.
- Select RMS mode for constant-power panning and verify centre gain and endpoint muting on both channels. Do not use Harmonics mode because it can exceed the multiplier's 0 to 1 range.
- Visual verification must confirm that each child receives one channel and that no child count exceeds the two-channel context.
- This topology attenuates existing left and right content independently; it does not convert a stereo input to mono before panning and therefore is not equivalent to panning a mono source duplicated to both channels.
