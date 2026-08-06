# math.sig2mod - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/math/sig2mod.md`
- Reference: `scriptnode_enrichment/output/math/sig2mod.md`

## Naming

- Module ID: `AudioToModulation`
- Network ID: `audio_to_modulation`

## Graph Plan

```text
audio_to_modulation
  SlowOscillator        core.oscillator
  SourcePeak            core.peak
  RangeConverter        math.sig2mod
  ConvertedPeak         core.peak
  SignalClear           math.clear
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - None
- Channel/routing setup:
  - Required channels: default stereo; the same slow bipolar source feeds both displays
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: []

## Public Parameters

- None

## Defaults To Omit

- `RangeConverter.Value` default `0.0`
- `SourcePeak.Value` default `0.0`
- `ConvertedPeak.Value` default `0.0`
- `SignalClear.Value` default `0.0`

## Locked Build Values

- `SlowOscillator.Range` = `LFO`
- `SlowOscillator.Frequency` = `20 Hz` (the minimum supported by `core.oscillator`)

## Friction Comments To Weave In

- Before `set SlowOscillator frequency`: use the minimum supported `20 Hz` value; `core.oscillator` does not expose the 0.8 Hz LFO range described in the original scenario.
- Before `SourcePeak` and `ConvertedPeak`: keep the two peak displays adjacent so the benefit of the conversion is obvious at a glance.

## Cosmetic Plan

- Main node: `RangeConverter`
- Accent colour: `0xFF2F80ED`
- Supporting relevant nodes: [`SourcePeak`, `ConvertedPeak`]
- Supporting colour: `0xFF6F8FAF`
- Folded nodes: [`SignalClear`]
- Nodes that must stay visible: [`SlowOscillator`, `SourcePeak`, `RangeConverter`, `ConvertedPeak`]

## Open Questions

- None
