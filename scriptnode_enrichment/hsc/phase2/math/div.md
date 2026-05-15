# math.div - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/math/div.md`
- Reference: `scriptnode_enrichment/output/math/div.md`

## Naming

- Module ID: `WrappedRampNormalizer`
- Network ID: `wrapped_ramp_normalizer`

## Graph Plan

```text
wrapped_ramp_normalizer
  SlowRamp              core.ramp
  WrapStage             math.fmod
  NormalizeStage        math.div
  OutputPeak            core.peak
  SignalClear           math.clear
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - None
- Channel/routing setup:
  - Required channels: default stereo; no non-default channel work is needed for the repeated ramp display
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: []

## Public Parameters

- WrapAmount -> `WrapStage.Value` matched
- Target range before connection: `[0.2, 1.0]`
- Macro range: `[0.2, 1.0]`
- Default: `1.0`
- WrapAmount -> `NormalizeStage.Value` matched
- Target range before connection: `[0.2, 1.0]`
- Macro range: `[0.2, 1.0]`
- Default: `1.0`

## Defaults To Omit

- `SignalClear.Value` default `0.0`

## Locked Build Values

- None

## Friction Comments To Weave In

- Before the shared macro connection: drive `math.fmod` and `math.div` from the same narrowed value so the wrap count and the renormalisation always stay aligned.
- Before `create_parameter`: exclude zero because `math.div` outputs silence for zero or negative divisors.

## Cosmetic Plan

- Main node: `NormalizeStage`
- Accent colour: `0xFF2F80ED`
- Supporting relevant nodes: [`WrapStage`, `OutputPeak`]
- Supporting colour: `0xFF6F8FAF`
- Folded nodes: [`SignalClear`]
- Nodes that must stay visible: [`SlowRamp`, `WrapStage`, `NormalizeStage`, `OutputPeak`]

## Open Questions

- None
