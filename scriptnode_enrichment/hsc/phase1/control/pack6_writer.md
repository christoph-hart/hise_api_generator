# control.pack6_writer - HSC Scenario

## Node

- Factory path: `control.pack6_writer`
- Source page: `scriptnode_enrichment/output/control/pack6_writer.md`

## Scenario

- Title: Six-Band Parametric EQ Gains
- Project context: Six cloned peak-EQ stages run serially at distributed centre frequencies. Six public band controls write a shared pack, and each pack entry sets the gain of the corresponding cloned EQ stage.
- Teaching goal: Demonstrate six fixed writer inputs driving a structured multi-parameter processor through slider-pack data.

## Support Nodes

- Required: [`container.clone`, `control.clone_cable`, `control.clone_pack`, `filters.svf_eq`]
- Optional: []
- Rationale: `container.clone` creates six identical serial EQ stages; `control.clone_cable` distributes centre frequencies; `control.clone_pack` assigns one written gain value to each clone; and `filters.svf_eq` in Peak mode provides a gain-sensitive target for every band.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: no

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Lock all clone and pack counts to six and use Serial clone mode so each peak-EQ band processes the previous band's output.
- Assign `control.pack6_writer` and `control.clone_pack` to one external SliderPack slot initialised in Interface `onInit`.
- Expose Value1 through Value6 as bipolar band-gain controls, mapping their normalised writer values to `filters.svf_eq.Gain` from -18 to +18 dB through clone-pack target ranges.
- Configure every SVF EQ in Peak mode because Gain is ignored in LowPass and HighPass modes. Lock common Q and smoothing.
- Use clone-cable Scale mode with an intentional frequency mapping and verify six distinct ordered centre frequencies.
- Connecting the writer must resize the pack to six entries. Verify each Value writes indices 0 through 5 and affects only the matching band gain.
