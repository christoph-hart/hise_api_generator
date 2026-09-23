# container.framex_block - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/container/framex_block.md`
- Reference: `scriptnode_enrichment/output/container/framex_block.md`

## Naming

- Module ID: `ThreeLevelPhaseModulation`
- Network ID: `three_level_phase_modulation`

## Graph Plan

```text
three_level_phase_modulation
  ChannelAllocator      container.multi
    DynamicFrames       container.framex_block
      OSC1              container.chain
        InputClear      math.clear
        Sine1           core.oscillator
      OSC2              container.chain
        Normalise1      math.sig2mod
        Peak1           core.peak
        Clear1          math.clear
        Sine2           core.oscillator
      OSC3              container.chain
        Normalise2      math.sig2mod
        Peak2           core.peak
        Clear2          math.clear
        Sine3           core.oscillator
      ENV               container.chain
        OutputEnvelope  envelope.simple_ar
        VoiceLifecycle  envelope.voice_manager
  StereoOutput          core.mono2stereo
```

## Builder Setup

- Host context: `Script Synth`
- Additional builder steps:
  - Trigger MIDI notes; all oscillators track the note before applying their static frequency ratios.
  - Keep exactly one child in `ChannelAllocator` for canonical verification.
  - Keep `StereoOutput` after `ChannelAllocator` so channel 0 is duplicated to channel 1 regardless of framex width.
- Channel/routing setup:
  - Required channels: default stereo polyphonic voice context; the single multi child receives both channels
  - Module routing: default stereo
  - Master routing: default stereo
  - Channel-specific comments needed: [framex width comes from the multi slice; adding another child reduces this slice to one channel]

## Public Parameters

- None

## Defaults To Omit

- All oscillator Mode parameters default to `Sine`
- All oscillator Gate parameters default to `On`
- `Sine1.Gain` default `1`
- `Sine2.Gain` default `1`
- `Sine3.Freq Ratio` default `1`
- `OutputEnvelope.Gate` default `Off`
- `VoiceLifecycle.Kill Voice` default `1`
- `Normalise1.Value` default `0`
- `Normalise2.Value` default `0`
- All clear-node Value parameters are unused defaults

## Locked Build Values

- `ChannelAllocator` child count = `1`
- `DynamicFrames` inherited channel count = `2`
- `DynamicFrames.IsVertical` = `false`
- `OSC1.IsVertical` = `true`
- `OSC2.IsVertical` = `true`
- `OSC3.IsVertical` = `true`
- `ENV.IsVertical` = `true`
- Serial group order = `OSC1`, `OSC2`, `OSC3`, `ENV`
- All oscillator Freq Ratio ranges = `[0.5, 2]`, middle position `1`
- `Sine1.Freq Ratio` = `2.0`
- `Sine2.Freq Ratio` = `0.5`
- `Sine3.Freq Ratio` = `1.0`
- `Sine3.Gain` = `0.15`
- `OutputEnvelope.Attack` = `5` ms
- `OutputEnvelope.Release` = `80` ms
- `OutputEnvelope` Gate output -> `VoiceLifecycle.Kill Voice`
- `Peak1` output -> `Sine2.Phase` range `[0, 1]`
- `Peak2` output -> `Sine3.Phase` range `[0, 1]`

## Friction Comments To Weave In

- Before `ChannelAllocator`: with one child, framex inherits both stereo channels; adding another multi child would split the pair and make DynamicFrames process one channel.
- Before oscillator ratios: widen Freq Ratio before setting 0.5; MIDI supplies the common base pitch and static ratios create the harmonic relationships.
- Before subgroup construction: horizontal frame layout with vertical stage groups makes the serial PM structure compact without changing processing order.
- Before `InputClear`: oscillators add to their input, so clear host audio before starting the PM cascade.
- Before each peak: sig2mod converts -1..1 to 0..1, preventing peak's absolute detector from folding the bipolar sine at zero.
- Before each intermediate clear: export the modulation first, then clear the modulator audio so only Sine3 reaches the output.
- Before `StereoOutput`: mono2stereo requires the existing stereo context and copies channel 0 to channel 1; it guarantees dual-mono output if framex later receives only one multi slice.
- Before publication: interpreted dynamic-width polyphonic frame processing is extremely expensive; compile to C++ for practical use, and prefer frame2 when stereo width is known.

## Cosmetic Plan

- Main node: `DynamicFrames`
- Accent colour: `0xFF8E44AD`
- Supporting relevant nodes: [`ChannelAllocator`, `OSC1`, `OSC2`, `OSC3`, `ENV`, `Sine1`, `Normalise1`, `Peak1`, `Sine2`, `Normalise2`, `Peak2`, `Sine3`, `OutputEnvelope`, `VoiceLifecycle`, `StereoOutput`]
- Supporting colour: `0xFF7F6A91`
- Folded nodes: [`InputClear`, `Normalise1`, `Peak1`, `Clear1`, `Normalise2`, `Peak2`, `Clear2`, `VoiceLifecycle`]
- Nodes that must stay visible: [`ChannelAllocator`, `DynamicFrames`, `OSC1`, `OSC2`, `OSC3`, `ENV`, `Sine1`, `Sine2`, `Sine3`, `OutputEnvelope`, `StereoOutput`]

## Open Questions

- None
