---
id: container.oversample4x.production-hard-clipper
node: container.oversample4x
domain: scriptnode
category: dsp-network
title: "Production Hard Clipper"
summary: "Upsamples the audio signal by a fixed factor of 4, processes child nodes at the higher rate, then downsamples back."
useCase: "Demonstrate the quality-versus-CPU middle ground of fixed 4x oversampling around conventional block-based distortion."
difficulty: advanced
networkName: production_hard_clipper
moduleType: ScriptFX
moduleId: ProductionHardClipper
tags:
  - container
  - oversample4x
aliases:
  - production hard clipper
  - oversample4x container
relatedNodes:
  - container.oversample4x
  - math.mul
  - math.clip
parameters:
  Drive: "Drive -> PreGain.Value matched"
  Target: "Target range before connection: [1, 8]"
  Macro: "Macro range: [1, 8]"
  Default:: "Default: 4"
---

scriptnode example: container.oversample4x

Production Hard Clipper.

Demonstrate the quality-versus-CPU middle ground of fixed 4x oversampling around conventional block-based distortion.

Graph:
```text
production_hard_clipper
  QuadRateClipper        container.oversample4x
    PreGain              math.mul
    HardClip             math.clip
    OutputTrim           math.mul
  OutputSpectrum         analyse.fft
```

Host:
  Module: ProductionHardClipper
  Network: production_hard_clipper
  Type: `ScriptFX`
  Builder setup: `add ScriptFX as "ProductionHardClipper"`, then set its network to `production_hard_clipper`.

Support nodes:
  Required: math.mul, math.clip
  Optional: analyse.fft
  A pre-gain `math.mul` forces the signal beyond the `math.clip` threshold, the clipper generates the strong harmonics that justify 4x processing, and a second multiplier controls output level; an optional FFT verifies reduced foldback relative to the bypassed 1x case.

Key rules:
  - Keep all distortion stages inside the 4x context.
  - Keep the analyser outside.
  - Do not wrap math.clip in a frame container.
  - Bypass retains the distortion chain at 1x.
  - Nesting oversample containers is not allowed: The container checks that the incoming sample rate matches the network's original sample rate. If the signal has already been upsampled, this check fails and the node reports an error.
  - Cannot be used in polyphonic networks: Oversampling is restricted to monophonic processing. If the container detects a polyphonic voice context, it reports an error.

Public controls:
  - Drive -> PreGain.Value matched
  - Target range before connection: [1, 8]
  - Macro range: [1, 8]
  - Default: 4

HISE CLI build commands:
```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id ProductionHardClipper --agent
hise-cli builder set --module ProductionHardClipper --network production_hard_clipper --agent
# All distortion stages share 4x processing; analysis remains outside at the host rate.
hise-cli dsp add --module ProductionHardClipper --type container.oversample4x --id QuadRateClipper --agent
hise-cli dsp add --module ProductionHardClipper --type math.mul --id PreGain --parent QuadRateClipper --agent
hise-cli dsp add --module ProductionHardClipper --type math.clip --id HardClip --parent QuadRateClipper --agent
hise-cli dsp add --module ProductionHardClipper --type math.mul --id OutputTrim --parent QuadRateClipper --agent
hise-cli dsp add --module ProductionHardClipper --type analyse.fft --id OutputSpectrum --agent
hise-cli dsp set --module ProductionHardClipper --node PreGain --param Value --range "1,8" --agent
hise-cli dsp set --module ProductionHardClipper --node PreGain --param Value --value 4 --agent
hise-cli dsp set --module ProductionHardClipper --node HardClip --param Value --value 0.35 --agent
hise-cli dsp set --module ProductionHardClipper --node OutputTrim --param Value --value 0.5 --agent
hise-cli dsp create_parameter --module ProductionHardClipper --container production_hard_clipper --id Drive --range "1,8" --default 4 --agent
hise-cli dsp connect --module ProductionHardClipper --source production_hard_clipper --source-param Drive --target PreGain --param Value --matched --agent
# Keep math.clip in block processing because its frame implementation has different transfer behaviour.
hise-cli dsp set --module ProductionHardClipper --node production_hard_clipper --param Comment --value '"**Block processing** - Keep math.clip out of frame containers because its single-sample implementation differs."' --agent
hise-cli dsp set --module ProductionHardClipper --node QuadRateClipper --param NodeColour --value 0xFFE67E22 --agent
hise-cli dsp set --module ProductionHardClipper --node QuadRateClipper --param Comment --value '"**Practical 4x stage** - Drive, hard clipping, and trim are oversampled while analysis remains at the host rate."' --agent
hise-cli dsp set --module ProductionHardClipper --node PreGain --param NodeColour --value 0xFF8C6D55 --agent
hise-cli dsp set --module ProductionHardClipper --node HardClip --param NodeColour --value 0xFF8C6D55 --agent
hise-cli dsp set --module ProductionHardClipper --node OutputTrim --param NodeColour --value 0xFF8C6D55 --agent
hise-cli dsp set --module ProductionHardClipper --node OutputSpectrum --param NodeColour --value 0xFF8C6D55 --agent
hise-cli dsp set --module ProductionHardClipper --node OutputSpectrum --param Folded --value true --agent
```

