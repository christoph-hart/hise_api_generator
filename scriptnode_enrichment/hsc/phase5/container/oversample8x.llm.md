---
id: container.oversample8x.aggressive-sine-fold-distortion
node: container.oversample8x
domain: scriptnode
category: dsp-network
title: "Aggressive Sine-Fold Distortion"
summary: "Upsamples the audio signal by a fixed factor of 8, processes child nodes at the higher rate, then downsamples back."
useCase: "Demonstrate when the stronger alias reduction of `container.oversample8x` is justified over the more typical 4x factor."
difficulty: advanced
networkName: aggressive_sine_fold_distortion
moduleType: ScriptFX
moduleId: AggressiveSineFoldDistortion
tags:
  - container
  - oversample8x
aliases:
  - aggressive sine-fold distortion
  - oversample8x container
relatedNodes:
  - container.oversample8x
  - math.expr
parameters:
  Fold: "Fold -> SineFolder.Value matched"
  Target: "Target range before connection: [0, 1]"
  Macro: "Macro range: [0, 1]"
  Default:: "Default: 0.65"
---

scriptnode example: container.oversample8x

Aggressive Sine-Fold Distortion.

Demonstrate when the stronger alias reduction of `container.oversample8x` is justified over the more typical 4x factor.

Graph:
```text
aggressive_sine_fold_distortion
  EightRateFolder        container.oversample8x
    SineFolder           math.expr
  OutputSpectrum         analyse.fft
```

Host:
  Module: AggressiveSineFoldDistortion
  Network: aggressive_sine_fold_distortion
  Type: `ScriptFX`
  Builder setup: `add ScriptFX as "AggressiveSineFoldDistortion"`, then set its network to `aggressive_sine_fold_distortion`.

Support nodes:
  Required: math.expr
  Optional: analyse.fft
  `math.expr` implements the repeated sine-folding curve responsible for severe alias generation, while an optional post-container FFT makes spectral foldback and the benefit of 8x processing directly comparable.

Key rules:
  - Oversample only the nonlinear expression.
  - Compare 8x against 4x before accepting the CPU cost.
  - Bypass is a 1x processing comparison, not silence.
  - Avoid an uncompensated parallel dry branch.
  - Nesting oversample containers is not allowed: The container checks that the incoming sample rate matches the network's original sample rate. If the signal has already been upsampled, this check fails and the node reports an error.
  - Cannot be used in polyphonic networks: Oversampling is restricted to monophonic processing. If the container detects a polyphonic voice context, it reports an error.

Public controls:
  - Fold -> SineFolder.Value matched
  - Target range before connection: [0, 1]
  - Macro range: [0, 1]
  - Default: 0.65

HISE CLI build commands:
```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id AggressiveSineFoldDistortion --agent
hise-cli builder set --module AggressiveSineFoldDistortion --network aggressive_sine_fold_distortion --agent
# Only the severe nonlinear stage receives the eightfold CPU multiplier.
hise-cli dsp add --module AggressiveSineFoldDistortion --type container.oversample8x --id EightRateFolder --agent
hise-cli dsp add --module AggressiveSineFoldDistortion --type math.expr --id SineFolder --parent EightRateFolder --agent
hise-cli dsp set --module AggressiveSineFoldDistortion --node SineFolder --param Code --value '"Math.sin(input * (1.0f + value * 14.0f))"' --agent
hise-cli dsp set --module AggressiveSineFoldDistortion --node SineFolder --param Value --value 0.65 --agent
hise-cli dsp add --module AggressiveSineFoldDistortion --type analyse.fft --id OutputSpectrum --agent
hise-cli dsp create_parameter --module AggressiveSineFoldDistortion --container aggressive_sine_fold_distortion --id Fold --range "0,1" --default 0.65 --agent
hise-cli dsp connect --module AggressiveSineFoldDistortion --source aggressive_sine_fold_distortion --source-param Fold --target SineFolder --param Value --matched --agent
# Compare its spectrum and CPU against 4x before selecting this fixed factor.
hise-cli dsp set --module AggressiveSineFoldDistortion --node aggressive_sine_fold_distortion --param Comment --value '"**Quality check** - Compare against 4x before accepting the eightfold child CPU cost."' --agent
hise-cli dsp set --module AggressiveSineFoldDistortion --node EightRateFolder --param NodeColour --value 0xFFE67E22 --agent
hise-cli dsp set --module AggressiveSineFoldDistortion --node EightRateFolder --param Comment --value '"**Severe nonlinearity only** - The sine folder is oversampled while spectrum analysis stays at the host rate."' --agent
hise-cli dsp set --module AggressiveSineFoldDistortion --node SineFolder --param NodeColour --value 0xFF8C6D55 --agent
hise-cli dsp set --module AggressiveSineFoldDistortion --node OutputSpectrum --param NodeColour --value 0xFF8C6D55 --agent
hise-cli dsp set --module AggressiveSineFoldDistortion --node OutputSpectrum --param Folded --value true --agent
```

