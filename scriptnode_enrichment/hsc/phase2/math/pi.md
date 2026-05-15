# math.pi - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/math/pi.md`
- Reference: `scriptnode_enrichment/output/math/pi.md`

## Naming

- Module ID: `VisibleRadianScaler`
- Network ID: `visible_radian_scaler`

## Graph Plan

```text
visible_radian_scaler
  SeedValue             math.add
  PiScaler              math.pi
  DisplayRange          math.sig2mod
  OutputPeak            core.peak
  SignalClear           math.clear
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - None
- Channel/routing setup:
  - Required channels: default stereo; the radian-scaled test value is duplicated for display only
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: []

## Public Parameters

- CycleScale -> `PiScaler.Value` matched
- Target range before connection: `[1.0, 2.0]`
- Macro range: `[1.0, 2.0]`
- Default: `2.0`

## Defaults To Omit

- `DisplayRange.Value` default `0.0`
- `OutputPeak.Value` default `0.0`
- `SignalClear.Value` default `0.0`

## Locked Build Values

- None

## Friction Comments To Weave In

- Before `DisplayRange`: convert the scaled bipolar-style result back into 0..1 so the peak display shows a readable modulation curve.
- Before `create_parameter`: keep the scale near the documented full-cycle use case instead of exposing the inconsistent broad raw range from the reference page.

## Cosmetic Plan

- Main node: `PiScaler`
- Accent colour: `0xFF2F80ED`
- Supporting relevant nodes: [`DisplayRange`, `OutputPeak`]
- Supporting colour: `0xFF6F8FAF`
- Folded nodes: [`SignalClear`]
- Nodes that must stay visible: [`SeedValue`, `PiScaler`, `DisplayRange`, `OutputPeak`]

## Open Questions

- None
