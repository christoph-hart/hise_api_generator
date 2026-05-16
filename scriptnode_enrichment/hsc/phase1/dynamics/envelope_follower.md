# dynamics.envelope_follower - HSC Scenario

## Node

- Factory path: `dynamics.envelope_follower`
- Source page: `scriptnode_enrichment/output/dynamics/envelope_follower.md`

## Scenario

- Title: Dynamic mid-cut EQ
- Project context: A bright lead or vocal-like synth should become less harsh when played harder, without using a full compressor on the whole signal. `dynamics.envelope_follower` tracks the source amplitude and drives a mid-focused peak band so louder passages automatically apply more attenuation in the harsh frequency range.
- Teaching goal: Demonstrate how `dynamics.envelope_follower` can act as the control source for a dynamic EQ style setup where amplitude modulates a filter band's gain.

## Support Nodes

- Required: [`container.fix16_block`, `filters.svf_eq`]
- Optional: [`container.fix8_block`, `math.mul`, `math.add`]
- Rationale: `filters.svf_eq` provides the actual EQ band being modulated. A fixed-block container is important here because the follower's exported modulation output drives another parameter, and `container.fix16_block` or `container.fix8_block` makes that modulation-to-parameter update timing deterministic. Simple math nodes are optional if Phase 2 needs to invert or narrow the envelope follower's 0..1 output into a musically useful attenuation range.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: no

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Keep `ProcessSignal` set to `Off`; the node should analyse the source while leaving the audio path intact.
- Wrap both the follower and the target EQ in `container.fix16_block` or `container.fix8_block` if the exported modulation-to-parameter update rate should be deterministic instead of inheriting an arbitrary parent block size.
- The modulation range will likely need narrowing and inversion so higher input level produces more mid-band attenuation rather than gain boost.
- Because this is the only polyphonic dynamics node, the example should make clear whether the target context is per-voice modulation or a simpler monophonic demonstration.
