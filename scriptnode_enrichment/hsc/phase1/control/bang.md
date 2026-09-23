# control.bang - HSC Scenario

## Node

- Factory path: `control.bang`
- Source page: `scriptnode_enrichment/output/control/bang.md`

## Scenario

- Title: Desynchronised Sample-and-Hold Sweep
- Project context: A free-running ramp continuously updates the stored Value of `control.bang`, while a timer with a non-matching period triggers its Bang input. Each trigger captures a different ramp phase and sends the held result to a lowpass cutoff, producing a quasi-random stepped filter pattern.
- Teaching goal: Demonstrate that changing Value only updates stored state and that output occurs only when Bang receives a trigger above 0.5.

## Support Nodes

- Required: [`container.modchain`, `core.ramp`, `control.timer`, `control.bang`, `control.normaliser`, `filters.svf`]
- Optional: []
- Rationale: `container.modchain` isolates the generated control signals from audio; `core.ramp` supplies the continuously changing value; `control.timer` supplies periodic Ping triggers at a deliberately desynchronised interval; `control.bang` holds and emits the ramp value; `control.normaliser` bridges the raw 0..1 bang output to the filter cutoff range; and `filters.svf` turns each captured value into an audible held cutoff step.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: no

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Inside `container.modchain`, connect `core.ramp` modulation output to `control.bang.Value` and `control.timer` output to `control.bang.Bang`; connect the bang output through `control.normaliser` to `filters.svf.Frequency` outside the modchain.
- Set the timer Mode property to Ping and choose ramp and timer periods whose ratio is not an integer. The timer output must cross 0.5 on every tick.
- Set the normaliser Value range to `[0, 1]` so the target cutoff range conversion maps the held output to `[200, 8000]` Hz.
- Expose ramp period and trigger interval with clear units. Changing the ramp alone must not move cutoff until the next bang.
- `control.timer` has a documented crash risk in DAW plugins and standalone apps. Restrict this canonical example to HISE development and do not publish it as export-safe without resolving that issue.
