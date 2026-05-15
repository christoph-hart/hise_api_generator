# routing.selector - HSC Scenario

## Node

- Factory path: `routing.selector`
- Source page: `scriptnode_enrichment/output/routing/selector.md`

## Scenario

- Title: Cab mic pair selector
- Project context: A guitar cabinet processor receives two internal stereo mic pairs: a close pair on channels 0-1 and a room pair on channels 2-3. The project needs a public control that chooses which pair feeds the cabinet tone-shaping chain.
- Teaching goal: Demonstrate how `routing.selector` dynamically copies one selected stereo pair to the front of a multichannel buffer for downstream processing.

## Support Nodes

- Required: [`container.multi`, `container.chain`, `filters.svf_eq`, `jdsp.jcompressor`, `core.gain`]
- Optional: []
- Rationale: `container.multi` isolates the selected stereo pair after routing. EQ, compressor, and gain provide a minimal real-world FX chain that makes the routing use case concrete.

## Assumptions

- Channels: multichannel required
- Public control needed: yes
- Raw node values acceptable: yes

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- This node is unusually channel-topology dependent. The example must explicitly show the difference between HISE stereo output, the Master Chain's internal four-channel routing, and the ScriptFX four-channel input.
- The public mic selector should expose raw channel offsets, not abstract indices: `0 = channels 0-1`, `2 = channels 2-3`.
