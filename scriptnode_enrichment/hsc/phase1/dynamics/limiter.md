# dynamics.limiter - HSC Scenario

## Node

- Factory path: `dynamics.limiter`
- Source page: `scriptnode_enrichment/output/dynamics/limiter.md`

## Scenario

- Title: Fixed-lookahead peak safety limiter
- Project context: A stereo Script FX chain ends with a `core.expr` waveshaper that adds strong non-linear colour without being a literal hard clipper, but can still create overs that need containment. The final processor is `dynamics.limiter`, configured as a safety stage to catch transient peaks before the signal leaves the effect.
- Teaching goal: Demonstrate how `dynamics.limiter` is used as a final peak-control stage, with its attack treated as a fixed lookahead/latency setting rather than a performance control.

## Support Nodes

- Required: [`core.expr`]
- Optional: [`core.gain`, `math.mul`]
- Rationale: `core.expr` provides a realistic non-linear stage that can produce overs without relying on a nonexistent dedicated clipper node. Optional gain or modulation wiring can make the amount of limiting visible, but the limiter itself should stay the focus.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: yes

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- The example should present `Attack` as a fixed setup parameter because changing it at runtime changes lookahead latency and causes clicks.
- If the module context is described, mention that DAW latency compensation may need manual handling because the limiter's latency is not automatically reported.
- Lock the upstream `core.expr` shaper to a very simple single-line SNEX formula such as `input + value * input * input * input` so Phase 3 does not have to improvise code.
- If the upstream waveshaper level is made public, keep it simple so the limiter remains the main teaching point rather than turning the example into a waveshaper showcase.
- Keep the ratio high enough that the node clearly behaves like a limiter, not just a mild compressor.
