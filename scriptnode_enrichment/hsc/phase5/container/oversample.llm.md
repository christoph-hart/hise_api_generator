---
id: container.oversample.selectable-anti-aliasing-quality
node: container.oversample
domain: scriptnode
category: dsp-network
title: "Selectable Anti-Aliasing Quality"
summary: "Upsamples the audio signal by a selectable factor, processes child nodes at the higher rate, then downsamples back."
useCase: "Demonstrate how `container.oversample` changes the sample rate and block size seen by nonlinear children, and why its factor is a configuration choice rather than a continuously modulated effect parameter."
difficulty: advanced
networkName: selectable_anti_aliasing_quality
moduleType: ScriptFX
moduleId: SelectableAntiAliasingQuality
tags:
  - container
  - oversample
aliases:
  - selectable anti-aliasing quality
  - oversample container
relatedNodes:
  - container.oversample
  - math.expr
parameters:
  Quality: "Quality -> QualityResampler.Oversampling matched"
  Target: "Target range before connection: [0, 4], step 1"
  Macro: "Macro range: [0, 4], step 1, labels None, 2x, 4x, 8x, 16x"
  Default:: "Default: 2"
---

scriptnode example: container.oversample

Selectable Anti-Aliasing Quality.

Demonstrate how `container.oversample` changes the sample rate and block size seen by nonlinear children, and why its factor is a configuration choice rather than a continuously modulated effect parameter.

Graph:
```text
selectable_anti_aliasing_quality
  QualityResampler       container.oversample
    SineFolder           math.expr
  OutputSpectrum         analyse.fft
```

Host:
  Module: SelectableAntiAliasingQuality
  Network: selectable_anti_aliasing_quality
  Type: `ScriptFX`
  Builder setup: `add ScriptFX as "SelectableAntiAliasingQuality"`, then set its network to `selectable_anti_aliasing_quality`.

Support nodes:
  Required: math.expr
  Optional: analyse.fft
  `math.expr` implements a deliberately aggressive sine-folding transfer function that produces obvious aliasing at 1x; an optional `analyse.fft` can display the reduction in folded spectral components without becoming part of the processing topology.

Key rules:
  - Quality is a setup-time exponent index rather than a modulation target.
  - Only the nonlinear child is oversampled.
  - Bypass removes resampling but continues child processing at the host rate.
  - Do not add an uncompensated parallel dry path because resampler latency is not reported.
  - Changing the factor during playback causes a gap: Changing the oversampling factor triggers a full re-preparation of the entire child chain. Audio output is briefly interrupted during this process. Treat the Oversampling parameter as a configuration setting, not a real-time control.
  - Nesting oversample containers is not allowed: The container checks that the incoming sample rate matches the network's original sample rate. If the signal has already been upsampled, this check fails and the node reports an error.
  - Cannot be used in polyphonic networks: Oversampling is restricted to monophonic processing. If the container detects a polyphonic voice context, it reports an error.

Public controls:
  - Quality -> QualityResampler.Oversampling matched
  - Target range before connection: [0, 4], step 1
  - Macro range: [0, 4], step 1, labels None, 2x, 4x, 8x, 16x
  - Default: 2

HISE CLI build commands:
```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id SelectableAntiAliasingQuality --agent
hise-cli builder set --module SelectableAntiAliasingQuality --network selectable_anti_aliasing_quality --agent
hise-cli dsp add --module SelectableAntiAliasingQuality --type container.oversample --id QualityResampler --agent
hise-cli dsp add --module SelectableAntiAliasingQuality --type math.expr --id SineFolder --parent QualityResampler --agent
hise-cli dsp set --module SelectableAntiAliasingQuality --node SineFolder --param Code --value '"Math.sin(input * (1.0f + value * 12.0f))"' --agent
hise-cli dsp set --module SelectableAntiAliasingQuality --node SineFolder --param Value --value 0.7 --agent
hise-cli dsp add --module SelectableAntiAliasingQuality --type analyse.fft --id OutputSpectrum --agent
hise-cli dsp set --module SelectableAntiAliasingQuality --node QualityResampler --param Oversampling --range "0,4" --stepSize 1 --agent
hise-cli dsp set --module SelectableAntiAliasingQuality --node QualityResampler --param Oversampling --value 2 --agent
# Quality is an exponent index: None, 2x, 4x, 8x, 16x. Changing it re-prepares the child chain.
hise-cli dsp create_parameter --module SelectableAntiAliasingQuality --container selectable_anti_aliasing_quality --id Quality --range "0,4" --default 2 --stepSize 1 --agent
hise-cli dsp connect --module SelectableAntiAliasingQuality --source selectable_anti_aliasing_quality --source-param Quality --target QualityResampler --param Oversampling --matched --agent
# Expose Oversampling so the root Quality cable is visible on the inner container.
hise-cli dsp set --module SelectableAntiAliasingQuality --node QualityResampler --param ShowParameters --value true --agent
# Keep only the nonlinear stage oversampled. Unreported latency makes an uncompensated dry branch unsuitable.
hise-cli dsp set --module SelectableAntiAliasingQuality --node selectable_anti_aliasing_quality --param Comment --value '"**Serial topology** - Unreported resampler latency makes an uncompensated parallel dry path unsuitable."' --agent
hise-cli dsp set --module SelectableAntiAliasingQuality --node QualityResampler --param NodeColour --value 0xFFE67E22 --agent
hise-cli dsp set --module SelectableAntiAliasingQuality --node QualityResampler --param Comment --value '"**Setup control** - Quality is an exponent index; changing it re-prepares only the nonlinear child chain."' --agent
hise-cli dsp set --module SelectableAntiAliasingQuality --node SineFolder --param NodeColour --value 0xFF8C6D55 --agent
hise-cli dsp set --module SelectableAntiAliasingQuality --node OutputSpectrum --param NodeColour --value 0xFF8C6D55 --agent
hise-cli dsp set --module SelectableAntiAliasingQuality --node OutputSpectrum --param Folded --value true --agent
```

