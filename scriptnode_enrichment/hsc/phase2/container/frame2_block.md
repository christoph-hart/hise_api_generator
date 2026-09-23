# container.frame2_block - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/container/frame2_block.md`
- Reference: `scriptnode_enrichment/output/container/frame2_block.md`

## Naming

- Module ID: `MidiTunedStereoResonator`
- Network ID: `midi_tuned_stereo_resonator`

## Graph Plan

```text
midi_tuned_stereo_resonator
  MidiContext               container.midichain
    Exciter                  container.chain
      ExciterNoise           core.oscillator
      ExciterEnvelope        envelope.ahdsr
    StereoFrames             container.frame2_block
      NoteFrequency         control.midi
      FrequencyHz           control.pma_unscaled
      PeriodMs              control.converter
      LeftPeriod            control.pma_unscaled
      RightPeriod           control.pma_unscaled
      ResonantLoop          template.feedback_delay
        ResonantLoop_fb_out routing.receive
        StereoDelays        container.multi
          LeftDelay         jdsp.jdelay_cubic
          RightDelay        jdsp.jdelay_cubic
        LoopDamping         filters.one_pole
        ResonantLoop_fb_in  routing.send
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - Add `template.feedback_delay`, remove its generated `ResonantLoop_delay`, insert `StereoDelays` and `LoopDamping`, and keep `ResonantLoop_fb_in` last.
  - Group `ExciterNoise` and `ExciterEnvelope` in the compact `Exciter` chain before `StereoFrames`.
  - Trigger MIDI notes with silent input; the internal enveloped noise oscillator provides the excitation burst.
- Channel/routing setup:
  - Required channels: exactly two stereo channels in frame mode
  - Module routing: default stereo
  - Master routing: default stereo
  - Channel-specific comments needed: [left and right delay periods differ subtly; each note tunes and excites]

## Public Parameters

- Feedback -> `ResonantLoop_fb_out.Feedback` matched
- Target range before connection: `[0, 0.995]`
- Macro range: `[0, 0.995]`
- Default: `0.985`
- Damping -> `LoopDamping.Frequency` matched
- Target range before connection: `[500, 12000]`
- Macro range: `[500, 12000]`
- Default: `6000`

## Defaults To Omit

- `ExciterNoise.Frequency` default `220`
- `ExciterNoise.Freq Ratio` default `1`
- `ExciterNoise.Gate` default `On`
- `ExciterEnvelope.AttackLevel` default `1`
- `ExciterEnvelope.AttackCurve` default `0.5`
- `ExciterEnvelope.Retrigger` default `Off`
- `ExciterEnvelope.Gate` default `Off`
- `FrequencyHz.Value` default `0`
- `FrequencyHz.Add` default `0`
- `PeriodMs.Value` default `0`
- `LeftPeriod.Value` default `0`
- `LeftPeriod.Add` default `0`
- `RightPeriod.Value` default `0`
- `RightPeriod.Add` default `0`
- `LoopDamping.Mode` default `LowPass`
- `LoopDamping.Enabled` default `On`

## Locked Build Values

- Audio order in `MidiContext` = `Exciter`, `StereoFrames`
- Audio order in `Exciter` = `ExciterNoise`, `ExciterEnvelope`
- `Exciter.IsVertical` property = `false` (horizontal compact layout)
- `ExciterNoise.Mode` = `Noise`
- `ExciterNoise.Gain` = `0.25`
- `ExciterEnvelope.Attack` = `0` ms
- `ExciterEnvelope.Hold` = `1` ms
- `ExciterEnvelope.Decay` = `8` ms
- `ExciterEnvelope.Sustain` = `0`
- `ExciterEnvelope.Release` = `5` ms
- `ExciterEnvelope.NumParameters` property = `3`
- `NoteFrequency.Mode` property = `Frequency`
- `FrequencyHz.Multiply` range = `[0, 20000]`
- `FrequencyHz.Multiply` = `20000`
- `PeriodMs.Mode` property = `Freq2Ms`
- `LeftPeriod.Multiply` range = `[0, 2]`
- `LeftPeriod.Multiply` = `0.998`
- `RightPeriod.Multiply` range = `[0, 2]`
- `RightPeriod.Multiply` = `1.002`
- Both delay Limits = `30` ms
- Both DelayTime ranges = `[0, 30]` ms
- `LeftPeriod` -> `LeftDelay.DelayTime` unscaled
- `RightPeriod` -> `RightDelay.DelayTime` unscaled
- `LoopDamping.Smoothing` = `0`
- Feedback send order = after `StereoDelays` and `LoopDamping`

## Friction Comments To Weave In

- Before `MidiContext`: a Script FX needs a midichain so the same note triggers the noise burst and updates note-frequency extraction.
- Before `ExciterNoise`: Noise mode ignores MIDI pitch but supplies broadband energy for the tuned feedback loop; the short AHDSR prevents continuous excitation.
- Before `FrequencyHz`: Frequency mode emits note Hz divided by 20000, so multiply by 20000 before Freq2Ms conversion.
- Before `StereoDelays`: 0.998 and 1.002 period multipliers create a subtle pseudo-stereo resonant decay.
- Before feedback setup: remove the template delay, retain receive and send, and keep the send last.
- Before verification: use silent input with `--trigger-note`; the internal noise burst now excites the tuned loop.
- Before publication: frame feedback is expensive while interpreted; compile to C++ for practical use.

## Cosmetic Plan

- Main node: `StereoFrames`
- Accent colour: `0xFF8E44AD`
- Supporting relevant nodes: [`MidiContext`, `Exciter`, `ExciterNoise`, `ExciterEnvelope`, `NoteFrequency`, `FrequencyHz`, `PeriodMs`, `LeftPeriod`, `RightPeriod`, `ResonantLoop`, `StereoDelays`, `LeftDelay`, `RightDelay`, `LoopDamping`]
- Supporting colour: `0xFF7F6A91`
- Folded nodes: [`FrequencyHz`, `PeriodMs`, `LeftPeriod`, `RightPeriod`, `ResonantLoop_fb_out`, `ResonantLoop_fb_in`]
- Nodes that must stay visible: [`MidiContext`, `Exciter`, `ExciterNoise`, `ExciterEnvelope`, `StereoFrames`, `NoteFrequency`, `ResonantLoop`, `StereoDelays`, `LeftDelay`, `RightDelay`, `LoopDamping`]

## Open Questions

- None
