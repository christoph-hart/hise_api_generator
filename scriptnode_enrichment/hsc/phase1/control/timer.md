# control.timer - HSC Scenario

## Node

- Factory path: `control.timer`
- Source page: `scriptnode_enrichment/output/control/timer.md`

## Scenario

- Title: Periodic Toggle Tremolo
- Project context: A timer alternates between zero and one at a fixed interval and applies that value to linear signal gain, creating a simple square-wave tremolo. Active stops the timer entirely and restarting it resets the counter.
- Teaching goal: Demonstrate sample-counted periodic output, Toggle mode, and immediate initial output when the timer becomes active.

## Support Nodes

- Required: [`math.mul`]
- Optional: []
- Rationale: `math.mul` converts the timer's binary Toggle output directly into alternating silence and unity gain without adding smoothing or another timing mechanism.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: no

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Set Mode to Toggle before compilation and connect timer output to `math.mul.Value` over 0 to 1.
- Expose Interval and Active, use a moderate startup interval, and verify enabling Active resets the counter and sends an initial value.
- Keep the timer in the audio-processing signal path because it counts processed samples.
- Each voice has an independent counter in polyphonic use; use a monophonic effect context for one shared tremolo cycle.
- `control.timer` has a documented crash risk in DAW plugins and standalone applications. Restrict this example to HISE development use and do not represent it as export-safe.
- Do not add smoothing because the hard square transition is the intended timing evidence.
