# container.chain - HSC Scenario

## Node

- Factory path: `container.chain`
- Source page: `scriptnode_enrichment/output/container/chain.md`

## Scenario

- Title: Nested Macro Modulation Chain
- Project context: A stereo filter effect uses an outer serial chain containing a control-rate ramp source followed by an inner processing chain. The ramp modulates one macro parameter on the inner chain, and that macro fans out to the cutoff and output attenuation of nodes nested inside it.
- Teaching goal: Demonstrate both serial child processing and how a container parameter can provide a clean modulation boundary for multiple parameters inside a nested `container.chain`.

## Support Nodes

- Required: [`container.modchain`, `core.ramp`, `core.peak`, `control.pma`, `filters.svf`, `core.gain`]
- Optional: []
- Rationale: `container.modchain` isolates the generated control signal from the parent audio path; `core.ramp` generates the repeating 0 to 1 sweep; `core.peak` exports that internal signal as modulation; `control.pma` creates an inverted copy without reversing the shared macro range; `filters.svf` makes the macro movement audible as a cutoff sweep; and `core.gain` provides a second nested target so the example visibly demonstrates one chain macro driving multiple children.

## Assumptions

- Channels: default stereo
- Public control needed: no
- Raw node values acceptable: no

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- The outer chain must order the modulation chain before the nested audio chain so the control source is updated before its targets are processed.
- Put `core.ramp` and then `core.peak` inside `container.modchain`; the modchain keeps the ramp's additive signal out of the stereo audio path.
- Add one macro parameter to the inner chain and connect the `core.peak` modulation output to that macro rather than directly to either processing node.
- Fan the inner macro out to `filters.svf.Frequency` and `control.pma.Value`. Configure PMA as `1 - Sweep`, then map its output to an ascending `core.gain.Gain` range. Do not reverse the Gain target range directly because connection normalization reverses the shared macro range and makes the other fan-out mapping invalid.
- Keep the SVF in LP mode and retain non-zero smoothing to avoid zipper noise during the repeating cutoff sweep.
- This is a control-rate example. Do not imply sample-accurate modulation, and do not place the modchain inside a resampled container.
