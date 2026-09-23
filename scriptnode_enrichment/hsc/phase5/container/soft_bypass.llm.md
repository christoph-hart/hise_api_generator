---
id: container.soft_bypass.click-free-vocal-strip-enable
node: container.soft_bypass
domain: scriptnode
category: dsp-network
title: "Click-Free Vocal Strip Enable"
summary: "A serial container with smoothed bypass crossfading to prevent clicks."
useCase: "Demonstrate the smoothed dry-to-processed transition of one `container.soft_bypass` around an entire serial effect chain."
difficulty: intermediate
networkName: click_free_vocal_strip
moduleType: ScriptFX
moduleId: ClickFreeVocalStrip
tags:
  - container
  - soft
  - bypass
aliases:
  - click-free vocal strip enable
  - soft bypass container
relatedNodes:
  - container.soft_bypass
  - filters.one_pole
  - dynamics.comp
  - math.tanh
parameters:
  StripEnable: "StripEnable -> VocalStrip.Bypass matched"
  Target: "Target range before connection: [0, 1], step 1; values below 0.5 bypass and values at or above 0.5 activate"
  Macro: "Macro range: [0, 1], step 1, labels Off, On"
  Default:: "Default: 1"
---

scriptnode example: container.soft_bypass

Click-Free Vocal Strip Enable.

Demonstrate the smoothed dry-to-processed transition of one `container.soft_bypass` around an entire serial effect chain.

Graph:
```text
click_free_vocal_strip
  VocalStrip             container.soft_bypass
    HighPass             filters.one_pole
    VocalCompressor      dynamics.comp
    SaturationDrive      math.mul
    SoftSaturation       math.tanh
```

Host:
  Module: ClickFreeVocalStrip
  Network: click_free_vocal_strip
  Type: `ScriptFX`
  Builder setup: `add ScriptFX as "ClickFreeVocalStrip"`, then set its network to `click_free_vocal_strip`.

Support nodes:
  Required: filters.one_pole, dynamics.comp, math.tanh
  Optional: math.mul
  `filters.one_pole` provides the stateful HPF that would be vulnerable to abrupt bypass; `dynamics.comp` supplies level-dependent state and a clearly processed strip sound; `math.tanh` adds bounded soft saturation; and an optional pre-gain multiplier can drive the saturator if the source level is too low to reveal it.

Key rules:
  - Modulation output not smoothed during bypass: The audio crossfade uses a linear ramp, but modulation output is cut instantly when bypass is engaged. If downstream nodes depend on modulation from inside the soft_bypass, they will see an abrupt change.
  - Series chaining produces clicks instead of smooth transitions: The double-ramp crossfade pre-multiplies the input by the ramp before processing. When two soft_bypass nodes are in series, the second node receives an already-ramped signal from the first, causing nested ramp interactions that produce clicks rather than smooth transitions.

Public controls:
  - StripEnable -> VocalStrip.Bypass matched
  - Target range before connection: [0, 1], step 1; values below 0.5 bypass and values at or above 0.5 activate
  - Macro range: [0, 1], step 1, labels Off, On
  - Default: 1

HISE CLI build commands:
```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id ClickFreeVocalStrip --agent
hise-cli builder set --module ClickFreeVocalStrip --network click_free_vocal_strip --agent

# Use one wrapper around the complete serial strip. Series-chained soft bypass containers can click.
hise-cli dsp add --module ClickFreeVocalStrip --type container.soft_bypass --id VocalStrip --agent
hise-cli dsp add --module ClickFreeVocalStrip --type filters.one_pole --id HighPass --parent VocalStrip --agent
hise-cli dsp add --module ClickFreeVocalStrip --type dynamics.comp --id VocalCompressor --parent VocalStrip --agent
hise-cli dsp add --module ClickFreeVocalStrip --type math.mul --id SaturationDrive --parent VocalStrip --agent
hise-cli dsp add --module ClickFreeVocalStrip --type math.tanh --id SoftSaturation --parent VocalStrip --agent

hise-cli dsp set --module ClickFreeVocalStrip --node VocalStrip --param SmoothingTime --value 40 --agent
hise-cli dsp set --module ClickFreeVocalStrip --node HighPass --param Mode --value 1 --agent
hise-cli dsp set --module ClickFreeVocalStrip --node HighPass --param Frequency --value 90 --agent
hise-cli dsp set --module ClickFreeVocalStrip --node HighPass --param Smoothing --value 0.02 --agent
hise-cli dsp set --module ClickFreeVocalStrip --node VocalCompressor --param Threshhold --value -18 --agent
hise-cli dsp set --module ClickFreeVocalStrip --node VocalCompressor --param Ratio --value 3 --agent
hise-cli dsp set --module ClickFreeVocalStrip --node VocalCompressor --param Attack --value 15 --agent
hise-cli dsp set --module ClickFreeVocalStrip --node VocalCompressor --param Release --value 120 --agent
hise-cli dsp set --module ClickFreeVocalStrip --node SaturationDrive --param Value --range "0,2" --stepSize 0 --agent
hise-cli dsp set --module ClickFreeVocalStrip --node SaturationDrive --param Value --value 1.5 --agent

hise-cli dsp create_parameter --module ClickFreeVocalStrip --container click_free_vocal_strip --id StripEnable --range "0,1" --default 1 --stepSize 1 --agent
# Bypass is a special power-button target, so matched range metadata is intentionally ignored.
hise-cli dsp connect --module ClickFreeVocalStrip --source click_free_vocal_strip --source-param StripEnable --target VocalStrip --param Bypass --matched --agent
# Do not enable ShowParameters: the bypass cable is already visible at the power button.

hise-cli dsp set --module ClickFreeVocalStrip --node VocalStrip --param NodeColour --value 0xFF27AE60 --agent
hise-cli dsp set --module ClickFreeVocalStrip --node VocalStrip --param Comment --value '"One smoothed wrapper crossfades the complete serial strip over 40 ms; do not series-chain soft bypass containers."' --agent
hise-cli dsp set --module ClickFreeVocalStrip --node HighPass --param NodeColour --value 0xFF668A73 --agent
hise-cli dsp set --module ClickFreeVocalStrip --node VocalCompressor --param NodeColour --value 0xFF668A73 --agent
hise-cli dsp set --module ClickFreeVocalStrip --node SoftSaturation --param NodeColour --value 0xFF668A73 --agent
hise-cli dsp set --module ClickFreeVocalStrip --node SoftSaturation --param Comment --value '"The active strip applies high-pass filtering, compression, 1.5x drive, and soft saturation."' --agent
hise-cli dsp set --module ClickFreeVocalStrip --node click_free_vocal_strip --param Comment --value '"StripEnable 0 bypasses and 1 activates processing. Audio crossfades over SmoothingTime, but child modulation outputs stop immediately on bypass."' --agent
hise-cli dsp set --module ClickFreeVocalStrip --node SaturationDrive --param Folded --value true --agent
```

