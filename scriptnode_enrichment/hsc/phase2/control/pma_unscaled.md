# control.pma_unscaled - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/control/pma_unscaled.md`
- Reference: `scriptnode_enrichment/output/control/pma_unscaled.md`

## Naming

- Module ID: `ScaledTempoDelayMs`
- Network ID: `scaled_tempo_delay_ms`

## Graph Plan

```text
scaled_tempo_delay_ms
  MusicalDuration        control.tempo_sync
  DurationMath           control.pma_unscaled
  ScaledDelay            core.fix_delay
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - Constrain all public combinations to keep the raw result within 0..1000 ms.
- Channel/routing setup:
  - Required channels: default stereo
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: []

## Public Parameters

- Scale -> `DurationMath.Multiply` matched; target and macro range `[0.25, 1]`; default `0.5`
- OffsetMs -> `DurationMath.Add` matched; target and macro range `[0, 100]` ms; default `20`

## Defaults To Omit

- `DurationMath.Value` default `0.0`
- `DurationMath.Multiply` default `1.0`
- `DurationMath.Add` default `0.0`

## Locked Build Values

- `MusicalDuration.Enabled = On`, Tempo = `1/4`, Multiplier = `1`
- MusicalDuration output -> `DurationMath.Value` unscaled milliseconds
- DurationMath output -> `ScaledDelay.DelayTime` unscaled milliseconds
- `ScaledDelay.FadeTime` = `256` samples
- Formula = `Value * Multiply + Add` with no clamp.

## Friction Comments To Weave In

- Before `DurationMath`: Value and Add are raw, but Multiply is range-scaled and must be configured before connection.
- Before delay target: output bypasses target conversion and can exceed 1.0 without clipping.
- Before FadeTime: delay crossfade time is measured in samples, unlike the millisecond arithmetic.

## Cosmetic Plan

- Main node: `DurationMath`
- Accent colour: `0xFF8E44AD`
- Supporting relevant nodes: [`MusicalDuration`, `ScaledDelay`]
- Supporting colour: `0xFF7F6A91`
- Folded nodes: []
- Nodes that must stay visible: [`MusicalDuration`, `DurationMath`, `ScaledDelay`]

## Open Questions

- None
