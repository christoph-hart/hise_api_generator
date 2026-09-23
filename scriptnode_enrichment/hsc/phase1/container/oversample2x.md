# container.oversample2x - HSC Scenario

## Node

- Factory path: `container.oversample2x`
- Source page: `scriptnode_enrichment/output/container/oversample2x.md`

## Scenario

- Title: Lightweight Soft Saturation
- Project context: A stereo insert applies moderate pre-gain, tanh saturation, and output trim inside a fixed 2x oversampling stage. Bypassing only the container's resampling allows the same saturator to be compared at the original rate without changing its drive.
- Teaching goal: Demonstrate fixed 2x processing as the lowest-cost oversampling choice for a nonlinear effect that produces a modest harmonic spectrum.

## Support Nodes

- Required: [`math.mul`, `math.tanh`]
- Optional: [`analyse.fft`]
- Rationale: A pre-gain `math.mul` pushes incoming audio into `math.tanh`, the tanh node supplies bounded soft saturation, and a second multiplier restores a comparable output level; an optional FFT provides consistent visual comparison of folded harmonics between 1x and 2x processing.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: no

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Keep the pre-gain, `math.tanh`, and output-trim nodes together inside `container.oversample2x` so every nonlinear operation and its gain staging use the doubled preparation specs.
- Override the pre-gain multiplier range above unity, expose it as Drive, and lock output trim to a safe value. `core.gain` cannot provide positive pre-gain because its range stops at 0 dB.
- Use Polyphase filtering initially and verify at a base rate such as 44.1 kHz that child preparation reports twice that sample rate and block size.
- Compare active and bypassed states with identical input and drive. Bypass removes resampling but continues to run every child at the original rate and re-prepares the chain.
- Keep the network monophonic and block-based, and do not place this container inside another oversampling container.
- If an FFT is used, place it after the container and keep analyser settings fixed. Also compare output level so a louder result is not mistaken for better quality.
- Avoid parallel dry mixing because the anti-aliasing stage adds latency that is not reported to the surrounding network.
