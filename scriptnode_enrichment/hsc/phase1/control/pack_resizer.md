# control.pack_resizer - HSC Scenario

## Node

- Factory path: `control.pack_resizer`
- Source page: `scriptnode_enrichment/output/control/pack_resizer.md`

## Scenario

- Title: Clone Count Matched Drawbar Pack
- Project context: A variable-size additive oscillator bank uses one slider per active clone to set partial levels. Changing Partial Count updates the clone container and uses `control.pack_resizer` to keep the external slider pack long enough for every active clone.
- Teaching goal: Demonstrate runtime slider-pack resizing, preservation of retained entries, and truncation of entries beyond a reduced size.

## Support Nodes

- Required: [`container.clone`, `control.clone_pack`, `core.oscillator`]
- Optional: []
- Rationale: `container.clone` creates the variable number of oscillator partials; `control.clone_pack` reads one gain value per clone and exposes the failure caused by an undersized pack; and `core.oscillator` makes each retained or newly added pack entry audible.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: no

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Connect one integer Partial Count macro to `container.clone.NumClones`, `control.clone_pack.NumClones`, and `control.pack_resizer.NumSliders` with matching 1 to 16 ranges.
- Make Partial Count the first root macro as required by clone containers and keep all clone child chains identical.
- Assign the resizer and clone pack to the same external SliderPack data slot, initialised in Interface `onInit`. Do not use embedded programmable pack data.
- Trigger an explicit initial NumSliders update after data assignment because connecting the resizer alone does not resize the pack.
- Change count only from a UI or low-rate control. Resizing allocates memory and must not be driven at audio rate.
- Verify growth preserves existing values and adds defaults, shrinking removes trailing entries, values below one clamp to one, and every active clone receives a pack value.
