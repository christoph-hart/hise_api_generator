# container.split - HSC Scenario

## Node

- Factory path: `container.split`
- Source page: `scriptnode_enrichment/output/container/split.md`

## Scenario

- Title: Phase-Cancellation Silencer
- Project context: A stereo signal is copied into two parallel children. One multiplier passes its copy unchanged while the other multiplies its independent copy by -1, and the split sums them to exact silence.
- Teaching goal: Demonstrate that `container.split` gives every child the same unmodified input and sums aligned outputs without introducing a child-to-child signal dependency or delay.

## Support Nodes

- Required: [`math.mul`]
- Optional: []
- Rationale: Two `math.mul` instances create the matched +1 and -1 paths needed for deterministic cancellation; the first also makes both branches structurally explicit instead of relying on an empty child as passthrough.

## Assumptions

- Channels: default stereo
- Public control needed: no
- Raw node values acceptable: yes

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Add exactly two parallel children, each containing one `math.mul`. Lock the first Value to +1 and override the second multiplier's range so its Value can be locked to -1.
- Feed both branches directly from `container.split`; do not connect them serially and do not add latency-producing nodes to either branch.
- Verify with non-silent stereo input that both child outputs have equal magnitude and opposite polarity, then measure the summed output at or near numerical silence on both channels.
- Temporarily bypassing the inverted child should restore the unchanged +1 path because bypassed split children contribute nothing to the sum.
- Do not add compensating gain after the split. The normal warning about unity branches summing to +6 dB is intentionally replaced here by opposite-polarity cancellation.
- If exact cancellation fails, inspect hidden smoothing, unequal parameter values, channel-count mismatches, or processing latency before attributing the result to the split container.
