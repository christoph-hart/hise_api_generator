# container.offline - HSC Scenario

## Node

- Factory path: `container.offline`
- Source page: `scriptnode_enrichment/output/container/offline.md`

## Scenario

- Title: Event-Driven Control Pipeline
- Project context: A public Amount parameter passes through a quadratic cable expression and a multiply-add range stage before controlling an audio-path multiplier. The control nodes live in `container.offline`: they never receive realtime processing callbacks, but their synchronous parameter-change handlers still propagate user value changes without continuous audio-callback work.
- Teaching goal: Demonstrate the distinction between skipped realtime processing callbacks and synchronous parameter updates for control-only children inside `container.offline`.

## Support Nodes

- Required: [`control.cable_expr`, `control.pma`, `math.mul`]
- Optional: []
- Rationale: `control.cable_expr` applies a quadratic response whenever Amount changes; `control.pma` scales that result into a safe non-zero gain interval and clamps it to 0 to 1; and `math.mul`, placed outside the offline container in the audio path, proves that the transformed value still reaches a realtime processor.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: no

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Put only `control.cable_expr` and `control.pma` inside `container.offline`; keep `math.mul` after the offline container in the parent audio chain so it continues to process samples.
- Connect the public Amount macro to `control.cable_expr.Value`, its output to `control.pma.Value`, and the PMA output to `math.mul.Value`. Lock the expression to a quadratic 0 to 1 mapping and configure PMA Multiply/Add so the final gain remains within 0 to 1 without unintended clamp plateaus.
- The network must be compile-enabled because `control.cable_expr` uses a SNEX expression and exported plugins do not contain the JIT engine.
- Verification must change Amount while audio is running and confirm immediate target gain updates, while separately confirming that offline children receive no `process`, `processFrame`, or `handleHiseEvent` activity from the realtime path.
- Children are still prepared and reset normally. Do not describe the container as a reduced-rate processor: it skips realtime processing and event callbacks entirely, and this example works only because these control nodes react synchronously to parameter changes.
- Audio entering `container.offline` must pass through unchanged before reaching `math.mul`.
