# control.pack5_writer - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/control/pack5_writer.md`
- Reference: `scriptnode_enrichment/output/control/pack5_writer.md`

## Naming

- Module ID: `FiveStepAccentPattern`
- Network ID: `five_step_accent_pattern`

## Graph Plan

```text
five_step_accent_pattern
  AccentWriter           control.pack5_writer
  PatternClock           core.clock_ramp
  AccentReader           control.cable_pack
  AccentGain             math.mul
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - Initialize shared external SliderPack slot 0 before applying writer values.
- Channel/routing setup:
  - Required channels: default stereo
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: []

## Public Parameters

- Accent1..Accent5 -> `AccentWriter.Value1..Value5` matched over `[0, 1]`
- Defaults: `1.0, 0.45, 0.7, 0.35, 0.6`

## Defaults To Omit

- `AccentWriter.Value1..Value5` defaults `0.0`

## Locked Build Values

- `AccentWriter.SliderPack` and `AccentReader.SliderPack` external data index = `0`
- Interface pattern = `Synth.getSliderPackProcessor("FiveStepAccentPattern").getSliderPack(0)`
- Writer resizes pack to `5`; Value1..Value5 map to indices `0..4`.
- `PatternClock.Mode = Synced`, Multiplier = `1 Bar`, AddToSignal = `Off`, Inactive = `0`
- Clock -> reader matched `[0, 1]`; reader -> `AccentGain.Value` matched `[0, 1]`

## Friction Comments To Weave In

- Before data setup: the programmable pack must use external slot 0.
- Before lookup: cable_pack preserves five hard accent levels without interpolation.
- Before clock setup: five zones across one bar intentionally create a polymetric cycle against binary subdivisions.

## Cosmetic Plan

- Main node: `AccentWriter`
- Accent colour: `0xFF8E44AD`
- Supporting relevant nodes: [`PatternClock`, `AccentReader`, `AccentGain`]
- Supporting colour: `0xFF7F6A91`
- Folded nodes: []
- Nodes that must stay visible: [`AccentWriter`, `AccentReader`, `AccentGain`]

## Open Questions

- None
