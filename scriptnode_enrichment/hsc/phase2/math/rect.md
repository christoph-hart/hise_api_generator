# math.rect - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/math/rect.md`
- Reference: `scriptnode_enrichment/output/math/rect.md`

## Naming

- Module ID: `ThresholdRectifier`
- Network ID: `threshold_rectifier`

## Graph Plan

```text
threshold_rectifier
  SeedValue             math.add
  InputSpecs            analyse.specs
  BinaryGate            math.rect
  OutputSpecs           analyse.specs
  SignalClear           math.clear
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - None
- Channel/routing setup:
  - Required channels: default stereo; the binary thresholding is shown with a duplicated normalised test value
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: []

## Public Parameters

- None

## Defaults To Omit

- `BinaryGate.Value` default `0.0`
- `SignalClear.Value` default `0.0`

## Locked Build Values

- None

## Friction Comments To Weave In

- Before `BinaryGate`: mention that the threshold is hardcoded at 0.5, so the plan demonstrates the built-in binary transition rather than a user-adjustable comparator.

## Cosmetic Plan

- Main node: `BinaryGate`
- Accent colour: `0xFF2F80ED`
- Supporting relevant nodes: [`SeedValue`, `InputSpecs`, `OutputSpecs`]
- Supporting colour: `0xFF6F8FAF`
- Folded nodes: [`SignalClear`]
- Nodes that must stay visible: [`SeedValue`, `InputSpecs`, `BinaryGate`, `OutputSpecs`]

## Open Questions

- None
