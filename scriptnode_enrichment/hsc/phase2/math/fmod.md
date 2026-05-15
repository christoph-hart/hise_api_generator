# math.fmod - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/math/fmod.md`
- Reference: `scriptnode_enrichment/output/math/fmod.md`

## Naming

- Module ID: `WrappedRampRepeater`
- Network ID: `wrapped_ramp_repeater`

## Graph Plan

```text
wrapped_ramp_repeater
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
  - Required channels: default stereo; no special routing is needed for the visual repetition example
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

- Before the shared macro connection: use one public control for both math nodes so the wrapped segment size and the display renormalisation stay in lockstep.
- Before `create_parameter`: keep the range away from zero so the zero-guard behaviour does not collapse the example into passthrough.

## Cosmetic Plan

- Main node: `WrapStage`
- Accent colour: `0xFF2F80ED`
- Supporting relevant nodes: [`NormalizeStage`, `OutputPeak`]
- Supporting colour: `0xFF6F8FAF`
- Folded nodes: [`SignalClear`]
- Nodes that must stay visible: [`SlowRamp`, `WrapStage`, `NormalizeStage`, `OutputPeak`]

## Open Questions

- None
