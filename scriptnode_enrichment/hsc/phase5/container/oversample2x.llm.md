---
id: container.oversample2x.lightweight-soft-saturation
node: container.oversample2x
domain: scriptnode
category: dsp-network
title: "Lightweight Soft Saturation"
summary: "Upsamples the audio signal by a fixed factor of 2, processes child nodes at the higher rate, then downsamples back."
useCase: "Demonstrate fixed 2x processing as the lowest-cost oversampling choice for a nonlinear effect that produces a modest harmonic spectrum."
difficulty: advanced
networkName: lightweight_soft_saturation
moduleType: ScriptFX
moduleId: LightweightSoftSaturation
tags:
  - container
  - oversample2x
aliases:
  - lightweight soft saturation
  - oversample2x container
relatedNodes:
  - container.oversample2x
  - math.mul
  - math.tanh
parameters:
  Drive: "Drive -> PreGain.Value matched"
  Target: "Target range before connection: [1, 6]"
  Macro: "Macro range: [1, 6]"
  Default:: "Default: 3"
---

scriptnode example: container.oversample2x

Lightweight Soft Saturation.

Demonstrate fixed 2x processing as the lowest-cost oversampling choice for a nonlinear effect that produces a modest harmonic spectrum.

Graph:
```text
lightweight_soft_saturation
  DoubleRateSaturation   container.oversample2x
    PreGain              math.mul
    SoftClip             math.tanh
    OutputTrim           math.mul
  OutputSpectrum         analyse.fft
```

Host:
  Module: LightweightSoftSaturation
  Network: lightweight_soft_saturation
  Type: `ScriptFX`
  Builder setup: `add ScriptFX as "LightweightSoftSaturation"`, then set its network to `lightweight_soft_saturation`.

Support nodes:
  Required: math.mul, math.tanh
  Optional: analyse.fft
  A pre-gain `math.mul` pushes incoming audio into `math.tanh`, the tanh node supplies bounded soft saturation, and a second multiplier restores a comparable output level; an optional FFT provides consistent visual comparison of folded harmonics between 1x and 2x processing.

Key rules:
  - Keep all gain stages inside the oversampled context.
  - Use math.mul for pre-gain above unity.
  - Bypass keeps the saturator active at the host rate.
  - Avoid an uncompensated dry branch.
  - Nesting oversample containers is not allowed: The container checks that the incoming sample rate matches the network's original sample rate. If the signal has already been upsampled, this check fails and the node reports an error.
  - Cannot be used in polyphonic networks: Oversampling is restricted to monophonic processing. If the container detects a polyphonic voice context, it reports an error.

Public controls:
  - Drive -> PreGain.Value matched
  - Target range before connection: [1, 6]
  - Macro range: [1, 6]
  - Default: 3

HISE CLI build commands:
```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id LightweightSoftSaturation --agent
hise-cli builder set --module LightweightSoftSaturation --network lightweight_soft_saturation --agent
# Keep gain staging and saturation together so all three stages share the doubled context.
hise-cli dsp add --module LightweightSoftSaturation --type container.oversample2x --id DoubleRateSaturation --agent
hise-cli dsp add --module LightweightSoftSaturation --type math.mul --id PreGain --parent DoubleRateSaturation --agent
hise-cli dsp add --module LightweightSoftSaturation --type math.tanh --id SoftClip --parent DoubleRateSaturation --agent
hise-cli dsp add --module LightweightSoftSaturation --type math.mul --id OutputTrim --parent DoubleRateSaturation --agent
hise-cli dsp add --module LightweightSoftSaturation --type analyse.fft --id OutputSpectrum --agent
# math.mul permits drive values above unity, unlike the tanh node's 0..1 Value range.
hise-cli dsp set --module LightweightSoftSaturation --node PreGain --param Value --range "1,6" --agent
hise-cli dsp set --module LightweightSoftSaturation --node PreGain --param Value --value 3 --agent
hise-cli dsp set --module LightweightSoftSaturation --node OutputTrim --param Value --value 0.4 --agent
hise-cli dsp create_parameter --module LightweightSoftSaturation --container lightweight_soft_saturation --id Drive --range "1,6" --default 3 --agent
hise-cli dsp connect --module LightweightSoftSaturation --source lightweight_soft_saturation --source-param Drive --target PreGain --param Value --matched --agent
# Bypass removes resampling but still runs this complete saturator at the host rate.
hise-cli dsp set --module LightweightSoftSaturation --node lightweight_soft_saturation --param Comment --value '"**Serial topology** - Resampler latency is not reported, so this example has no uncompensated dry branch."' --agent
hise-cli dsp set --module LightweightSoftSaturation --node DoubleRateSaturation --param NodeColour --value 0xFFE67E22 --agent
hise-cli dsp set --module LightweightSoftSaturation --node DoubleRateSaturation --param Comment --value '"**Complete gain stage** - Pre-gain, soft clipping, and output trim all share the doubled processing context."' --agent
hise-cli dsp set --module LightweightSoftSaturation --node PreGain --param NodeColour --value 0xFF8C6D55 --agent
hise-cli dsp set --module LightweightSoftSaturation --node SoftClip --param NodeColour --value 0xFF8C6D55 --agent
hise-cli dsp set --module LightweightSoftSaturation --node OutputTrim --param NodeColour --value 0xFF8C6D55 --agent
hise-cli dsp set --module LightweightSoftSaturation --node OutputSpectrum --param NodeColour --value 0xFF8C6D55 --agent
hise-cli dsp set --module LightweightSoftSaturation --node OutputSpectrum --param Folded --value true --agent
```

