---
id: container.chain.nested-macro-modulation-chain
node: container.chain
domain: scriptnode
category: dsp-network
title: "Nested Macro Modulation Chain"
summary: "A serial container that processes each child node in sequence."
useCase: "Demonstrate both serial child processing and how a container parameter can provide a clean modulation boundary for multiple parameters inside a nested `container.chain`."
difficulty: intermediate
networkName: nested_macro_chain
moduleType: ScriptFX
moduleId: NestedMacroChain
tags:
  - container
  - chain
  - routing
  - parallel-processing
aliases:
  - nested macro modulation chain
  - chain container
relatedNodes:
  - container.chain
  - container.modchain
  - core.ramp
  - core.peak
  - control.pma
  - filters.svf
  - core.gain
parameters:
  None: "None"
---

scriptnode example: container.chain

Nested Macro Modulation Chain.

Demonstrate both serial child processing and how a container parameter can provide a clean modulation boundary for multiple parameters inside a nested `container.chain`.

Graph:
```text
nested_macro_chain
  SweepControl           container.modchain
    SweepRamp            core.ramp
    SweepPeak            core.peak
  FilterAndLevel         container.chain
    Sweep                parameter
    GainInverter         control.pma
    MovingFilter         filters.svf
    OutputLevel          core.gain
```

Host:
  Module: NestedMacroChain
  Network: nested_macro_chain
  Host context: Script FX
  Required channels: default stereo; SweepControl uses an isolated mono control buffer
  Module routing: default stereo
  Master routing: default stereo
  Type: `ScriptFX`
  Builder setup: `add ScriptFX as "NestedMacroChain"`, then set its network to `nested_macro_chain`.

Support nodes:
  Required: container.modchain, core.ramp, core.peak, control.pma, filters.svf, core.gain
  `container.modchain` isolates the generated control signal from the parent audio path; `core.ramp` generates the repeating 0 to 1 sweep; `core.peak` exports that internal signal as modulation; `control.pma` creates an inverted copy without reversing the shared macro range; `filters.svf` makes the macro movement audible as a cutoff sweep; and `core.gain` provides a second nested target so the example visibly demonstrates one chain macro driving multiple children.

Key rules:
  - Before SweepControl: The modchain keeps its generated ramp out of the audible stereo path.
  - Before FilterAndLevel.Sweep: The nested macro is the modulation boundary and fans one source out to two targets.
  - Before GainInverter: Invert Sweep with PMA instead of reversing the shared macro range.
  - Before the gain connection: The PMA inversion lowers output as the filter opens.
  - Expecting click-free bypass transitions: Chain uses hard bypass - processing stops immediately with no crossfade. Stateful effects may produce clicks when abruptly bypassed or un-bypassed.

Public controls:
  - None

HISE CLI build commands:
```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id NestedMacroChain --agent
hise-cli builder set --module NestedMacroChain --network nested_macro_chain --agent

hise-cli dsp add --module NestedMacroChain --type container.modchain --id SweepControl --agent
hise-cli dsp add --module NestedMacroChain --type core.ramp --id SweepRamp --parent SweepControl --agent
hise-cli dsp add --module NestedMacroChain --type core.peak --id SweepPeak --parent SweepControl --agent
hise-cli dsp add --module NestedMacroChain --type container.chain --id FilterAndLevel --agent
hise-cli dsp add --module NestedMacroChain --type control.pma --id GainInverter --parent FilterAndLevel --agent
hise-cli dsp add --module NestedMacroChain --type filters.svf --id MovingFilter --parent FilterAndLevel --agent
hise-cli dsp add --module NestedMacroChain --type core.gain --id OutputLevel --parent FilterAndLevel --agent

hise-cli dsp set --module NestedMacroChain --node SweepRamp --param PeriodTime --range "0.1,2000" --agent
hise-cli dsp set --module NestedMacroChain --node SweepRamp --param PeriodTime --value 2000 --agent
hise-cli dsp set --module NestedMacroChain --node GainInverter --param Multiply --value -1 --agent
hise-cli dsp set --module NestedMacroChain --node GainInverter --param Add --value 1 --agent
hise-cli dsp set --module NestedMacroChain --node MovingFilter --param Smoothing --value 0.02 --agent
hise-cli dsp set --module NestedMacroChain --node MovingFilter --param Frequency --range "200,8000" --agent
hise-cli dsp set --module NestedMacroChain --node OutputLevel --param Gain --range "-12,-3" --agent

hise-cli dsp create_parameter --module NestedMacroChain --container FilterAndLevel --id Sweep --range "0,1" --default 0 --agent
hise-cli dsp connect --module NestedMacroChain --source FilterAndLevel --source-param Sweep --target MovingFilter --param Frequency --agent
hise-cli dsp connect --module NestedMacroChain --source FilterAndLevel --source-param Sweep --target GainInverter --param Value --agent
hise-cli dsp connect --module NestedMacroChain --source GainInverter --target OutputLevel --param Gain --agent
hise-cli dsp connect --module NestedMacroChain --source SweepPeak --target FilterAndLevel --param Sweep --agent

hise-cli dsp set --module NestedMacroChain --node FilterAndLevel --param NodeColour --value 0xFF2F80ED --agent
hise-cli dsp set --module NestedMacroChain --node FilterAndLevel --param Comment --value '"**Nested macro chain** - Sweep fans one normalised control value out to cutoff and inverse output level."' --agent
hise-cli dsp set --module NestedMacroChain --node SweepControl --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module NestedMacroChain --node SweepControl --param Comment --value '"The modchain generates a mono control ramp without leaking it into the audible stereo path."' --agent
hise-cli dsp set --module NestedMacroChain --node SweepPeak --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module NestedMacroChain --node GainInverter --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module NestedMacroChain --node GainInverter --param Comment --value '"Invert Sweep before gain mapping so the level falls while the filter opens."' --agent
hise-cli dsp set --module NestedMacroChain --node MovingFilter --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module NestedMacroChain --node OutputLevel --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module NestedMacroChain --node SweepRamp --param Folded --value true --agent
```

