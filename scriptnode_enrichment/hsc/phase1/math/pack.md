# math.pack - HSC Scenario

## Node

- Factory path: `math.pack`
- Source page: `scriptnode_enrichment/output/math/pack.md`

## Scenario

- Title: SliderPack lookup shaper
- Project context: A slow `core.ramp` scans through a SliderPack-driven lookup so the peak display shows how a stepped or interpolated response can be drawn by editing a small number of visible points.
- Teaching goal: Demonstrate how `math.pack` turns a 0..1 ramp into a visibly shaped output using SliderPack lookup data.

## Support Nodes

- Required: [`core.ramp`, `core.peak`]
- Optional: [`math.clear`]
- Rationale: `core.ramp` provides a slow scan through the lookup domain, and `core.peak` makes the resulting stepped or smoothed shape easy to inspect.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: yes

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Use a slow ramp such as 1000 ms so the peak display can show the pack response clearly.
- Pick a small, obviously non-linear SliderPack shape so the lookup behavior is visually distinct from `math.table`.
- Keep the example about lookup shaping rather than turning it into a full sequencer patch.
