# container.soft_bypass - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/container/soft_bypass.md`
- Reference: `scriptnode_enrichment/output/container/soft_bypass.md`

## Naming

- Module ID: `ClickFreeVocalStrip`
- Network ID: `click_free_vocal_strip`

## Graph Plan

```text
click_free_vocal_strip
  VocalStrip             container.soft_bypass
    HighPass             filters.one_pole
    VocalCompressor      dynamics.comp
    SaturationDrive      math.mul
    SoftSaturation       math.tanh
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - Use sustained vocal audio to verify active and bypass transitions.
- Channel/routing setup:
  - Required channels: default stereo
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: []

## Public Parameters

- StripEnable -> `VocalStrip.Bypass` matched
- Target range before connection: `[0, 1]`, step `1`; values below `0.5` bypass and values at or above `0.5` activate
- Macro range: `[0, 1]`, step `1`, labels `Off, On`
- Default: `1`

## Defaults To Omit

- `HighPass.Smoothing` default `0.01`
- `VocalCompressor.Attack` default `20`
- `VocalCompressor.Release` default `50`

## Locked Build Values

- `VocalStrip.SmoothingTime` property = `40` ms
- `HighPass.Mode` = `HighPass`
- `HighPass.Frequency` = `90`
- `HighPass.Smoothing` = `0.02`
- `VocalCompressor.Threshold` = `-18`
- `VocalCompressor.Ratio` = `3`
- `VocalCompressor.Attack` = `15`
- `VocalCompressor.Release` = `120`
- `SaturationDrive.Value` = `1.5`

## Friction Comments To Weave In

- Before `VocalStrip`: use one wrapper around the complete serial strip; series-chaining soft-bypass containers causes nested-ramp problems.
- Before StripEnable: bypass polarity is explicit because connection values at or above 0.5 activate processing.
- Before verification: audio crossfades over SmoothingTime, but child modulation outputs would be suppressed immediately.

## Cosmetic Plan

- Main node: `VocalStrip`
- Accent colour: `0xFF27AE60`
- Supporting relevant nodes: [`HighPass`, `VocalCompressor`, `SoftSaturation`]
- Supporting colour: `0xFF668A73`
- Folded nodes: [`SaturationDrive`]
- ShowParameters containers: [] (bypass cable targets the always-visible power button)
- Nodes that must stay visible: [`VocalStrip`, `HighPass`, `VocalCompressor`, `SoftSaturation`]

## Open Questions

- None
