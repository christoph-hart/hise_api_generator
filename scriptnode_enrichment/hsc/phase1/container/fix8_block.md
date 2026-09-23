# container.fix8_block - HSC Scenario

## Node

- Factory path: `container.fix8_block`
- Source page: `scriptnode_enrichment/output/container/fix8_block.md`

## Scenario

- Title: Event-Raster Vibrato
- Project context: A fixed-rate triangle LFO applies depth-controlled vibrato to a sine oscillator by modulating its frequency ratio inside an 8-sample container. This mirrors HISE's 8-sample `HISE_EVENT_RASTER`; at maximum Intensity the range is exactly plus or minus 20 cents, making subtle stepped-pitch sidebands inspectable in the sine spectrum.
- Teaching goal: Demonstrate that `container.fix8_block` provides the highest precision in the fixed-block family and is appropriate when subtle pitch modulation should update at event-raster resolution without per-sample frame processing.

## Support Nodes

- Required: [`container.modchain`, `container.no_midi`, `core.oscillator`, `math.sig2mod`, `core.peak`, `control.bipolar`]
- Optional: []
- Rationale: `container.modchain` isolates the LFO from the audible path; `container.no_midi` prevents played notes from retuning the fixed-rate LFO; the triangle `core.oscillator` generates bipolar modulation; `math.sig2mod` converts it to 0 to 1; `core.peak` exports one value per child chunk; `control.bipolar` scales excursion around the neutral midpoint without shifting pitch; and the audible sine `core.oscillator` exposes stepped-pitch sidebands clearly because no saw harmonics mask them.

## Assumptions

- Channels: default stereo; LFO generation uses an isolated mono modchain
- Public control needed: yes; `Intensity` controls `control.bipolar.Scale` from 0 to 1
- Raw node values acceptable: yes

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Place both the complete LFO control path and audible oscillator inside `container.fix8_block` so source updates and target processing share an at-most-eight-sample cadence.
- Build the control path as `container.modchain -> container.no_midi -> triangle core.oscillator -> math.sig2mod -> core.peak`, send the peak value through `control.bipolar`, and route its output to `Freq Ratio` over `2^(-20/1200)` through `2^(20/1200)` with middle position `1.0`.
- Set `control.bipolar.Scale` to 0 to 1 before creating and matching root `Intensity`. A matched parameter connection can copy the target's current range back to the root parameter, so connecting first would expose the bipolar node's original -1 to 1 Scale range. Intensity 0 must collapse to neutral ratio 1.0 and Intensity 1 must reach plus or minus 20 cents.
- Use a sine wave at a fixed audible base frequency, enable both oscillator gates, and keep output gain conservative so the example runs from silent Script FX input without MIDI setup. The sine spectrum exposes zipper sidebands that a saw wave would mask with its harmonics.
- Describe 8 samples as a maximum chunk size because a final remainder chunk can be shorter.
- Explain that this size mirrors `HISE_EVENT_RASTER`, making it a natural high-resolution block choice for subtle vibrato and other pitch modulation that should track HISE event timing.
- Keep unrelated processing outside this container; subdividing unmodulated nodes adds call overhead without improving modulation precision.
