# control.clone_forward - HSC Scenario

## Node

- Factory path: `control.clone_forward`
- Source page: `scriptnode_enrichment/output/control/clone_forward.md`

## Scenario

- Title: Shared Resonance Across Cloned Filters
- Project context: A parallel bank of cloned bandpass filters uses distributed cutoff frequencies but one common Resonance control. `control.clone_forward` broadcasts the exact same Q value to every active clone while leaving per-clone frequency differentiation intact.
- Teaching goal: Demonstrate unscaled one-to-all parameter forwarding and contrast it with clone-specific distribution.

## Support Nodes

- Required: [`container.clone`, `control.clone_cable`, `filters.svf`]
- Optional: []
- Rationale: `container.clone` supplies identical filter chains; `control.clone_cable` spreads cutoff values so the clones have distinct roles; and `filters.svf` exposes a Q parameter whose shared raw value clearly proves that `control.clone_forward` writes identically to every clone.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: no

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Configure identical clone child chains with one bandpass `filters.svf`, and use Parallel or Copy mode according to whether the dry input should be retained. Lock the choice and document it.
- Use `control.clone_cable` only for Frequency distribution. Connect one `control.clone_forward` to the first clone's Q target and rely on clone propagation for the remaining siblings.
- Expose Resonance in the filter's raw 0.3 to 9.9 domain and feed that exact value into `clone_forward.Value`; unscaled forwarding bypasses target range conversion.
- Synchronise NumClones ranges and make clone count the first root macro. Use one clone-forward instance per target clone container.
- Verify all active filters receive bit-identical Q values at minimum, midpoint, and maximum settings while their cutoff values remain different.
