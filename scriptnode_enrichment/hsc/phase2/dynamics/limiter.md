# dynamics.limiter - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/dynamics/limiter.md`
- Reference: `scriptnode_enrichment/output/dynamics/limiter.md`

## Naming

- Module ID: `SafetyPeakLimiter`
- Network ID: `safety_peak_limiter`

## Graph Plan

```text
safety_peak_limiter
  DriveShaper           core.expr
  SafetyLimiter         dynamics.limiter
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - None
- Channel/routing setup:
  - Required channels: default stereo; the limiter acts as the final stereo safety stage
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: []

## Public Parameters

- DriveAmount -> `DriveShaper.Value` matched
- Target range before connection: `[0.0, 0.75]`
- Macro range: `[0.0, 0.75]`
- Default: `0.5`
- LimitThreshold -> `SafetyLimiter.Threshhold` matched
- Target range before connection: `[-12, -1]`
- Macro range: `[-12, -1]`
- Default: `-3`
- LimitRelease -> `SafetyLimiter.Release` matched
- Target range before connection: `[20, 180]`
- Macro range: `[20, 180]`
- Default: `90`
- LimitRatio -> `SafetyLimiter.Ratio` matched
- Target range before connection: `[12, 32]`
- Macro range: `[12, 32]`
- Default: `20`

## Defaults To Omit

- `SafetyLimiter.Sidechain` default `Disabled`

## Locked Build Values

- `DriveShaper.Code` = `input + value * input * input * input`

## Friction Comments To Weave In

- Before `set DriveShaper.Code`: lock the expression to `input + value * input * input * input` so the example stays on a simple cubic shaper that compiles cleanly in SNEX.
- Before `SafetyLimiter`: place the limiter last so it reads as a safety stage after the non-linear shaper.
- Before `set SafetyLimiter.Attack`: treat attack as a fixed lookahead/latency choice, not a performance macro, because changing it at runtime causes clicks.

## Cosmetic Plan

- Main node: `SafetyLimiter`
- Accent colour: `0xFFE67E22`
- Supporting relevant nodes: [`DriveShaper`]
- Supporting colour: `0xFF8F7766`
- Folded nodes: []
- Nodes that must stay visible: [`DriveShaper`, `SafetyLimiter`]

## Open Questions

- None
