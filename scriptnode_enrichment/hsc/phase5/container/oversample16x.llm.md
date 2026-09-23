---
id: container.oversample16x.extreme-foldback-stress-test
node: container.oversample16x
domain: scriptnode
category: dsp-network
title: "Extreme Foldback Stress Test"
summary: "Upsamples the audio signal by the maximum fixed factor of 16, processes child nodes at the higher rate, then downsamples back."
useCase: "Demonstrate that `container.oversample16x` is a last-resort quality setting for extreme nonlinear spectra, not a default wrapper for ordinary distortion."
difficulty: advanced
networkName: extreme_foldback_stress_test
moduleType: ScriptFX
moduleId: ExtremeFoldbackStressTest
tags:
  - container
  - oversample16x
aliases:
  - extreme foldback stress test
  - oversample16x container
relatedNodes:
  - container.oversample16x
  - math.expr
parameters:
  Stress: "Stress -> NestedSineStress.Value matched"
  Target: "Target range before connection: [0, 1]"
  Macro: "Macro range: [0, 1]"
  Default:: "Default: 0.7"
---

scriptnode example: container.oversample16x

Extreme Foldback Stress Test.

Demonstrate that `container.oversample16x` is a last-resort quality setting for extreme nonlinear spectra, not a default wrapper for ordinary distortion.

Graph:
```text
extreme_foldback_stress_test
  SixteenRateStress      container.oversample16x
    NestedSineStress     math.expr
  OutputSpectrum         analyse.fft
```

Host:
  Module: ExtremeFoldbackStressTest
  Network: extreme_foldback_stress_test
  Type: `ScriptFX`
  Builder setup: `add ScriptFX as "ExtremeFoldbackStressTest"`, then set its network to `extreme_foldback_stress_test`.

Support nodes:
  Required: math.expr
  Optional: analyse.fft
  `math.expr` supplies a controllable nested-sine transfer function with more severe high-order content than ordinary clipping, while an optional post-container FFT provides the spectral evidence needed to justify or reject the 16x factor.

Key rules:
  - Oversample only the pathological nonlinear expression.
  - Treat 16x as a diagnostic upper bound.
  - Compare matched 4x, 8x, and 16x captures rather than using bypass as the only quality comparison.
  - Bypass is the 1x baseline and keeps the expression active.
  - Extreme CPU cost - verify 16x is necessary: 16x oversampling multiplies the CPU cost of all child nodes by 16. At 44.1 kHz, children process at 705.6 kHz. In most cases, 4x or 8x oversampling provides sufficient aliasing reduction at a fraction of the cost.
  - Nesting oversample containers is not allowed: The container checks that the incoming sample rate matches the network's original sample rate. If the signal has already been upsampled, this check fails and the node reports an error.
  - Cannot be used in polyphonic networks: Oversampling is restricted to monophonic processing. If the container detects a polyphonic voice context, it reports an error.

Public controls:
  - Stress -> NestedSineStress.Value matched
  - Target range before connection: [0, 1]
  - Macro range: [0, 1]
  - Default: 0.7

HISE CLI build commands:
```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id ExtremeFoldbackStressTest --agent
hise-cli builder set --module ExtremeFoldbackStressTest --network extreme_foldback_stress_test --agent
# Only the pathological nonlinear stage receives the sixteenfold CPU multiplier.
hise-cli dsp add --module ExtremeFoldbackStressTest --type container.oversample16x --id SixteenRateStress --agent
hise-cli dsp add --module ExtremeFoldbackStressTest --type math.expr --id NestedSineStress --parent SixteenRateStress --agent
hise-cli dsp set --module ExtremeFoldbackStressTest --node NestedSineStress --param Code --value '"Math.sin(Math.sin(input * (1.0f + value * 12.0f)) * 8.0f)"' --agent
hise-cli dsp set --module ExtremeFoldbackStressTest --node NestedSineStress --param Value --value 0.7 --agent
hise-cli dsp add --module ExtremeFoldbackStressTest --type analyse.fft --id OutputSpectrum --agent
hise-cli dsp create_parameter --module ExtremeFoldbackStressTest --container extreme_foldback_stress_test --id Stress --range "0,1" --default 0.7 --agent
hise-cli dsp connect --module ExtremeFoldbackStressTest --source extreme_foldback_stress_test --source-param Stress --target NestedSineStress --param Value --matched --agent
# Treat 16x as a diagnostic upper bound and compare it against matched 4x and 8x captures.
hise-cli dsp set --module ExtremeFoldbackStressTest --node extreme_foldback_stress_test --param Comment --value '"**16x diagnostic** - Reserve this factor for cases where matched 4x and 8x comparisons still leave audible aliasing."' --agent
hise-cli dsp set --module ExtremeFoldbackStressTest --node SixteenRateStress --param NodeColour --value 0xFFE74C3C --agent
hise-cli dsp set --module ExtremeFoldbackStressTest --node SixteenRateStress --param Comment --value '"**Extreme CPU cost** - Only the nested sine stress stage runs at sixteen times the host rate."' --agent
hise-cli dsp set --module ExtremeFoldbackStressTest --node NestedSineStress --param NodeColour --value 0xFF965E58 --agent
hise-cli dsp set --module ExtremeFoldbackStressTest --node OutputSpectrum --param NodeColour --value 0xFF965E58 --agent
hise-cli dsp set --module ExtremeFoldbackStressTest --node OutputSpectrum --param Folded --value true --agent
```

