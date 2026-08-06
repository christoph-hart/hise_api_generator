---
id: dynamics.updown_comp.ott
node: dynamics.updown_comp
domain: scriptnode
category: dsp-network
title: OTT-style multiband compressor
summary: Recreates the aggressive Ableton OTT-style effect with three calibrated bands, upward and downward compression, and a shared mix control.
useCase: Use this when you need pronounced multiband upward and downward compression with independently calibrated low, mid, and high frequency ranges.
difficulty: advanced
networkName: ott_compressor
moduleType: ScriptFX
moduleId: OTTCompressor
tags:
  - ott
  - multiband
  - upward-compression
  - downward-compression
  - dynamics
  - frequency-split
aliases:
  - OTT effect
  - Ableton OTT recreation
  - multiband upward compressor
  - aggressive multiband compressor
relatedNodes:
  - dynamics.updown_comp
  - template.freq_split3
  - template.dry_wet
  - math.mul
parameters:
  Mix: Controls all three band-local dry/wet mixers together.
  FrequencySplit.Band 1: Low/mid crossover, hardcoded to 88 Hz.
  FrequencySplit.Band 2: Mid/high crossover, hardcoded to 2500 Hz.
  LowCompressor: Calibrated low-band dual-threshold compressor settings.
  MidCompressor: Calibrated mid-band dual-threshold compressor settings.
  HighCompressor: Calibrated high-band dual-threshold compressor settings.
---

scriptnode example: dynamics.updown_comp

OTT-style multiband compressor.
Use this to recreate the characteristic aggressive OTT sound with three frequency bands. The crossover points, gain multipliers, thresholds, ratios, knee values, attack times, release times, and RMS modes are hardcoded calibrated values.

Graph:
```text
ott_compressor
  FrequencySplit      template.freq_split3
    LowBand           template.dry_wet
      LowPreGain      math.mul
      LowCompressor   dynamics.updown_comp
      LowPostGain     math.mul
    MidBand           template.dry_wet
      MidPreGain      math.mul
      MidCompressor   dynamics.updown_comp
      MidPostGain     math.mul
    HighBand          template.dry_wet
      HighPreGain     math.mul
      HighCompressor  dynamics.updown_comp
      HighPostGain    math.mul
```

Host:
  Module: `OTTCompressor`
  Type: `ScriptFX`
  Network: `ott_compressor`
  Routing: fixed stereo
  Builder setup:
    - `add ScriptFX as "OTTCompressor"`
    - `set OTTCompressor.network "ott_compressor"`

Support nodes:
  Required: `template.freq_split3`, `template.dry_wet`, `math.mul`, `dynamics.updown_comp`
  Optional: none

Key rules:
  - Use `template.freq_split3` for the two-crossover, three-band structure.
  - Use one `template.dry_wet` inside each band. The dry signal must share the crossover filters with the processed signal; a top-level dry/wet mixer would bypass the split and introduce phase/group-delay mismatch.
  - Connect one global `Mix` parameter to all three band-local `DryWet` parameters.
  - Do not round, normalize, or retune any numeric value. The hardcoded values were tested to match the reference effect.
  - Keep the network fixed stereo because `dynamics.updown_comp` only supports two channels.

Calibrated values:
  - Crossovers: `88 Hz`, `2500 Hz`.
  - Low band: pre-gain `0.69`, post-gain `2.108`; compressor `(-40.8, 3.941296815520002, -33.8, 65.06681640664662, 0.1812000017549026, 0, 305.4111685202056, RMS=1)`.
  - Mid band: pre-gain `1.834`, post-gain `1.8004609375`; compressor `(-42, 5.351868752117148, -30.3, 65.06681640664667, 0.3, 0.664653791202388, 280.8672311435491, RMS=0)`.
  - High band: pre-gain `1.81`, post-gain `3.27`; compressor `(-37.6321556848105, 4.17, -35.05200048966641, 100, 0.1175999981086471, 2.095644181214617, 122.9679758241329, RMS=0)`.

