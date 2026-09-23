---
id: container.modchain.control-rate-oscillator-vibrato
node: container.modchain
domain: scriptnode
category: dsp-network
title: "Control-Rate Oscillator Vibrato"
summary: "A serial container that processes children at control rate without affecting the parent audio signal."
useCase: "Demonstrate that `container.modchain` processes a separate mono control buffer and leaves parent audio unchanged while a child node exports modulation to an audio-path target."
difficulty: intermediate
networkName: control_rate_oscillator_vibrato
moduleType: ScriptFX
moduleId: ControlRateOscillatorVibrato
tags:
  - container
  - modchain
aliases:
  - control-rate oscillator vibrato
  - modchain container
relatedNodes:
  - container.modchain
  - container.fix32_block
  - core.ramp
  - math.pi
  - math.sin
  - math.sig2mod
  - core.peak
  - core.oscillator
parameters:
  Rate: "Rate -> LfoRamp.PeriodTime matched"
  Target: "Target range before connection: [100, 2000]"
  Macro: "Macro range: [100, 2000]"
  Default:: "Default: 500"
---

scriptnode example: container.modchain

Control-Rate Oscillator Vibrato.

Demonstrate that `container.modchain` processes a separate mono control buffer and leaves parent audio unchanged while a child node exports modulation to an audio-path target.

Graph:
```text
control_rate_oscillator_vibrato
  Resolution32           container.fix32_block
    VibratoControl       container.modchain
      LfoRamp            core.ramp
      FullCycle          math.pi
      SineShape          math.sin
      Normalise          math.sig2mod
      VibratoPeak        core.peak
    SawTone              core.oscillator
```

Host:
  Module: ControlRateOscillatorVibrato
  Network: control_rate_oscillator_vibrato
  Type: `ScriptFX`
  Builder setup: `add ScriptFX as "ControlRateOscillatorVibrato"`, then set its network to `control_rate_oscillator_vibrato`.

Support nodes:
  Required: container.fix32_block, core.ramp, math.pi, math.sin, math.sig2mod, core.peak, core.oscillator
  `core.ramp` establishes the LFO period; `math.pi` converts its 0 to 1 cycle into radians; `math.sin` creates bipolar sine motion; `math.sig2mod` maps that motion to 0 to 1; `core.peak` exports the resulting block value as modulation; and `core.oscillator` generates the MIDI-pitched saw whose frequency ratio reveals the vibrato.

Key rules:
  - Expecting modchain to modify audio: Modchain does not modify the parent audio signal. It processes a separate internal control buffer at reduced rate. Nodes inside it should generate modulation output via cables, not process audio.
  - Orphan modulation connections after deleting nodes: When a node that modulates another node is deleted, the connection can persist on the target node, preventing it from working normally. The symptom is a parameter that no longer responds as expected.
  - Setting parameter range on source only: Modulation connections require ranges defined on both ends. Use Shift-click on the min/max fields in the range editor to set values. Setting min greater than max inverts the modulation curve.

Public controls:
  - Rate -> LfoRamp.PeriodTime matched
  - Target range before connection: [100, 2000]
  - Macro range: [100, 2000]
  - Default: 500

