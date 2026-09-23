# container.fix16_block - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/container/fix16_block.md`
- Reference: `scriptnode_enrichment/output/container/fix16_block.md`

## Naming

- Module ID: `SnappyFilterEnvelope`
- Network ID: `snappy_filter_envelope`

## Graph Plan

```text
snappy_filter_envelope
  SixteenSampleVoice     container.fix16_block
    SawVoice             core.oscillator
    FilterEnvelope       envelope.ahdsr
    SnappyLowPass        filters.svf
    VoiceLifecycle       envelope.voice_manager
```

## Builder Setup

- Host context: `Script Synth`
- Additional builder steps:
  - Send MIDI notes with enough spacing to hear each fast-onset filter transient.
  - Keep `FilterEnvelope.NumParameters` at `2` so the UI emphasizes the attack and decay controls relevant to this example.
  - Verify envelope CV and filter cutoff while a note is active.
- Channel/routing setup:
  - Required channels: default stereo in the Scriptnode Synthesiser voice context
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: [synth root already supplies MIDI and voice context; envelope Gate handles voice cleanup]

## Public Parameters

- None

## Defaults To Omit

- `SawVoice.Frequency` default `220`
- `SawVoice.Freq Ratio` default `1`
- `SawVoice.Gate` default `On`
- `FilterEnvelope.AttackLevel` default `1`
- `FilterEnvelope.AttackCurve` default `0.5`
- `FilterEnvelope.Retrigger` default `Off`
- `FilterEnvelope.Gate` default `Off`
- `SnappyLowPass.Mode` default `LowPass`
- `SnappyLowPass.Gain` default `0`
- `SnappyLowPass.Enabled` default `On`
- `VoiceLifecycle.Kill Voice` default `1`

## Locked Build Values

- Maximum child chunk size = `16` samples
- `SawVoice.Mode` = `Saw`
- `SawVoice.Gain` = `0.125`
- `FilterEnvelope.Attack` = `1` ms
- `FilterEnvelope.Hold` = `0` ms
- `FilterEnvelope.Decay` = `300` ms
- `FilterEnvelope.Sustain` = `0.5`
- `FilterEnvelope.NumParameters` property = `2`
- `FilterEnvelope.Release` = `50` ms
- `FilterEnvelope` CV output -> `SnappyLowPass.Frequency` range = `[120, 12000]`, skewed with default `120`
- `FilterEnvelope` Gate output -> `VoiceLifecycle.Kill Voice`
- `SnappyLowPass.Q` = `0.8`
- `SnappyLowPass.Smoothing` = `0`

## Friction Comments To Weave In

- Before `SixteenSampleVoice`: the Scriptnode Synthesiser root already supplies MIDI and voice context, so do not add a redundant midichain. Sixteen samples is a maximum chunk size; a final remainder may be shorter and the update rate depends on session sample rate.
- Before the filter connection: set the cutoff range before connecting the envelope CV.
- Before verification: filter Smoothing must be exactly zero or interpolation will hide the fixed-block cadence.
- Before `VoiceLifecycle`: connect the envelope Gate output, not its CV output, to Kill Voice.

## Cosmetic Plan

- Main node: `SixteenSampleVoice`
- Accent colour: `0xFF2F80ED`
- Supporting relevant nodes: [`SawVoice`, `FilterEnvelope`, `SnappyLowPass`, `VoiceLifecycle`]
- Supporting colour: `0xFF6F8FAF`
- Folded nodes: [`VoiceLifecycle`]
- Nodes that must stay visible: [`SixteenSampleVoice`, `SawVoice`, `FilterEnvelope`, `SnappyLowPass`]

## Open Questions

- None