Public controls:
  - `Mix` -> `LowBand.DryWet`, `MidBand.DryWet`, and `HighBand.DryWet`, matched, `0..1`, default `1`.

HISE CLI build commands:
```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id OTTCompressor --agent
hise-cli builder set --module OTTCompressor --network ott_compressor --agent
hise-cli dsp add --module OTTCompressor --type template.freq_split3 --id FrequencySplit --agent
hise-cli dsp add --module OTTCompressor --type template.dry_wet --id LowBand --parent FrequencySplit_band1 --agent
hise-cli dsp add --module OTTCompressor --type math.mul --id LowPreGain --parent LowBand_wet_path --agent
hise-cli dsp add --module OTTCompressor --type dynamics.updown_comp --id LowCompressor --parent LowBand_wet_path --agent
hise-cli dsp add --module OTTCompressor --type math.mul --id LowPostGain --parent LowBand_wet_path --agent
hise-cli dsp add --module OTTCompressor --type template.dry_wet --id MidBand --parent FrequencySplit_band2 --agent
hise-cli dsp add --module OTTCompressor --type math.mul --id MidPreGain --parent MidBand_wet_path --agent
hise-cli dsp add --module OTTCompressor --type dynamics.updown_comp --id MidCompressor --parent MidBand_wet_path --agent
hise-cli dsp add --module OTTCompressor --type math.mul --id MidPostGain --parent MidBand_wet_path --agent
hise-cli dsp add --module OTTCompressor --type template.dry_wet --id HighBand --parent FrequencySplit_band3 --agent
hise-cli dsp add --module OTTCompressor --type math.mul --id HighPreGain --parent HighBand_wet_path --agent
hise-cli dsp add --module OTTCompressor --type dynamics.updown_comp --id HighCompressor --parent HighBand_wet_path --agent
hise-cli dsp add --module OTTCompressor --type math.mul --id HighPostGain --parent HighBand_wet_path --agent
hise-cli dsp remove --module OTTCompressor --node FrequencySplit_dummy1 --agent
hise-cli dsp remove --module OTTCompressor --node FrequencySplit_dummy2 --agent
hise-cli dsp remove --module OTTCompressor --node FrequencySplit_dummy3 --agent
hise-cli dsp remove --module OTTCompressor --node LowBand_dummy --agent
hise-cli dsp remove --module OTTCompressor --node MidBand_dummy --agent
hise-cli dsp remove --module OTTCompressor --node HighBand_dummy --agent
hise-cli dsp set --module OTTCompressor --node FrequencySplit_lr1_1 --param Frequency --value 88 --agent
hise-cli dsp set --module OTTCompressor --node FrequencySplit_lr2_1 --param Frequency --value 88 --agent
hise-cli dsp set --module OTTCompressor --node FrequencySplit_lr3_1 --param Frequency --value 88 --agent
hise-cli dsp set --module OTTCompressor --node FrequencySplit_lr1_2 --param Frequency --value 2500 --agent
hise-cli dsp set --module OTTCompressor --node FrequencySplit_lr2_2 --param Frequency --value 2500 --agent
hise-cli dsp set --module OTTCompressor --node FrequencySplit_lr3_2 --param Frequency --value 2500 --agent
hise-cli dsp set --module OTTCompressor --node LowPreGain --param Value --range "0,2" --agent
hise-cli dsp set --module OTTCompressor --node LowPostGain --param Value --range "0,6" --agent
hise-cli dsp set --module OTTCompressor --node MidPreGain --param Value --range "0,2" --agent
hise-cli dsp set --module OTTCompressor --node MidPostGain --param Value --range "0,6" --agent
hise-cli dsp set --module OTTCompressor --node HighPreGain --param Value --range "0,2" --agent
hise-cli dsp set --module OTTCompressor --node HighPostGain --param Value --range "0,6" --agent
hise-cli dsp set --module OTTCompressor --node LowPreGain --param Value --value 0.69 --agent
hise-cli dsp set --module OTTCompressor --node LowPostGain --param Value --value 2.108 --agent
hise-cli dsp set --module OTTCompressor --node MidPreGain --param Value --value 1.834 --agent
hise-cli dsp set --module OTTCompressor --node MidPostGain --param Value --value 1.8004609375 --agent
hise-cli dsp set --module OTTCompressor --node HighPreGain --param Value --value 1.81 --agent
hise-cli dsp set --module OTTCompressor --node HighPostGain --param Value --value 3.27 --agent
hise-cli dsp set --module OTTCompressor --node LowCompressor --param LowThreshold --value -40.8 --agent
hise-cli dsp set --module OTTCompressor --node LowCompressor --param LowRatio --value 3.941296815520002 --agent
hise-cli dsp set --module OTTCompressor --node LowCompressor --param HighThreshold --value -33.8 --agent
hise-cli dsp set --module OTTCompressor --node LowCompressor --param HighRatio --value 65.06681640664662 --agent
hise-cli dsp set --module OTTCompressor --node LowCompressor --param Knee --value 0.1812000017549026 --agent
hise-cli dsp set --module OTTCompressor --node LowCompressor --param Attack --value 0 --agent
hise-cli dsp set --module OTTCompressor --node LowCompressor --param Release --value 305.4111685202056 --agent
hise-cli dsp set --module OTTCompressor --node LowCompressor --param RMS --value 1 --agent
hise-cli dsp set --module OTTCompressor --node MidCompressor --param LowThreshold --value -42 --agent
hise-cli dsp set --module OTTCompressor --node MidCompressor --param LowRatio --value 5.351868752117148 --agent
hise-cli dsp set --module OTTCompressor --node MidCompressor --param HighThreshold --value -30.3 --agent
hise-cli dsp set --module OTTCompressor --node MidCompressor --param HighRatio --value 65.06681640664667 --agent
hise-cli dsp set --module OTTCompressor --node MidCompressor --param Knee --value 0.3 --agent
hise-cli dsp set --module OTTCompressor --node MidCompressor --param Attack --value 0.664653791202388 --agent
hise-cli dsp set --module OTTCompressor --node MidCompressor --param Release --value 280.8672311435491 --agent
hise-cli dsp set --module OTTCompressor --node MidCompressor --param RMS --value 0 --agent
hise-cli dsp set --module OTTCompressor --node HighCompressor --param LowThreshold --value -37.6321556848105 --agent
hise-cli dsp set --module OTTCompressor --node HighCompressor --param LowRatio --value 4.17 --agent
hise-cli dsp set --module OTTCompressor --node HighCompressor --param HighThreshold --value -35.05200048966641 --agent
hise-cli dsp set --module OTTCompressor --node HighCompressor --param HighRatio --value 100 --agent
hise-cli dsp set --module OTTCompressor --node HighCompressor --param Knee --value 0.1175999981086471 --agent
hise-cli dsp set --module OTTCompressor --node HighCompressor --param Attack --value 2.095644181214617 --agent
hise-cli dsp set --module OTTCompressor --node HighCompressor --param Release --value 122.9679758241329 --agent
hise-cli dsp set --module OTTCompressor --node HighCompressor --param RMS --value 0 --agent
hise-cli dsp create_parameter --module OTTCompressor --container ott_compressor --id Mix --range "0,1" --default 1 --agent
hise-cli dsp connect --module OTTCompressor --source ott_compressor --source-param Mix --target LowBand --param DryWet --matched --agent
hise-cli dsp connect --module OTTCompressor --source ott_compressor --source-param Mix --target MidBand --param DryWet --matched --agent
hise-cli dsp connect --module OTTCompressor --source ott_compressor --source-param Mix --target HighBand --param DryWet --matched --agent
```