HISE CLI build commands:
```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id ControlRateOscillatorVibrato --agent
hise-cli builder set --module ControlRateOscillatorVibrato --network control_rate_oscillator_vibrato --agent

# A fixed 32-sample wrapper increases updates from once per host block to every 32 audio samples.
hise-cli dsp add --module ControlRateOscillatorVibrato --type container.fix32_block --id Resolution32 --agent
hise-cli dsp add --module ControlRateOscillatorVibrato --type container.modchain --id VibratoControl --parent Resolution32 --agent
hise-cli dsp add --module ControlRateOscillatorVibrato --type core.ramp --id LfoRamp --parent VibratoControl --agent
hise-cli dsp add --module ControlRateOscillatorVibrato --type math.pi --id FullCycle --parent VibratoControl --agent
hise-cli dsp add --module ControlRateOscillatorVibrato --type math.sin --id SineShape --parent VibratoControl --agent
# Convert bipolar sine to 0..1 before peak, avoiding zero-crossing folding.
hise-cli dsp add --module ControlRateOscillatorVibrato --type math.sig2mod --id Normalise --parent VibratoControl --agent
hise-cli dsp add --module ControlRateOscillatorVibrato --type core.peak --id VibratoPeak --parent VibratoControl --agent
hise-cli dsp add --module ControlRateOscillatorVibrato --type core.oscillator --id SawTone --parent Resolution32 --agent

hise-cli dsp set --module ControlRateOscillatorVibrato --node LfoRamp --param PeriodTime --range "100,2000" --agent
hise-cli dsp set --module ControlRateOscillatorVibrato --node LfoRamp --param PeriodTime --value 500 --agent
hise-cli dsp set --module ControlRateOscillatorVibrato --node FullCycle --param Value --range "0,2" --agent
hise-cli dsp set --module ControlRateOscillatorVibrato --node FullCycle --param Value --value 2 --agent
hise-cli dsp set --module ControlRateOscillatorVibrato --node SawTone --param Mode --value 2 --agent
# The stock oscillator ratio step is integer. Set step size zero before applying subtle modulation.
hise-cli dsp set --module ControlRateOscillatorVibrato --node SawTone --param 'Freq Ratio' --range "0.98,1.02" --stepSize 0 --middlePosition 1 --agent

hise-cli dsp create_parameter --module ControlRateOscillatorVibrato --container control_rate_oscillator_vibrato --id Rate --range "100,2000" --default 500 --agent
hise-cli dsp connect --module ControlRateOscillatorVibrato --source control_rate_oscillator_vibrato --source-param Rate --target LfoRamp --param PeriodTime --matched --agent
hise-cli dsp connect --module ControlRateOscillatorVibrato --source VibratoPeak --target SawTone --param 'Freq Ratio' --agent

hise-cli dsp set --module ControlRateOscillatorVibrato --node Resolution32 --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module ControlRateOscillatorVibrato --node Resolution32 --param Comment --value '"Constrains source and target to 32-sample blocks, so vibrato updates every 32 audio samples instead of once per host block."' --agent
hise-cli dsp set --module ControlRateOscillatorVibrato --node VibratoControl --param NodeColour --value 0xFF8E44AD --agent
hise-cli dsp set --module ControlRateOscillatorVibrato --node VibratoControl --param Comment --value '"Processes an isolated mono control buffer at one eighth of the parent sample rate and does not enter the stereo audio path."' --agent
hise-cli dsp set --module ControlRateOscillatorVibrato --node LfoRamp --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module ControlRateOscillatorVibrato --node LfoRamp --param Comment --value '"PeriodTime is the full vibrato cycle in milliseconds."' --agent
hise-cli dsp set --module ControlRateOscillatorVibrato --node Normalise --param Comment --value '"Convert the bipolar sine to 0..1 before peak extraction so the negative half-cycle is not folded."' --agent
hise-cli dsp set --module ControlRateOscillatorVibrato --node VibratoPeak --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module ControlRateOscillatorVibrato --node VibratoPeak --param Comment --value '"Exports the normalized control buffer into SawTone Freq Ratio range 0.98..1.02."' --agent
hise-cli dsp set --module ControlRateOscillatorVibrato --node SawTone --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module ControlRateOscillatorVibrato --node SawTone --param Comment --value '"Freq Ratio uses a continuous fractional range; step size must be zero or the subtle vibrato is quantized away."' --agent
hise-cli dsp set --module ControlRateOscillatorVibrato --node FullCycle --param Folded --value true --agent
hise-cli dsp set --module ControlRateOscillatorVibrato --node SineShape --param Folded --value true --agent
hise-cli dsp set --module ControlRateOscillatorVibrato --node Normalise --param Folded --value true --agent
```

