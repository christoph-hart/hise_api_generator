# control.pma - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/control/pma.md`
- Reference: `scriptnode_enrichment/output/control/pma.md`

## Naming

- Module ID: `InvertedTremoloFloor`
- Network ID: `inverted_tremolo_floor`

## Graph Plan

```text
inverted_tremolo_floor
  RampControl            container.modchain
    TremoloRamp          core.ramp
  GainTransform          control.pma
  TremoloGain            math.mul
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - Set locked PMA values before connecting the moving ramp.
- Channel/routing setup:
  - Required channels: default stereo; ramp uses isolated mono control processing
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: []

## Public Parameters

- Depth -> `GainTransform.Multiply` matched
- Target range before connection: `[-1, 0]`
- Macro range: `[0, 1]`, mapped to `[0, -1]`
- Default: `0.75`

## Defaults To Omit

- `GainTransform.Value` default `0.0`
- `GainTransform.Multiply` default `1.0`

## Locked Build Values

- `GainTransform.Add` = `1.0`
- `TremoloRamp.PeriodTime` = `800`
- Ramp -> `GainTransform.Value` matched `[0, 1]`
- PMA output -> `TremoloGain.Value` matched `[0, 1]`
- Formula = `clamp(Value * Multiply + Add, 0, 1)`
- Startup Multiply = `-0.75`, yielding gain range `1.0..0.25`.

## Friction Comments To Weave In

- Before `RampControl`: keep the additive ramp out of the audio path.
- Before Depth: the user-facing positive depth maps to a negative multiplier for inversion.
- Before verification: PMA clamps the final result to 0..1 and Multiply zero gives constant unity.

## Cosmetic Plan

- Main node: `GainTransform`
- Accent colour: `0xFF8E44AD`
- Supporting relevant nodes: [`TremoloRamp`, `TremoloGain`]
- Supporting colour: `0xFF7F6A91`
- Folded nodes: [`RampControl`]
- Nodes that must stay visible: [`TremoloRamp`, `GainTransform`, `TremoloGain`]

## Open Questions

- None
