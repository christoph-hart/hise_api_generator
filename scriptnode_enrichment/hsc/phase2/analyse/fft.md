# analyse.fft - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/analyse/fft.md`
- Reference: `scriptnode_enrichment/output/analyse/fft.md`

## Naming

- Module ID: `SpectrumComparison`
- Network ID: `spectrum_comparison`

## Graph Plan

```text
spectrum_comparison
  SpectrumBranches      container.split
    SineBranch            container.chain
      SineClear             math.clear
      SineSource            core.oscillator
      SineTrim              core.gain
      SineSpectrum          analyse.fft
    SawBranch             container.chain
      SawClear              math.clear
      SawSource             core.oscillator
      SawTrim               core.gain
      SawSpectrum           analyse.fft
    NoiseBranch           container.chain
      NoiseClear            math.clear
      NoiseSource           core.oscillator
      NoiseTrim             core.gain
      NoiseSpectrum         analyse.fft
  OutputClear           math.clear
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - Create a monophonic Script FX and initialise `spectrum_comparison`.
  - Register each FFT display buffer with a distinct external display source if the graphs will be shown on the scripted interface.
  - Apply the same ring-buffer properties to all three FFT nodes with `DisplayBuffer.setRingBufferProperties()` so the comparison persists after reload.
- Channel/routing setup:
  - Required channels: default stereo; each oscillator produces duplicated stereo, but each FFT analyses channel 0 only
  - Module routing: default stereo
  - Master routing: default
  - Channel-specific comments needed: [FFT analysis is hardcoded to the first channel, the stereo signal still passes through each analyser unchanged]

## Public Parameters

- TestFrequency -> `SineSource.Frequency` matched
- Target range before connection: `[40, 2000]`
- Macro range: `[40, 2000]`
- Default: `220`
- TestFrequency -> `SawSource.Frequency` matched
- Target range before connection: `[40, 2000]`
- Macro range: `[40, 2000]`
- Default: `220`
- DisplayDecay -> scripted FFT display property `Decay`
- Scripted property range: `[0.0, 0.99999]`
- Default: `0.7`

## Defaults To Omit

- `SineSource.Gate` default `On`
- `SawSource.Gate` default `On`
- `NoiseSource.Gate` default `On`
- FFT properties other than those listed below remain at their documented defaults.

## Locked Build Values

- `SineSource.Mode` = `Sine`
- `SawSource.Mode` = `Saw`
- `NoiseSource.Mode` = `Noise`
- `SineSource.Gain` = `0.2`
- `SawSource.Gain` = `0.2`
- `NoiseSource.Gain` = `0.1`
- `SineTrim.Gain` = `0 dB`
- `SawTrim.Gain` = `0 dB`
- `NoiseTrim.Gain` = `0 dB`
- All FFT nodes: `BufferLength` = `8192`
- All FFT nodes: `WindowType` = `Blackman Harris`
- All FFT nodes: `Overlap` = `0.0`
- All FFT nodes: `DecibelRange` = `[-60, 0]`
- All FFT nodes: `UseDecibelScale` = `On`
- All FFT nodes: `UseLogarithmicFreqAxis` = `On`

## Friction Comments To Weave In

- Before each clear node: `core.oscillator` adds to its input, so each branch must clear the incoming Script FX signal before generating its test waveform.
- Before `SpectrumBranches`: a split sums its child outputs. Keep branch gains conservative even though `OutputClear` later mutes the result.
- Before the FFT nodes: place each analyser after its branch trim so every display sees exactly the signal produced by that branch.
- Before display setup: popup property edits are temporary. Use the display-buffer scripting API to persist identical settings for all three analysers.
- Before `OutputClear`: the analysers are passthrough nodes, so explicitly clear the summed oscillator signal to keep this an analysis-only fixture.

## Cosmetic Plan

- Main node: `SineSpectrum`
- Accent colour: `0xFF2F80ED`
- Supporting relevant nodes: [`SpectrumBranches`, `SineSource`, `SawSource`, `NoiseSource`, `SawSpectrum`, `NoiseSpectrum`]
- Supporting colour: `0xFF6F8FAF`
- Folded nodes: [`SineClear`, `SawClear`, `NoiseClear`, `SineTrim`, `SawTrim`, `NoiseTrim`, `OutputClear`]
- Nodes that must stay visible: [`SpectrumBranches`, `SineBranch`, `SineSource`, `SineSpectrum`, `SawBranch`, `SawSource`, `SawSpectrum`, `NoiseBranch`, `NoiseSource`, `NoiseSpectrum`]

## Open Questions

- None. The output-muting decision and persistent shared FFT display configuration are resolved.
