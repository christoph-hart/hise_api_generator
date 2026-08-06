---
id: math.sig2mod.audio-to-modulation
node: math.sig2mod
domain: scriptnode
category: dsp-network
title: Audio-to-modulation converter
summary: Uses math.sig2mod to convert a bipolar oscillator into a 0..1 modulation signal.
useCase: Use this before modulation-oriented consumers that expect unipolar values.
difficulty: beginner
networkName: audio_to_modulation
moduleType: ScriptFX
moduleId: AudioToModulation
tags:
  - range-conversion
  - modulation
  - bipolar
aliases:
  - signal to modulation
  - bipolar to unipolar
relatedNodes:
  - math.sig2mod
  - core.oscillator
  - core.peak
  - math.clear
parameters:
  RangeConverter.Value: Unused interface parameter; conversion is fixed.
---

scriptnode example: math.sig2mod

Audio-to-modulation converter.
Use this to compare a slow bipolar source with the converted 0..1 modulation range.

Graph:
```text
audio_to_modulation
  SlowOscillator        core.oscillator
  SourcePeak            core.peak
  RangeConverter        math.sig2mod
  ConvertedPeak         core.peak
  SignalClear           math.clear
```

Host:
  Module: `AudioToModulation`
  Type: `ScriptFX`
  Network: `audio_to_modulation`
  Builder setup: add ScriptFX `AudioToModulation`, then set its network.

Support nodes:
  Required: `core.oscillator`, `core.peak`, `math.clear`

Key rules:
  - Use the minimum supported `core.oscillator` frequency, 20 Hz, so both peak displays remain as slow as this factory allows.
  - Keep the source and converted displays adjacent.

Public controls:
  - None.

HISE CLI build commands:
```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id AudioToModulation --agent
hise-cli builder set --module AudioToModulation --network audio_to_modulation --agent
hise-cli dsp add --module AudioToModulation --type core.oscillator --id SlowOscillator --agent
hise-cli dsp set --module AudioToModulation --node SlowOscillator --param Mode --value 4 --agent
hise-cli dsp set --module AudioToModulation --node SlowOscillator --param Frequency --value 20 --agent
hise-cli dsp add --module AudioToModulation --type core.peak --id SourcePeak --agent
hise-cli dsp add --module AudioToModulation --type math.sig2mod --id RangeConverter --agent
hise-cli dsp add --module AudioToModulation --type core.peak --id ConvertedPeak --agent
hise-cli dsp add --module AudioToModulation --type math.clear --id SignalClear --agent
```
