# control.logic_op - HSC Scenario

## Node

- Factory path: `control.logic_op`
- Source page: `scriptnode_enrichment/output/control/logic_op.md`

## Scenario

- Title: Transport-And-User Effect Enable
- Project context: An effect should process only when the DAW is playing and a public Enable switch is on. `control.logic_op` combines those two binary conditions with AND and controls one soft-bypass wrapper around the effect stage.
- Teaching goal: Demonstrate boolean thresholding, two-input initialisation, and strict binary output from the AND operator.

## Support Nodes

- Required: [`control.transport`, `container.soft_bypass`, `filters.svf`]
- Optional: []
- Rationale: `control.transport` supplies the host play state; `container.soft_bypass` accepts the combined binary result as a click-free activation value; and `filters.svf` provides an audible processing stage whose presence confirms the compound condition.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: yes

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Connect `control.transport` to Left, a public two-state Enable parameter to Right, lock Operator to AND, and connect the result to the soft-bypass activation input.
- Initialise both operands explicitly after reset. `control.logic_op` sends no output until Left and Right have each received at least one value.
- Keep both controls strictly at 0 or 1 even though logic thresholding accepts any value above 0.5 as true.
- Put one clearly audible LP filter inside `container.soft_bypass` and use non-zero `SmoothingTime` so transport changes do not click.
- Verify all four truth-table combinations. The effect must be active only for Playing=1 and Enable=1.
- Label the soft-bypass polarity carefully: values at or above 0.5 activate processing rather than bypassing it.
