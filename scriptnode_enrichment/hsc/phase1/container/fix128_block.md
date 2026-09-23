# container.fix128_block - HSC Scenario

## Node

- Factory path: `container.fix128_block`
- Source page: `scriptnode_enrichment/output/container/fix128_block.md`

## Scenario

- Title: Lightweight Large-Buffer Subdivision
- Project context: A one-second ramp is centred and folded into a triangular control shape, then rendered as an additive staircase updated every 128 samples. With a 512-sample host buffer, the coarse zipper steps provide a technical demonstration of the limited modulation usefulness of this large chunk size.
- Teaching goal: Demonstrate how `container.fix128_block` improves slow-modulation resolution in large-buffer sessions with very low dispatch overhead.

## Support Nodes

- Required: [`analyse.specs`, `container.modchain`, `core.ramp`, `math.sub`, `math.abs`, `core.peak`, `math.add`]
- Optional: []
- Rationale: `analyse.specs` displays the local block size for inspection only; `container.modchain` provides an isolated control path; `core.ramp`, `math.sub`, and `math.abs` create the folded triangle; `core.peak` exports one value per 128-sample chunk; and `math.add` makes the coarse holds visible and audible.

## Assumptions

- Channels: default stereo
- Public control needed: no
- Raw node values acceptable: yes

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Duplicate the dynamic-blocksize triangle topology under `container.fix128_block`: inspection specs, then `core.ramp -> math.sub -> math.abs -> core.peak` in a modchain, with peak modulation driving `math.add.Value`.
- Use a 512- or 1024-sample host buffer for verification so the enabled output contains multiple 128-sample levels per host callback and the bypass comparison is unambiguous.
- Set the ramp period to 1000 ms, subtract 0.5, and take the absolute value. The folded motion makes 128-sample zipper steps easy to hear and compare. This size is presented as a technical demonstration, not a recommendation for pitch or fast filter modulation.
- Run on silence and verify with a waveform display because the additive test output contains substantial DC. Keep monitoring gain low if it is auditioned.
- Capture active and bypassed states after re-preparation; bypass causes children to process at the full host block size.
- The nominal update rate is about 345 Hz at 44.1 kHz and scales with sample rate. A final remainder chunk may contain fewer than 128 samples.
