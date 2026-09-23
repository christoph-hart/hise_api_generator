# control.cable_expr - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/control/cable_expr.md`
- Reference: `scriptnode_enrichment/output/control/cable_expr.md`

## Naming

- Module ID: `ThresholdedEffectActivation`
- Network ID: `thresholded_effect_activation`

## Graph Plan

```text
thresholded_effect_activation
  ActivationGate         control.cable_expr
  FilteredPath           container.soft_bypass
    ActiveFilter         filters.svf
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - Enable compilation and verify the expression status before tracing output.
- Channel/routing setup:
  - Required channels: default stereo
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: []

## Public Parameters

- Amount -> `ActivationGate.Value` matched
- Target range before connection: `[0, 1]`
- Macro range: `[0, 1]`
- Default: `0`

## Defaults To Omit

- `ActivationGate.Value` default `0.0`
- `ActivationGate.Code` default `input`

## Locked Build Values

- `ActivationGate.Code` = `input > 0.5 ? 1.0 : 0.0`
- `ActivationGate.Debug` = `Off`
- `ActivationGate` output -> `FilteredPath.Bypass` matched over `[0, 1]`
- `FilteredPath.SmoothingTime` property = `40` ms
- `ActiveFilter.Mode` = `LowPass`
- `ActiveFilter.Frequency` = `1200`
- `ActiveFilter.Smoothing` = `0.02`
- Exact midpoint input `0.5` returns `0.0`.

## Friction Comments To Weave In

- Before compilation: exported plugins require the network compiled to C++ because the SNEX JIT is unavailable.
- Before `ActivationGate`: output is unscaled but this formula deliberately returns exact zero or one.
- Before `FilteredPath`: the soft wrapper converts the binary decision into a click-free audio transition.
- Before verification: expression compile failure falls back to passthrough and must not be mistaken for threshold behaviour.

## Cosmetic Plan

- Main node: `ActivationGate`
- Accent colour: `0xFF8E44AD`
- Supporting relevant nodes: [`FilteredPath`, `ActiveFilter`]
- Supporting colour: `0xFF7F6A91`
- Folded nodes: []
- Nodes that must stay visible: [`ActivationGate`, `FilteredPath`, `ActiveFilter`]

## Open Questions

- None
