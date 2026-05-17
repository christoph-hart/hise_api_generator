---
id: dynamics.limiter.fixed-lookahead-peak-safety
node: dynamics.limiter
domain: scriptnode
category: dsp-network
title: Fixed-lookahead peak safety limiter
summary: Places dynamics.limiter after a non-linear shaper as a final peak-safety stage with fixed attack/lookahead.
useCase: Use this when you need a final limiter after distortion or shaping, and the limiter attack should stay fixed to avoid runtime latency changes.
difficulty: intermediate
networkName: safety_peak_limiter
moduleType: ScriptFX
moduleId: SafetyPeakLimiter
tags:
  - limiter
  - peak-control
  - safety-limiter
  - lookahead
  - waveshaper
  - latency
aliases:
  - peak safety limiter
  - final limiter
  - limiter after distortion
  - lookahead limiter
  - shaper peak control
relatedNodes:
  - dynamics.limiter
  - math.expr
  - core.gain
  - math.mul
parameters:
  DriveAmount: Controls DriveShaper.Value and how hard the cubic shaper feeds the limiter.
  LimitThreshold: Controls SafetyLimiter.Threshhold for final peak containment.
  LimitRelease: Controls how quickly SafetyLimiter releases after gain reduction.
  LimitRatio: Controls limiting strength; high values approach brickwall limiting.
  SafetyLimiter.Attack: Fixed at 5 ms because attack changes lookahead latency and can click at runtime.
---

scriptnode example: dynamics.limiter

Fixed-lookahead peak safety limiter.
Use this to place `dynamics.limiter` after a non-linear shaper so peaks are contained before the signal leaves the effect.

Graph:
```text
safety_peak_limiter
  DriveShaper           math.expr
  SafetyLimiter         dynamics.limiter
```

Host:
  Module: `SafetyPeakLimiter`
  Type: `ScriptFX`
  Network: `safety_peak_limiter`
  Routing: default stereo
  Builder setup:
    - `add ScriptFX as "SafetyPeakLimiter"`
    - `set SafetyPeakLimiter.network "safety_peak_limiter"`

Support nodes:
  Required: `math.expr`
  Optional: `core.gain`, `math.mul`

Key rules:
  - Put `SafetyLimiter` last so it acts as the final peak-safety stage after non-linear shaping.
  - Lock `DriveShaper.Code` to `input + value * input * input * input` for a simple cubic curve that generates peaks for the limiter to catch.
  - Setting `DriveShaper.Code` applies the compile-enabled expression setup required by `math.expr`.
  - Keep `SafetyLimiter.Attack` fixed at `5 ms`; limiter attack changes lookahead latency and can click if changed at runtime.
  - Use a high `SafetyLimiter.Ratio`; `1:1` means no gain reduction, while high values approach brickwall limiting.
  - Do not expose attack as a performance macro unless the user explicitly wants variable lookahead latency.

Public controls:
  - `DriveAmount` -> `DriveShaper.Value`, matched, `0..0.75`, default `0.5`
  - `LimitThreshold` -> `SafetyLimiter.Threshhold`, matched, `-12..-1`, default `-3`
  - `LimitRelease` -> `SafetyLimiter.Release`, matched, `20..180`, default `90`
  - `LimitRatio` -> `SafetyLimiter.Ratio`, matched, `12..32`, default `20`

HISE CLI build commands:
```bash
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id SafetyPeakLimiter --agent
hise-cli builder set --module SafetyPeakLimiter --network safety_peak_limiter --agent

hise-cli dsp add --module SafetyPeakLimiter --type math.expr --id DriveShaper --agent
hise-cli dsp add --module SafetyPeakLimiter --type dynamics.limiter --id SafetyLimiter --agent
hise-cli dsp set --module SafetyPeakLimiter --node DriveShaper --param Code --value '"input + value * input * input * input"' --agent
hise-cli dsp set --module SafetyPeakLimiter --node DriveShaper --param Value --range "0,0.75" --stepSize 0.01 --agent
hise-cli dsp set --module SafetyPeakLimiter --node DriveShaper --param Value --value 0.5 --agent
hise-cli dsp set --module SafetyPeakLimiter --node SafetyLimiter --param Attack --value 5 --agent
hise-cli dsp set --module SafetyPeakLimiter --node SafetyLimiter --param Threshhold --range "-12,-1" --stepSize 0.1 --agent
hise-cli dsp set --module SafetyPeakLimiter --node SafetyLimiter --param Threshhold --value -3 --agent
hise-cli dsp set --module SafetyPeakLimiter --node SafetyLimiter --param Release --range "20,180" --stepSize 0.1 --agent
hise-cli dsp set --module SafetyPeakLimiter --node SafetyLimiter --param Release --value 90 --agent
hise-cli dsp set --module SafetyPeakLimiter --node SafetyLimiter --param Ratio --range "12,32" --stepSize 0.1 --agent
hise-cli dsp set --module SafetyPeakLimiter --node SafetyLimiter --param Ratio --value 20 --agent

hise-cli dsp create_parameter --module SafetyPeakLimiter --container safety_peak_limiter --id DriveAmount --range "0,0.75" --default 0.5 --stepSize 0.01 --agent
hise-cli dsp create_parameter --module SafetyPeakLimiter --container safety_peak_limiter --id LimitThreshold --range "-12,-1" --default -3 --stepSize 0.1 --agent
hise-cli dsp create_parameter --module SafetyPeakLimiter --container safety_peak_limiter --id LimitRelease --range "20,180" --default 90 --stepSize 0.1 --agent
hise-cli dsp create_parameter --module SafetyPeakLimiter --container safety_peak_limiter --id LimitRatio --range "12,32" --default 20 --stepSize 0.1 --agent
hise-cli dsp connect --module SafetyPeakLimiter --source safety_peak_limiter --source-param DriveAmount --target DriveShaper --param Value --matched --agent
hise-cli dsp connect --module SafetyPeakLimiter --source safety_peak_limiter --source-param LimitThreshold --target SafetyLimiter --param Threshhold --matched --agent
hise-cli dsp connect --module SafetyPeakLimiter --source safety_peak_limiter --source-param LimitRelease --target SafetyLimiter --param Release --matched --agent
hise-cli dsp connect --module SafetyPeakLimiter --source safety_peak_limiter --source-param LimitRatio --target SafetyLimiter --param Ratio --matched --agent

hise-cli dsp set --module SafetyPeakLimiter --node DriveShaper --param NodeColour --value 0xFF8F7766 --agent
hise-cli dsp set --module SafetyPeakLimiter --node DriveShaper --param Comment --value '"DriveShaper adds cubic colour before the limiter so the safety stage has real overs to catch."' --agent
hise-cli dsp set --module SafetyPeakLimiter --node SafetyLimiter --param NodeColour --value 0xFFE67E22 --agent
hise-cli dsp set --module SafetyPeakLimiter --node SafetyLimiter --param Comment --value '"**Peak safety limiter** - Final stage catches shaper peaks. Attack is fixed because it changes lookahead latency."' --agent
```
