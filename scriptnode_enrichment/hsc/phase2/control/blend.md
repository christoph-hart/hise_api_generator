# control.blend - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/control/blend.md`
- Reference: `scriptnode_enrichment/output/control/blend.md`

## Naming

- Module ID: `HumanisedLfoBlend`
- Network ID: `humanised_lfo_blend`

## Graph Plan

```text
humanised_lfo_blend
  ModulationSources      container.modchain
    SourceSplit          container.split
      RegularMotion      container.no_midi
        SineLfo          core.oscillator
        SineNormalise    math.sig2mod
        SinePeak         core.peak
      RandomMotion       container.no_midi
        NoiseSource      core.oscillator
        sampleandhold    fx.sampleandhold
        smoother         core.smoother
        NoiseNormalise   math.sig2mod
        NoisePeak        core.peak
    HumaniseBlend        control.blend
  CutoffNormalise        control.normaliser
  MovingFilter           filters.svf
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - None
- Channel/routing setup:
  - Required channels: default stereo; both sources are isolated in a mono modchain
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: [split creates independent control-source branches]

## Public Parameters

- Humanise -> `HumaniseBlend.Alpha` matched
- Target range before connection: `[0, 1]`
- Macro range: `[0, 1]`
- Default: `0.35`

## Defaults To Omit

- `HumaniseBlend.Alpha` default `0.0`
- `HumaniseBlend.Value1` default `0.0`
- `HumaniseBlend.Value2` default `0.0`

## Locked Build Values

- `SineLfo.Mode` = `Sine`
- `SineLfo.Frequency` range = `[0.1, 5]`
- `SineLfo.Frequency` = `0.5`
- `NoiseSource.Mode` = `Noise`
- `NoiseSource.Mode` = `Noise`
- `sampleandhold.Counter` = `412`
- `smoother.SmoothingTime` = `772.6`
- `NoisePeak` output -> `HumaniseBlend.Value2` raw connection over `[0, 1]`
- `SinePeak` output -> `HumaniseBlend.Value1` raw connection over `[0, 1]`
- `HumaniseBlend` output -> `CutoffNormalise.Value`
- `CutoffNormalise` output -> `MovingFilter.Frequency` range = `[250, 7000]`, skewed
- `MovingFilter.Mode` = `LowPass`
- `MovingFilter.Smoothing` = `0.03`

## Friction Comments To Weave In

- Before `SourceSplit`: each branch receives its own control buffer copy before results are exported.
- Before `RandomMotion`: `fx.sampleandhold` reduces random update frequency and `core.smoother` converts the steps into slow audible drift.
- Before `HumaniseBlend`: Alpha 0 selects sine exactly, Alpha 1 selects filtered noise exactly, and intermediate values are linear interpolation.
- Before no_midi wrappers: fixed control oscillators must not react to played note pitch.

## Cosmetic Plan

- Main node: `HumaniseBlend`
- Accent colour: `0xFF8E44AD`
- Supporting relevant nodes: [`SineLfo`, `NoiseSource`, `sampleandhold`, `smoother`, `MovingFilter`]
- Supporting colour: `0xFF7F6A91`
- Folded nodes: [`SineNormalise`, `SinePeak`, `NoiseNormalise`, `NoisePeak`]
- Nodes that must stay visible: [`HumaniseBlend`, `SineLfo`, `NoiseSource`, `sampleandhold`, `smoother`, `CutoffNormalise`, `MovingFilter`]

## Open Questions

- None
