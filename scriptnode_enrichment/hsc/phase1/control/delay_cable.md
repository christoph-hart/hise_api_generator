# control.delay_cable - HSC Scenario

## Node

- Factory path: `control.delay_cable`
- Source page: `scriptnode_enrichment/output/control/delay_cable.md`

## Scenario

- Title: Staggered Oscillator Gate Toggles
- Project context: A periodic Toggle signal controls the Gate of one fixed-frequency oscillator immediately and reaches a second oscillator after a sample-count delay. Their alternating sustained tones expose the timing offset and the delayed node's single pending-value queue.
- Teaching goal: Demonstrate sample-counted control delay, minimum one-callback delivery, and replacement of a queued value by newer input.

## Support Nodes

- Required: [`control.timer`, `container.no_midi`, `core.oscillator`]
- Optional: []
- Rationale: `control.timer` produces repeated 0/1 state changes; `container.no_midi` keeps both test oscillators at fixed pitches; and two `core.oscillator` instances make the immediate and delayed Gate transitions audible.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: yes

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Set timer Mode to Toggle and connect its output directly to oscillator A Gate and to `control.delay_cable.Value`; connect delayed output to oscillator B Gate.
- Put both oscillators in a no-MIDI subtree, use distinct fixed frequencies, and keep their output gains conservative because both can overlap.
- Expose Delay Samples and timer Interval. Keep the delay shorter than the toggle interval for the canonical pattern so every queued transition arrives.
- Verify DelayTimeSamples zero still delivers on the next processing callback rather than synchronously, and measure timing in raw samples at more than one host block size.
- Temporarily make the timer interval shorter than the delay to prove a newer Value replaces the pending one and restarts the counter.
- `control.timer` has a documented crash risk in DAW and standalone exports. Restrict this example to HISE development use unless that issue is resolved.
- This scenario creates toggled sustained tones, not short blips or note events.
