# container.frame1_block - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/container/frame1_block.md`
- Reference: `scriptnode_enrichment/output/container/frame1_block.md`

## Naming

- Module ID: `AntiphaseStereoChorus`
- Network ID: `antiphase_stereo_chorus`

## Graph Plan

```text
antiphase_stereo_chorus
  ChorusMix                    template.dry_wet
    ChorusMix_wet_path
      StereoWetChannels        container.multi
        LeftFrames             container.frame1_block
          LeftDelayLfo         container.modchain
            LeftRamp           core.ramp
            LeftCycle          math.pi
            LeftSine           math.sin
            LeftNormalise      math.sig2mod
            LeftDelayControl   core.peak
          LeftDelay            jdsp.jdelay_cubic
        RightFrames            container.frame1_block
          RightDelayLfo        container.modchain
            RightRamp          core.ramp
            RightCycle         math.pi
            RightSine          math.sin
            InvertRight        math.mul
            RightNormalise     math.sig2mod
            RightDelayControl  core.peak
          RightDelay           jdsp.jdelay_cubic
      ChorusMix_wet_gain
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - Add a module-tree `WaveSynth` as `Waveform Generator` so MIDI notes provide an immediate audition source.
  - Add `StereoWetChannels` to `ChorusMix_wet_path`, remove the template dummy, and keep `ChorusMix_wet_gain` last.
  - Feed the WaveSynth or correlated stereo noise through the effect and verify opposite left/right delay movement.
  - Warn that the interpreted network has extremely high CPU usage because both frame1 branches execute per sample; compile it to a C++ node for practical use.
- Channel/routing setup:
  - Required channels: default stereo; `container.multi` assigns one mono channel to each frame child
  - Module routing: default stereo
  - Master routing: default stereo
  - Channel-specific comments needed: [left and right use independent frame1 processors; right modulation is polarity-inverted]

## Public Parameters

- Rate -> `LeftRamp.PeriodTime` and `RightRamp.PeriodTime` matched
- Target ranges before connection: `[200, 6000]`
- Macro range: `[200, 6000]` ms period
- Default: `5000`
- Mix -> `ChorusMix.DryWet` matched
- Target range before connection: `[0, 1]`
- Macro range: `[0, 1]`
- Default: `0.5`
- LfoGate -> `LeftRamp.Gate` and `RightRamp.Gate` matched
- Macro range: `Off/On`
- Default: `On`
- Construction reset: set LfoGate to `Off`, then `On` after both connections are present

## Defaults To Omit

- `LeftCycle.Value` default `2`
- `RightCycle.Value` default `2`
- `LeftNormalise.Value` default `0`
- `RightNormalise.Value` default `0`
- `LeftDelayControl.Value` default `0`
- `RightDelayControl.Value` default `0`

## Locked Build Values

- Both frame containers process exactly `1` channel per frame
- `LeftDelay.Limit` = `20` ms
- `RightDelay.Limit` = `20` ms
- Both DelayTime ranges = `[4, 10]` ms, middle position `7` for linear antiphase mapping
- `InvertRight.Value` range = `[-1, 1]`
- `InvertRight.Value` = `-1`
- `LeftDelayControl` -> `LeftDelay.DelayTime`
- `RightDelayControl` -> `RightDelay.DelayTime`
- Dry/wet crossfade law = `linear`
- Wet-path order = `StereoWetChannels`, `ChorusMix_wet_gain`

## Friction Comments To Weave In

- Before `StereoWetChannels`: each multi child receives one channel, making two frame1 containers safe in a default stereo host.
- Before `InvertRight`: invert the bipolar sine before normalization; this produces `1 - left` after sig2mod and opposite delay movement.
- Before verification: toggle the shared LfoGate off and on after construction so the two independently created ramps restart together; otherwise their creation times can leave a fixed phase offset.
- Before each delay connection: set both 4 to 10 ms target ranges with middle position 7 first; retaining the delay node's original skew would make complementary LFO values produce asymmetric times.
- Before wet-path construction: retain the template wet gain and keep it last.
- Before verification: this dual-frame graph has extremely high CPU usage while interpreted in HISE. Compile the network to a C++ node before practical use.

## Cosmetic Plan

- Main nodes: [`LeftFrames`, `RightFrames`]
- Accent colour: `0xFF8E44AD`
- Supporting relevant nodes: [`ChorusMix`, `StereoWetChannels`, `LeftDelayLfo`, `LeftDelay`, `RightDelayLfo`, `RightDelay`]
- Supporting colour: `0xFF7F6A91`
- Folded nodes: [`LeftCycle`, `LeftSine`, `LeftNormalise`, `LeftDelayControl`, `RightCycle`, `RightSine`, `InvertRight`, `RightNormalise`, `RightDelayControl`, `ChorusMix_wet_gain`]
- ShowParameters containers: [`ChorusMix`]
- Nodes that must stay visible: [`ChorusMix`, `StereoWetChannels`, `LeftFrames`, `LeftDelayLfo`, `LeftRamp`, `LeftDelay`, `RightFrames`, `RightDelayLfo`, `RightRamp`, `RightDelay`]

## Open Questions

- None
