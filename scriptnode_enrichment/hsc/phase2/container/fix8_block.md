# container.fix8_block - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/container/fix8_block.md`
- Reference: `scriptnode_enrichment/output/container/fix8_block.md`

## Naming

- Module ID: `EventRasterVibrato`
- Network ID: `event_raster_vibrato`

## Graph Plan

```text
event_raster_vibrato
  EightSampleVibrato    container.fix8_block
    VibratoControl      container.modchain
      MidiIsolation     container.no_midi
        TriangleLfo     core.oscillator
        NormaliseLfo    math.sig2mod
        LfoValue        core.peak
      VibratoDepth      control.bipolar
    AudibleTone         core.oscillator
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - Feed silence into the Script FX and audition at a conservative level.
  - Verify that the LFO remains fixed-rate and the audible oscillator frequency ratio moves symmetrically around `1.0`.
- Channel/routing setup:
  - Required channels: default stereo; control generation uses an isolated mono modchain
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: [MIDI blocked only for fixed-rate LFO; oscillator generates from silence]

## Public Parameters

- Intensity -> `VibratoDepth.Scale` matched
- Target range before connection: `[0, 1]`
- Macro range: `[0, 1]`
- Default: `1.0`

## Defaults To Omit

- `NormaliseLfo.Value` default `0.0`
- `LfoValue.Value` default `0.0`
- `VibratoDepth.Scale` default `0.0`
- `VibratoDepth.Gamma` default `1.0`

## Locked Build Values

- Maximum child chunk size = `8` samples
- `TriangleLfo.Mode` = `Triangle`
- `TriangleLfo.Frequency` range = `[0.5, 8]`
- `TriangleLfo.Frequency` = `5`
- `TriangleLfo.Gate` = `On`
- `LfoValue` modulation output -> `VibratoDepth.Value` scaled over `[0, 1]`
- `VibratoDepth.Gamma` = `1.0`
- `VibratoDepth` output -> `AudibleTone.Freq Ratio` range = `[0.9885140204, 1.0116194403]`, middle position `1.0` (exactly plus or minus 20 cents)
- `AudibleTone.Mode` = `Sine`
- `AudibleTone.Frequency` = `220`
- `AudibleTone.Gate` = `On`
- `AudibleTone.Gain` = `0.125` (approximately `-18 dB`)

## Friction Comments To Weave In

- Before `EightSampleVibrato`: 8 samples is the maximum chunk size and mirrors `HISE_EVENT_RASTER`; the final remainder may be shorter.
- Before `MidiIsolation`: MIDI must not retune the fixed-rate triangle LFO.
- Before creating and connecting `Intensity`: first narrow `VibratoDepth.Scale` to `[0, 1]`. A matched parameter connection can copy the target's current range back to the root parameter; connecting before narrowing Scale would expose its original `[-1, 1]` range.
- Before `VibratoDepth`: root Intensity controls Scale, so zero depth remains at midpoint and does not shift the oscillator away from ratio `1.0`.
- Before the ratio connection: use reciprocal semitone-ratio bounds for symmetric plus or minus 20-cent pitch, not an additive plus or minus 0.01 approximation.
- Before verification: the oscillator adds to its input, so use silence and conservative monitoring gain. Keep it in Sine mode because saw harmonics mask the subtle zipper sidebands.

## Cosmetic Plan

- Main node: `EightSampleVibrato`
- Accent colour: `0xFF2F80ED`
- Supporting relevant nodes: [`TriangleLfo`, `LfoValue`, `VibratoDepth`, `AudibleTone`]
- Supporting colour: `0xFF6F8FAF`
- Folded nodes: [`NormaliseLfo`]
- Nodes that must stay visible: [`EightSampleVibrato`, `VibratoControl`, `TriangleLfo`, `LfoValue`, `VibratoDepth`, `AudibleTone`]

## Open Questions

- None
