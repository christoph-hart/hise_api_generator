# control.cable_pack - HSC Scenario

## Node

- Factory path: `control.cable_pack`
- Source page: `scriptnode_enrichment/output/control/cable_pack.md`

## Scenario

- Title: Tempo-Synced Filter Step Sequencer
- Project context: A DAW-synchronised ramp scans an eight-value slider pack once per bar. `control.cable_pack` selects the nearest programmed step without interpolation and sends it to a lowpass cutoff, producing a repeatable rhythmic filter sequence.
- Teaching goal: Demonstrate discrete slider-pack lookup and the direct relationship between pack size, input zones, and held output values.

## Support Nodes

- Required: [`core.clock_ramp`, `filters.svf`]
- Optional: []
- Rationale: `core.clock_ramp` supplies a transport-locked 0 to 1 playhead without adding to audio, and `filters.svf` turns each slider value into an audible cutoff step while remaining stable under repeated parameter changes.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: no

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Connect `core.clock_ramp` modulation output directly to `control.cable_pack.Value`, then map the cable-pack output to `filters.svf.Frequency` with an explicit musical frequency range.
- Configure exactly eight slider values and lock the clock ramp to one bar in Synced mode with `AddToSignal` disabled. Set an intentional Inactive value so stopped transport behaviour is deterministic.
- Initialise the sequence through an external SliderPack data slot and Interface `onInit` setup. Do not embed the programmable pack because embedded complex data cannot be changed from script.
- Expose the eight step values through the interface and optionally expose the clock division, but retain nearest-neighbour lookup. There must be no interpolation between steps.
- Keep SVF smoothing short but non-zero so the filter avoids zipper artefacts without blurring the intended rhythmic edges excessively.
- Verify first and last lookup zones carefully because the normalised input is rounded to a slider index and endpoint handling must not address beyond the eight-entry pack.
