# container.split - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/container/split.md`
- Reference: `scriptnode_enrichment/output/container/split.md`

## Naming

- Module ID: `PhaseCancellationSilencer`
- Network ID: `phase_cancellation_silencer`

## Graph Plan

```text
phase_cancellation_silencer
  CancellationPaths      container.split
    PositivePath         math.mul
    InvertedPath         math.mul
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - Feed identical non-silent stereo input to both split paths and measure the summed output on both channels.
- Channel/routing setup:
  - Required channels: default stereo
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: [both children receive independent copies of the same stereo input]

## Public Parameters

- None

## Defaults To Omit

- `PositivePath.Value` default `1.0`

## Locked Build Values

- `CancellationPaths` child count = `2`
- `PositivePath.Value` = `1.0`
- `InvertedPath.Value` range = `[-1, 1]`
- `InvertedPath.Value` = `-1.0`
- No smoothing or latency-producing nodes are permitted in either path.

## Friction Comments To Weave In

- Before `CancellationPaths`: split copies the untouched input to both children and sums their aligned outputs.
- Before `InvertedPath`: widen the multiplier range to permit the locked negative value.
- Before output verification: no compensating gain is needed because equal and opposite paths intentionally cancel.

## Cosmetic Plan

- Main node: `CancellationPaths`
- Accent colour: `0xFF2F80ED`
- Supporting relevant nodes: [`PositivePath`, `InvertedPath`]
- Supporting colour: `0xFF6F8FAF`
- Folded nodes: []
- Nodes that must stay visible: [`CancellationPaths`, `PositivePath`, `InvertedPath`]

## Open Questions

- None
