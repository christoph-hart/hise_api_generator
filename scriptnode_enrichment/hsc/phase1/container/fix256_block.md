# container.fix256_block - HSC Scenario

## Node

- Factory path: `container.fix256_block`
- Source page: `scriptnode_enrichment/output/container/fix256_block.md`

## Scenario

- Title: Minimal Large-Buffer Split
- Project context: A one-second ramp is centred and folded into a triangular control shape, then rendered as an additive staircase updated every 256 samples. In a 512-sample host callback this produces only two coarse updates, clearly demonstrating why practical modulation usefulness decays at this size.
- Teaching goal: Demonstrate the host-buffer dependency and deliberately coarse update resolution of the largest fixed-block container.

## Support Nodes

- Required: [`analyse.specs`, `container.modchain`, `core.ramp`, `math.sub`, `math.abs`, `core.peak`, `math.add`]
- Optional: []
- Rationale: `analyse.specs` displays the local block size for inspection only; `container.modchain` isolates control generation; `core.ramp`, `math.sub`, and `math.abs` create the folded triangle; `core.peak` samples it once per chunk; and `math.add` renders the resulting 256-sample plateaus.

## Assumptions

- Channels: default stereo
- Public control needed: no
- Raw node values acceptable: yes

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Duplicate the dynamic-blocksize triangle topology under `container.fix256_block`: inspection specs, then `core.ramp -> math.sub -> math.abs -> core.peak` in a modchain, with peak modulation driving `math.add.Value`.
- Visual verification must cover two host settings: at least 512 samples to show subdivision and 256 samples or less to show that no extra chunking occurs.
- Set the ramp period to 1000 ms, subtract 0.5, and take the absolute value. The folded motion makes the extremely coarse zipper steps easy to hear. Use silent input and conservative monitoring because the generated staircase is unipolar and DC-rich.
- At a 512-sample host size, expect two full chunks; do not claim this node improves resolution for an incoming block of 256 samples or less.
- Bypassing re-prepares the children and returns them to host-buffer processing; allow that transition to settle before capture.
- The nominal 172 Hz update figure applies at 44.1 kHz. Treat 256 as a maximum because a final host-buffer remainder can be shorter.
