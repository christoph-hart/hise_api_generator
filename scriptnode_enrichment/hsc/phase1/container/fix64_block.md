# container.fix64_block - HSC Scenario

## Node

- Factory path: `container.fix64_block`
- Source page: `scriptnode_enrichment/output/container/fix64_block.md`

## Scenario

- Title: Slowly Evolving Filter Tone
- Project context: A root Tone control makes abrupt normalized jumps, but `control.smoothed_parameter` turns each jump into a long linear transition before driving a low-pass filter cutoff. Both smoother and filter run inside a 64-sample container, showing that slow modulation remains clean at a low-overhead chunk cadence.
- Teaching goal: Demonstrate that `container.fix64_block` is a sensible default for slowly evolving modulation: its parameter updates are much finer than the smoothing trajectory requires, while it avoids the iteration cost of 8-, 16-, and 32-sample containers.

## Support Nodes

- Required: [`control.smoothed_parameter`, `filters.svf`]
- Optional: []
- Rationale: `control.smoothed_parameter` converts abrupt root control changes into a deterministic long ramp, and `filters.svf` provides an audible cutoff target whose own smoothing can be disabled so the control node and 64-sample cadence remain authoritative.

## Assumptions

- Channels: default stereo
- Public control needed: yes; normalized `Tone` drives the smoother target
- Raw node values acceptable: no

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Place the smoother before the filter inside `container.fix64_block` so each child chunk updates the smoothed value before processing audio with the new cutoff.
- Set `control.smoothed_parameter.Mode` to Linear Ramp and use the maximum 1000 ms smoothing time. Slow movement makes 64-sample update steps negligible for this use case.
- Set the filter Frequency range before connecting the smoother output, using a musically useful skewed range from 200 to 8000 Hz.
- Set filter Smoothing to exactly zero. Otherwise the example stacks a second smoothing stage on top of `control.smoothed_parameter` and obscures which node defines the transition.
- Feed noise or another harmonically rich signal into the Script FX for verification. Injecting silence cannot demonstrate cutoff movement.
- Describe 64 samples as a maximum chunk size because a final host-buffer remainder can be shorter, and explain that 64 is the default starting point for adjustable block containers.
