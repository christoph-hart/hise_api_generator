# control.cable_expr - HSC Scenario

## Node

- Factory path: `control.cable_expr`
- Source page: `scriptnode_enrichment/output/control/cable_expr.md`

## Scenario

- Title: Thresholded Effect Activation
- Project context: A continuous 0 to 1 Amount control is converted into a strict off/on signal by a custom expression. Crossing the midpoint activates or bypasses a filtered effect path, while the soft-bypass wrapper keeps the resulting audio transition click-free.
- Teaching goal: Demonstrate formula-based control transformation and unscaled expression output using a simple threshold gate.

## Support Nodes

- Required: [`container.soft_bypass`, `filters.svf`]
- Optional: []
- Rationale: `container.soft_bypass` accepts the expression's binary output as its activation state and smooths audio transitions, while `filters.svf` supplies an audible processed state that differs clearly from bypass.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: yes

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Connect a public Amount macro to `control.cable_expr.Value`, then connect expression output to the soft-bypass activation input around one LP SVF.
- Lock Code to `input > 0.5 ? 1.0 : 0.0` and verify exact behaviour below, at, and above 0.5. At exactly 0.5 the expression returns zero.
- Keep the network compile-enabled. Export requires compiling the network to C++ because the SNEX JIT engine is unavailable in plugins.
- Use a non-zero soft-bypass SmoothingTime so the binary control decision does not produce an abrupt audio edge.
- The expression output is unnormalised, but values are intentionally limited to exact zero and one for this target.
- If expression compilation fails, the node falls back to passthrough; verification must detect that failure rather than mistaking it for threshold operation.
