# control.xfader - HSC Scenario

## Node

- Factory path: `control.xfader`
- Source page: `scriptnode_enrichment/output/control/xfader.md`

## Scenario

- Title: Three-Way Effect Morph
- Project context: One Morph control moves across dry, filtered, and saturated parallel paths. `control.xfader` generates three overlapping gain coefficients so adjacent paths crossfade instead of switching abruptly.
- Teaching goal: Demonstrate multi-output coefficient distribution, output-slot ordering, and selectable fade curves.

## Support Nodes

- Required: [`container.split`, `math.mul`, `filters.svf`, `math.tanh`]
- Optional: []
- Rationale: `container.split` copies and sums the three paths; one `math.mul` at the end of each path applies its xfader coefficient; `filters.svf` and `math.tanh` make the second and third destinations audibly distinct from the dry path.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: no

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Set NumParameters to three and connect output slots in order to the final multiplier of dry, filtered, and saturated split branches.
- Expose Value as Morph from 0 to 1 and use RMS mode for the canonical overlapping crossfade.
- Keep processing nodes before each branch's final multiplier and lock filter and saturation settings so path identity remains stable.
- Verify endpoint isolation and the two adjacent overlap regions. Account for correlation when judging perceived loudness.
- Do not use Harmonics mode because higher outputs can exceed 1 and the branch multipliers expect 0 to 1.
- Ensure every path has gain control; otherwise an unscaled branch remains present regardless of Morph.
