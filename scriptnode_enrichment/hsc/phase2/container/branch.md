# container.branch - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/container/branch.md`
- Reference: `scriptnode_enrichment/output/container/branch.md`

## Naming

- Module ID: `SelectableWaveshaper`
- Network ID: `selectable_waveshaper`

## Graph Plan

```text
selectable_waveshaper
  ShapeModes             container.branch
    TanhShape            math.expr
    HiseSaturation       math.expr
    SineFold             math.expr
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - Enable compilation because every branch contains a SNEX expression.
- Channel/routing setup:
  - Required channels: default stereo
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: []

## Public Parameters

- Mode -> `ShapeModes.Index` matched
- Target range before connection: `[0, 2]`, step `1`
- Macro range: `[0, 2]`, step `1`, labels `Tanh, HISE Saturation, Sine Fold`
- Default: `0`

## Defaults To Omit

- `ShapeModes.Index` default `0`

## Locked Build Values

- `TanhShape.Code` = `Math.tanh(input * (1.0f + value * 5.0f))`
- `TanhShape.Value` = `0.5`
- `HiseSaturation.Code` = `(1.0f + value / (1.0f - value)) * input / (1.0f + value / (1.0f - value) * Math.abs(input))`
- `HiseSaturation.Value` = `0.75`
- `SineFold.Code` = `Math.sin(input * (1.0f + value * 8.0f))`
- `SineFold.Value` = `0.5`
- Branch child order = `TanhShape`, `HiseSaturation`, `SineFold`

## Friction Comments To Weave In

- Before `ShapeModes`: the branch processes exactly one prepared child and switches immediately without a crossfade.
- Before the expression nodes: lock each algorithm's amount so Mode compares transfer functions rather than unrelated gain settings.

## Cosmetic Plan

- Main node: `ShapeModes`
- Accent colour: `0xFFE67E22`
- Supporting relevant nodes: [`TanhShape`, `HiseSaturation`, `SineFold`]
- Supporting colour: `0xFF8C6D55`
- Folded nodes: []
- ShowParameters containers: [`ShapeModes`]
- Nodes that must stay visible: [`ShapeModes`, `TanhShape`, `HiseSaturation`, `SineFold`]

## Open Questions

- None
