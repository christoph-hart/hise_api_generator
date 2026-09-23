# container.branch - HSC Scenario

## Node

- Factory path: `container.branch`
- Source page: `scriptnode_enrichment/output/container/branch.md`

## Scenario

- Title: Selectable Waveshaper Modes
- Project context: A stereo distortion effect offers three mutually exclusive colours: tanh soft clipping, the rational HISE saturation curve, and sine folding. A single Mode control selects one `math.expr` child inside `container.branch`, so only the chosen waveshaper consumes processing time.
- Teaching goal: Demonstrate that `container.branch` immediately dispatches audio to exactly one indexed child while leaving the other prepared children idle.

## Support Nodes

- Required: [`math.expr`]
- Optional: []
- Rationale: Three `math.expr` instances implement the distinct tanh, HISE saturation, and sine-folding transfer functions that the branch selects between.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: yes

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Add exactly three `math.expr` children in the displayed mode order and expose the branch `Index` as a discrete three-choice Mode parameter.
- The network must be compile-enabled because every processing path contains a SNEX expression node.
- Use single-line SNEX formulas with `input` and `value` only, and suffix floating-point literals with `f`.
- Recreate the HISE saturation transfer function `(1 + k) * input / (1 + k * abs(input))`, deriving `k` from a locked saturation amount below 1.0 to avoid division by zero.
- Lock intentional drive or amount values for all three waveshapers so changing Mode compares algorithms rather than unrelated gain settings.
- Index changes are immediate and are allowed to click; the example teaches exclusive branch dispatch, not click-free effect morphing.
