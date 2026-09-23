# control.converter - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/control/converter.md`
- Reference: `scriptnode_enrichment/output/control/converter.md`

## Naming

- Module ID: `TempoDurationSampleHold`
- Network ID: `tempo_duration_sample_hold`

## Graph Plan

```text
tempo_duration_sample_hold
  MusicalDuration        control.tempo_sync
  SampleCount            control.converter
  LongSampleHold         fx.sampleandhold
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - Verify the widened Counter range at every supported BPM, division, and sample rate before construction is final.
- Channel/routing setup:
  - Required channels: default stereo
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: []

## Public Parameters

- Tempo -> `MusicalDuration.Tempo` matched
- Target range before connection: `[40, 240]`
- Macro range: `[40, 240]`
- Default: `120`
- Multiplier -> `MusicalDuration.Multiplier` matched
- Target range before connection: full discrete tempo division range
- Macro range: matching labelled tempo divisions
- Default: `1/4`

## Defaults To Omit

- `SampleCount.Value` default `0.0`

## Locked Build Values

- `MusicalDuration.Enabled` = `On`
- `SampleCount.Mode` property = `Ms2Samples`
- `MusicalDuration` output -> `SampleCount.Value` unscaled milliseconds
- `LongSampleHold.Counter` range = `[1, 529200]`, step `1`
- `SampleCount` output -> `LongSampleHold.Counter` unscaled
- At 44.1 kHz, `500` ms must produce approximately `22050` samples.

## Friction Comments To Weave In

- Before `SampleCount`: both input and output are raw units; the converter uses the current processing sample rate.
- Before Counter setup: widen the stock range because musical durations produce far more than 64 samples.
- Before verification: this intentionally creates extreme low-rate holding, and all generated counts must remain within implementation limits.

## Cosmetic Plan

- Main node: `SampleCount`
- Accent colour: `0xFF8E44AD`
- Supporting relevant nodes: [`MusicalDuration`, `LongSampleHold`]
- Supporting colour: `0xFF7F6A91`
- Folded nodes: []
- Nodes that must stay visible: [`MusicalDuration`, `SampleCount`, `LongSampleHold`]

## Open Questions

- None
