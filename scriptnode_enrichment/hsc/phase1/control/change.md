# control.change - HSC Scenario

## Node

- Factory path: `control.change`
- Source page: `scriptnode_enrichment/output/control/change.md`

## Scenario

- Title: Duplicate-Free Four-Step Sweep
- Project context: A repeating ramp is quantised into four exact plateau values by a cable expression. Although the expression is evaluated repeatedly within each plateau, `control.change` forwards only transitions to a lowpass cutoff.
- Teaching goal: Demonstrate exact duplicate suppression and the initial stored-value behaviour using deliberately repeated control values.

## Support Nodes

- Required: [`container.modchain`, `core.ramp`, `control.cable_expr`, `control.change`, `control.normaliser`, `filters.svf`]
- Optional: []
- Rationale: `container.modchain` isolates control generation; `core.ramp` supplies continuous motion; `control.cable_expr` quantises it to repeated exact values; `control.change` forwards only transitions; `control.normaliser` maps the raw transition values into the filter frequency range; and `filters.svf` makes the four forwarded transitions audible as cutoff steps.

## Assumptions

- Channels: default stereo
- Public control needed: no
- Raw node values acceptable: no

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Build `core.ramp -> control.cable_expr -> control.change -> control.normaliser` in the modulation path and connect the normaliser output to `filters.svf.Frequency` with an explicit four-level range.
- Use a compile-enabled network and lock the quantiser expression to `Math.min(Math.floor(input * 4.0), 3.0) / 3.0`, producing exactly 0, 1/3, 2/3, and 1 while handling the input endpoint without a fifth level.
- Trace cable-expression output and change output simultaneously: repeated plateau values must appear upstream but only first transitions downstream.
- The change node starts with stored value 0.0, so the first incoming zero is intentionally suppressed. Begin verification with that case.
- Exact floating-point comparison has no tolerance; the quantiser must generate bit-identical plateau values rather than noisy approximations.
- Keep SVF smoothing short but non-zero and lock mode and Q. The normaliser must remain behind `control.change` so duplicate suppression happens before range mapping.
