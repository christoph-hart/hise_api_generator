# container.fix_blockx - HSC Scenario

## Node

- Factory path: `container.fix_blockx`
- Source page: `scriptnode_enrichment/output/container/fix_blockx.md`

## Scenario

- Title: Legacy Design-Time Block Selection
- Project context: The folded-triangle staircase from `container.dynamic_blocksize` is duplicated without a mapped root parameter. A hidden BlockSize property selects the child cadence, illustrating the legacy design-time mechanism while directing readers to the dynamic or static fixed-size alternatives.
- Teaching goal: Document `container.fix_blockx` for compatibility while explaining that it is effectively deprecated: prefer `container.dynamic_blocksize` for runtime selection or a `container.fixN_block` node when the size is known.

## Support Nodes

- Required: [`analyse.specs`, `container.modchain`, `core.ramp`, `math.sub`, `math.abs`, `core.peak`, `math.add`]
- Optional: []
- Rationale: `analyse.specs` displays the selected local size for inspection only; `container.modchain` isolates control generation; `core.ramp`, `math.sub`, and `math.abs` produce the same folded triangle used by the dynamic example; `core.peak` exports one value per chunk; and `math.add` renders the selected cadence as audible zipper steps.

## Assumptions

- Channels: default stereo
- Public control needed: no
- Raw node values acceptable: yes

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Duplicate the `container.dynamic_blocksize` folded-triangle topology without its mapped root BlockSize parameter: inspection specs, then `core.ramp -> math.sub -> math.abs -> core.peak` in a modchain, with peak modulation driving `math.add.Value`.
- Use the hidden `BlockSize` property, not a network parameter, to select 8, 16, 32, 64, 128, or 256 samples. Explicitly link to `container.dynamic_blocksize` and state that new graphs should normally use it or a static `fixN_block` node instead.
- Run on silent input because `math.add` intentionally emits a DC-rich staircase. Include waveform inspection and use conservative monitoring levels.
- Lock the legacy property to 64 samples for the canonical example and verify that local specs report 64.
- Treat property changes as design-time operations: changing the size re-prepares children and may briefly interrupt audio.
- Record the selected property value explicitly in Phase 2 because compilation bakes that value into a static path equivalent to the corresponding `fixN_block` node.
