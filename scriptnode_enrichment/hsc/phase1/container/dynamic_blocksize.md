# container.dynamic_blocksize - HSC Scenario

## Node

- Factory path: `container.dynamic_blocksize`
- Source page: `scriptnode_enrichment/output/container/dynamic_blocksize.md`

## Scenario

- Title: Adjustable Modulation Staircase
- Project context: A generated ramp controls the value of an additive signal stage inside a block-size container. Switching the public Block Size control from per-sample processing to progressively larger chunks turns the smooth ramp into increasingly coarse audible and visible steps.
- Teaching goal: Demonstrate that `container.dynamic_blocksize` changes child update granularity at runtime and exposes the resulting precision-versus-processing tradeoff.

## Support Nodes

- Required: [`analyse.specs`, `container.modchain`, `core.ramp`, `math.sub`, `math.abs`, `core.peak`, `math.add`]
- Optional: []
- Rationale: `analyse.specs` displays the selected local block size for inspection only and is not load-bearing; `container.modchain` creates an isolated mono control path inside the selected block context; `core.ramp` generates a slow 0 to 1 source; `math.sub` and `math.abs` centre and fold it into a repeating triangular control shape; `core.peak` exports each processed chunk's value as modulation; and `math.add` converts those discrete parameter updates into an audible staircase on an otherwise silent signal.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: no

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Place `analyse.specs`, the modulation chain, and `math.add` inside `container.dynamic_blocksize` so the UI displays the local processing specification and the functional nodes share the selected child block size. Comment that `analyse.specs` is an inspection-only design tool which may be omitted without changing behavior.
- Inside the modchain, use `core.ramp -> math.sub -> math.abs -> core.peak`. Set subtraction to `0.5` so the ramp folds around its midpoint, then connect the peak modulation output to `math.add.Value` with matching 0 to 1 ranges.
- Run the example in a generator or otherwise silent-input context because `math.add` adds the stepped value to any incoming audio and intentionally creates DC-rich output.
- Expose the container parameter as a discrete choice labelled with actual sizes `1, 8, 16, 32, 64, 128, 256, 512`; the underlying raw parameter is an index from 0 to 7, not a sample count.
- Set the ramp period to exactly 1000 ms. The slow folded motion makes the zipper artifacts from larger processing chunks more audible while remaining easy to inspect visually. Monitor at a safe level because the signal is DC-rich.
- Runtime size changes may output one silent buffer while children are re-prepared. Bypassing the container disables chunking and processes children at the host block size.
