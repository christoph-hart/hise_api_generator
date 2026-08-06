---
id: math.sin.ramp-to-sine-converter
node: math.sin
domain: scriptnode
category: dsp-network
title: Ramp-to-sine converter
summary: Uses math.sin to convert a ramp phase into a display-friendly sine curve.
useCase: Use this to turn a normalized phase ramp into a sine-shaped modulation signal.
difficulty: intermediate
networkName: ramp_to_sine_converter
moduleType: ScriptFX
moduleId: RampToSineConverter
tags:
  - sine
  - phase
  - waveform
aliases:
  - ramp sine converter
  - phase to sine
relatedNodes:
  - math.sin
  - core.ramp
  - math.pi
  - math.sig2mod
  - core.peak
  - math.clear
parameters:
  RadianScale.Value: Fixed full-cycle pi scaling.
  DisplayRange.Value: Fixed signal-to-modulation conversion.
---

scriptnode example: math.sin

Ramp-to-sine converter.
Use this to show the complete phase conversion: ramp, radians, sine, then bipolar-to-unipolar display conversion.

Graph:
```text
ramp_to_sine_converter
  SlowRamp              core.ramp
  RadianScale           math.pi
  SineShape             math.sin
  DisplayRange          math.sig2mod
  OutputPeak            core.peak
  SignalClear           math.clear
```

Host:
  Module: `RampToSineConverter`
  Type: `ScriptFX`
  Network: `ramp_to_sine_converter`
  Builder setup: add ScriptFX `RampToSineConverter`, then set its network.

Support nodes:
  Required: `core.ramp`, `math.pi`, `math.sig2mod`, `core.peak`, `math.clear`

Key rules:
  - Keep the pi stage at its full-cycle setting.
  - Convert the bipolar sine to 0..1 before the peak display.

Public controls:
  - None.

HISE CLI build commands:
```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id RampToSineConverter --agent
hise-cli builder set --module RampToSineConverter --network ramp_to_sine_converter --agent
hise-cli dsp add --module RampToSineConverter --type core.ramp --id SlowRamp --agent
hise-cli dsp set --module RampToSineConverter --node SlowRamp --param PeriodTime --value 1000 --agent
hise-cli dsp add --module RampToSineConverter --type math.pi --id RadianScale --agent
hise-cli dsp add --module RampToSineConverter --type math.sin --id SineShape --agent
hise-cli dsp add --module RampToSineConverter --type math.sig2mod --id DisplayRange --agent
hise-cli dsp add --module RampToSineConverter --type core.peak --id OutputPeak --agent
hise-cli dsp add --module RampToSineConverter --type math.clear --id SignalClear --agent
```
