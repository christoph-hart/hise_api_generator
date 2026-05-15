# math.intensity - HSC Scenario

## Node

- Factory path: `math.intensity`
- Source page: `scriptnode_enrichment/output/math/intensity.md`

## Scenario

- Title: Unity-anchored modulation depth
- Project context: A slow modulation curve should be reduced in depth without lowering its ceiling from `1.0`. The example uses a simple visible modulation source and shows how `math.intensity` keeps the top of the range fixed while shrinking the excursion.
- Teaching goal: Demonstrate how `math.intensity` scales a modulation signal around unity instead of around zero.

## Support Nodes

- Required: [`core.ramp`, `core.peak`]
- Optional: [`math.clear`]
- Rationale: A slow ramp makes the changing range easy to see, and `core.peak` can show the difference between a full 0..1 signal and the reduced-depth unity-anchored output.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: yes

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- The explanation should explicitly contrast `math.intensity` with `math.mul`, because this node is mainly about that difference in scaling behavior.
- Use a simple modulation source in the 0..1 range so the unity anchor is easy to understand.
- Terminate any artificial control signal safely if it remains in the audio path.
