# control.locked_mod - HSC Scenario

## Node

- Factory path: `control.locked_mod`
- Source page: `scriptnode_enrichment/output/control/locked_mod.md`

## Scenario

- Title: Reusable Locked Ramp Modulator
- Project context: A small container packages a free-running ramp and exposes it as one draggable modulation source after the container is locked. The resulting normalised output controls a lowpass cutoff outside the reusable block using the target's frequency range.
- Teaching goal: Demonstrate how `control.locked_mod` promotes internal 0 to 1 modulation to the immediate parent container and retains normal target range conversion.

## Support Nodes

- Required: [`container.modchain`, `core.ramp`, `filters.svf`]
- Optional: []
- Rationale: `container.modchain` is the lockable reusable parent and keeps generated control audio out of the signal path; `core.ramp` supplies a normalised internal source; and `filters.svf` provides an external ranged target that proves the locked output behaves like an ordinary normalised modulation dragger.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: no

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Place `core.ramp` and `control.locked_mod` as direct children of the same `container.modchain`, then connect the ramp modulation output to `locked_mod.Value`.
- Lock that immediate parent and connect its newly exposed modulation dragger to `filters.svf.Frequency` outside the container.
- Keep the locked-mod input at 0 to 1 and define the desired cutoff range on the external connection. The normalised variant must apply target range conversion.
- Expose ramp period on the locked container so the reusable block has one clear control while its internal topology remains hidden.
- Verify that nesting `control.locked_mod` one level deeper fails to expose it on the intended parent, then restore direct-child placement for the canonical topology.
- Keep the reusable block as a modchain so the ramp's additive signal remains confined to its internal control buffer.
