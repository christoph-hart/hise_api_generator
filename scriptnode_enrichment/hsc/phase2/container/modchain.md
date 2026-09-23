# container.modchain - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/container/modchain.md`
- Reference: `scriptnode_enrichment/output/container/modchain.md`

## Naming

- Module ID: `ControlRateOscillatorVibrato`
- Network ID: `control_rate_oscillator_vibrato`

## Graph Plan

```text
control_rate_oscillator_vibrato
  Resolution32           container.fix32_block
    VibratoControl       container.modchain
      LfoRamp            core.ramp
      FullCycle          math.pi
      SineShape          math.sin
      Normalise          math.sig2mod
      VibratoPeak        core.peak
    SawTone              core.oscillator
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - Verify that `SawTone.Freq Ratio` accepts the narrowed fractional range before connecting modulation.
  - Put both modulation source and audible target inside the same fixed 32-sample wrapper.
- Channel/routing setup:
  - Required channels: default stereo; modchain uses a separate mono control buffer
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: [control buffer does not enter parent audio]

## Public Parameters

- Rate -> `LfoRamp.PeriodTime` matched
- Target range before connection: `[100, 2000]`
- Macro range: `[100, 2000]`
- Default: `500`

## Defaults To Omit

- `Normalise.Value` default `0.0`
- `VibratoPeak.Value` default `0.0`
- `SawTone.Gain` default `1.0`

## Locked Build Values

- `Resolution32` block size = `32` audio samples
- Verified nested modchain block size = `4` samples at one-eighth sample rate
- Child order in `Resolution32` = `VibratoControl`, `SawTone`
- `FullCycle.Value` range = `[0, 2]`
- `FullCycle.Value` = `2.0`
- `SawTone.Mode` = `Saw`
- `SawTone.Gate` = `On`
- `SawTone.Freq Ratio` range = `[0.98, 1.02]`, step size `0`
- `VibratoPeak` output range = `[0, 1]`
- `VibratoPeak` modulation output -> `SawTone.Freq Ratio` matched

## Friction Comments To Weave In

- Before `Resolution32`: constraining both source and target to 32-sample blocks increases the parameter-update resolution from one host block to every 32 audio samples.
- Before `VibratoControl`: this container processes an isolated mono control buffer and leaves parent audio untouched.
- Before `Normalise`: convert the bipolar sine before peak extraction or the negative half-cycle would be folded.
- Before the modulation connection: configure the oscillator's fractional ratio override with step size zero. Retaining its default integer step quantizes the subtle vibrato to `1.0`.

## Cosmetic Plan

- Main node: `VibratoControl`
- Accent colour: `0xFF8E44AD`
- Supporting relevant nodes: [`Resolution32`, `LfoRamp`, `VibratoPeak`, `SawTone`]
- Supporting colour: `0xFF7F6A91`
- Folded nodes: [`FullCycle`, `SineShape`, `Normalise`]
- Nodes that must stay visible: [`Resolution32`, `VibratoControl`, `VibratoPeak`, `SawTone`]

## Open Questions

- None
