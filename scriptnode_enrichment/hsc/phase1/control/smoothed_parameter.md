# control.smoothed_parameter - HSC Scenario

## Node

- Factory path: `control.smoothed_parameter`
- Source page: `scriptnode_enrichment/output/control/smoothed_parameter.md`

## Scenario

- Title: Smoothed Stereo Pan Automation
- Project context: A public Pan control can jump instantly between left and right, but a normalised smoothing stage turns those steps into controlled movement before they reach a stereo panner. Switching smoothing off provides an immediate comparison.
- Teaching goal: Demonstrate normalised parameter smoothing, selectable curve behaviour, and Enabled bypass.

## Support Nodes

- Required: [`jdsp.jpanner`]
- Optional: []
- Rationale: `jdsp.jpanner` maps the smoother's 0 to 1 output to a bipolar stereo position, making abrupt versus smoothed parameter transitions easy to hear and measure.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: no

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Connect a normalised public Pan source to Value and map the smoothed output to `jdsp.jpanner.Pan` from -1 to +1.
- Set Mode to Linear Ramp for the canonical example, expose SmoothingTime, and keep Enabled on by default.
- Lock a constant-power panning rule and test repeated full-left/full-right jumps.
- Verify Linear Ramp reaches the target in the specified time, Low Pass approaches asymptotically when temporarily selected, and Enabled off passes changes immediately.
- Keep all values normalised through the smoothing node; use the unscaled variant for native-unit targets.
- In a polyphonic context, verify each new voice resets to the current target rather than ramping from stale state.
