# control.intensity - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/control/intensity.md`
- Reference: `scriptnode_enrichment/output/control/intensity.md`

## Naming

- Module ID: `HiseGainModulationDepth`
- Network ID: `hise_gain_modulation_depth`

## Graph Plan

```text
hise_gain_modulation_depth
  RampControl            container.modchain
    GainRamp             core.ramp
  GainDepth              control.intensity
  AudioMultiplier        math.mul
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - None
- Channel/routing setup:
  - Required channels: default stereo; ramp is isolated from audio in a mono modchain
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: []

## Public Parameters

- Amount -> `GainDepth.Intensity` matched
- Target range before connection: `[0, 1]`
- Macro range: `[0, 100]` percent
- Default: `50`
- Rate -> `GainRamp.PeriodTime` matched
- Target range before connection: `[200, 2000]`
- Macro range: `[200, 2000]`
- Default: `800`

## Defaults To Omit

- `GainDepth.Value` default `0.0`
- `GainDepth.Intensity` default `1.0`
- `AudioMultiplier.Value` default `1.0`

## Locked Build Values

- `GainRamp` output -> `GainDepth.Value` matched over `[0, 1]`
- `GainDepth` output -> `AudioMultiplier.Value` matched over `[0, 1]`
- Formula = `(1.0 - Intensity) + Intensity * Value`

## Friction Comments To Weave In

- Before `RampControl`: isolate core.ramp because it otherwise adds a DC-rich signal to audio.
- Before Amount: zero intensity means unity gain and no modulation, not silence.
- Before `AudioMultiplier`: use linear multiplication rather than decibel gain to preserve the formula.

## Cosmetic Plan

- Main node: `GainDepth`
- Accent colour: `0xFF8E44AD`
- Supporting relevant nodes: [`GainRamp`, `AudioMultiplier`]
- Supporting colour: `0xFF7F6A91`
- Folded nodes: [`RampControl`]
- Nodes that must stay visible: [`GainRamp`, `GainDepth`, `AudioMultiplier`]

## Open Questions

- None
