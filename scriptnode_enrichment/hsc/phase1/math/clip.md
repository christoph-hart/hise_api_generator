# math.clip - HSC Scenario

## Node

- Factory path: `math.clip`
- Source page: `scriptnode_enrichment/output/math/clip.md`

## Scenario

- Title: Hard-clipped ramp shaper
- Project context: A slow `core.ramp` is driven into `math.clip` with a low threshold so the output curve develops an obvious flat top in the peak display. This turns the node into a visible transfer-function example rather than a generic distortion story.
- Teaching goal: Demonstrate how `math.clip` truncates signal values at a symmetric limit and creates hard clipping.

## Support Nodes

- Required: [`core.ramp`, `math.add`, `core.peak`]
- Optional: [`math.clear`]
- Rationale: `core.ramp` provides a slow visible source, a support offset can make the clipping region more obvious, and `core.peak` shows the flattened output shape.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: yes

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Use a slow ramp such as 1000 ms so the clipped plateau is easy to read in the peak display.
- Set the clip threshold low enough that the transfer is visibly shaped instead of passing through unchanged.
- If the setup leaves an artificial signal in the audio path, terminate it safely after the visual nodes.
