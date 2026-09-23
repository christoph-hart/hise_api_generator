# control.pack4_writer - HSC Scenario

## Node

- Factory path: `control.pack4_writer`
- Source page: `scriptnode_enrichment/output/control/pack4_writer.md`

## Scenario

- Title: Four-Layer Stereo Placement
- Project context: Four cloned tone layers share one oscillator setup but have independent pan positions. Four public controls write a pack that `control.clone_pack` distributes to the corresponding panner in each clone.
- Teaching goal: Demonstrate direct four-parameter pack writing and fixed index ownership for independently positioned clone layers.

## Support Nodes

- Required: [`container.clone`, `control.clone_pack`, `core.oscillator`, `jdsp.jpanner`]
- Optional: []
- Rationale: `container.clone` creates four identical layer chains; `control.clone_pack` reads one written value per clone; `core.oscillator` supplies each layer; and `jdsp.jpanner` maps each pack entry to an audible stereo position.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: no

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Lock all clone-related counts to four and build identical child chains containing `core.oscillator -> jdsp.jpanner`.
- Assign writer and clone pack to the same external SliderPack slot and initialise it in Interface `onInit`.
- Expose four bipolar Pan controls but map them to writer Values 0 to 1; clone-pack output then maps to `jdsp.jpanner.Pan` from -1 to +1.
- Verify Value1 through Value4 write pack indices 0 through 3 and move only the matching clone panner.
- Connecting the writer must resize the pack to four. Keep panner rules identical and oscillator gains conservative.
- This example uses pack data for arbitrary per-clone values; do not replace it with formula-based `control.clone_cable` spread.
