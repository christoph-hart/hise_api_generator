---
id: container.sidechain.internally-keyed-pumping-compressor
node: container.sidechain
domain: scriptnode
category: dsp-network
title: "Internally Keyed Pumping Compressor"
summary: "A serial container that doubles the channel count by adding empty sidechain channels."
useCase: "Demonstrate that `container.sidechain` creates zeroed auxiliary channels which must be filled explicitly before a child processor can use them as a detector input."
difficulty: advanced
networkName: internally_keyed_pumping_compressor
moduleType: ScriptFX
moduleId: InternallyKeyedPumpingCompressor
tags:
  - container
  - sidechain
  - dynamics
aliases:
  - internally keyed pumping compressor
  - sidechain container
relatedNodes:
  - container.sidechain
  - container.multi
  - container.no_midi
  - core.oscillator
  - dynamics.comp
parameters:
  PumpRate: "PumpRate -> PumpOscillator.Frequency matched"
  Target: "Target range before connection: [0.5, 8]"
  Macro: "Macro range: [0.5, 8]"
  Default:: "Default: 2"
---

scriptnode example: container.sidechain

Internally Keyed Pumping Compressor.

Demonstrate that `container.sidechain` creates zeroed auxiliary channels which must be filled explicitly before a child processor can use them as a detector input.

Graph:
```text
internally_keyed_pumping_compressor
  InternalSidechain      container.sidechain
    FourChannelSlices    container.multi
      MainStereo         container.chain
      KeyStereo          container.no_midi
        PumpOscillator   core.oscillator
    PumpCompressor       dynamics.comp
```

Host:
  Module: InternallyKeyedPumpingCompressor
  Network: internally_keyed_pumping_compressor
  Type: `ScriptFX`
  Builder setup: `add ScriptFX as "InternallyKeyedPumpingCompressor"`, then set its network to `internally_keyed_pumping_compressor`.

Support nodes:
  Required: container.multi, container.no_midi, core.oscillator, dynamics.comp
  `container.multi` divides the expanded four-channel buffer into a passthrough main stereo slice and a key-generator stereo slice; `container.no_midi` prevents notes from retuning the fixed key source; `core.oscillator` writes the periodic signal into channels 2-3; and `dynamics.comp` reads those channels in Sidechain mode while applying gain reduction only to channels 0-1.

Key rules:
  - Forgetting to route into sidechain channels: The extra channels created by the sidechain container are zeroed by default. Without routing a signal into them, sidechain-enabled processors detect silence and have no effect.
  - Not enabling all channels on the Script FX wrapper: The Script FX module must also have its channel count set to match the master container. Otherwise the extra sidechain channels are not passed through to the network.

Public controls:
  - PumpRate -> PumpOscillator.Frequency matched
  - Target range before connection: [0.5, 8]
  - Macro range: [0.5, 8]
  - Default: 2

HISE CLI build commands:
```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id InternallyKeyedPumpingCompressor --agent
hise-cli builder set --module InternallyKeyedPumpingCompressor --network internally_keyed_pumping_compressor --agent

# sidechain appends a zeroed auxiliary pair internally; it is not a DAW sidechain input.
hise-cli dsp add --module InternallyKeyedPumpingCompressor --type container.sidechain --id InternalSidechain --agent
hise-cli dsp add --module InternallyKeyedPumpingCompressor --type container.multi --id FourChannelSlices --parent InternalSidechain --agent
# The first stereo slice intentionally passes the program signal unchanged.
hise-cli dsp add --module InternallyKeyedPumpingCompressor --type container.chain --id MainStereo --parent FourChannelSlices --agent
# The second stereo slice fills the initially silent auxiliary channels.
hise-cli dsp add --module InternallyKeyedPumpingCompressor --type container.no_midi --id KeyStereo --parent FourChannelSlices --agent
hise-cli dsp add --module InternallyKeyedPumpingCompressor --type core.oscillator --id PumpOscillator --parent KeyStereo --agent
hise-cli dsp add --module InternallyKeyedPumpingCompressor --type dynamics.comp --id PumpCompressor --parent InternalSidechain --agent

hise-cli dsp set --module InternallyKeyedPumpingCompressor --node PumpOscillator --param Frequency --range "0.5,8" --stepSize 0 --agent
hise-cli dsp set --module InternallyKeyedPumpingCompressor --node PumpOscillator --param Frequency --value 2 --agent
hise-cli dsp set --module InternallyKeyedPumpingCompressor --node PumpCompressor --param Sidechain --value 2 --agent
hise-cli dsp set --module InternallyKeyedPumpingCompressor --node PumpCompressor --param Threshhold --value -24 --agent
hise-cli dsp set --module InternallyKeyedPumpingCompressor --node PumpCompressor --param Ratio --value 8 --agent
hise-cli dsp set --module InternallyKeyedPumpingCompressor --node PumpCompressor --param Attack --value 5 --agent
hise-cli dsp set --module InternallyKeyedPumpingCompressor --node PumpCompressor --param Release --value 180 --agent
hise-cli dsp create_parameter --module InternallyKeyedPumpingCompressor --container internally_keyed_pumping_compressor --id PumpRate --range "0.5,8" --default 2 --agent
hise-cli dsp connect --module InternallyKeyedPumpingCompressor --source internally_keyed_pumping_compressor --source-param PumpRate --target PumpOscillator --param Frequency --matched --agent

hise-cli dsp set --module InternallyKeyedPumpingCompressor --node InternalSidechain --param NodeColour --value 0xFFE67E22 --agent
hise-cli dsp set --module InternallyKeyedPumpingCompressor --node InternalSidechain --param Comment --value '"Appends a zeroed stereo auxiliary pair internally; this is not a DAW sidechain input, and only channels 0-1 leave the container."' --agent
hise-cli dsp set --module InternallyKeyedPumpingCompressor --node FourChannelSlices --param NodeColour --value 0xFF8C6D55 --agent
hise-cli dsp set --module InternallyKeyedPumpingCompressor --node FourChannelSlices --param Comment --value '"The first child receives main channels 0-1; the second receives auxiliary channels 2-3."' --agent
hise-cli dsp set --module InternallyKeyedPumpingCompressor --node MainStereo --param Comment --value '"Intentionally empty so the original stereo pair reaches PumpCompressor unchanged."' --agent
hise-cli dsp set --module InternallyKeyedPumpingCompressor --node KeyStereo --param NodeColour --value 0xFF8C6D55 --agent
hise-cli dsp set --module InternallyKeyedPumpingCompressor --node KeyStereo --param Comment --value '"Generates the internal stereo key and blocks MIDI so notes cannot retune it."' --agent
hise-cli dsp set --module InternallyKeyedPumpingCompressor --node PumpOscillator --param NodeColour --value 0xFF8C6D55 --agent
hise-cli dsp set --module InternallyKeyedPumpingCompressor --node PumpCompressor --param NodeColour --value 0xFF8C6D55 --agent
hise-cli dsp set --module InternallyKeyedPumpingCompressor --node PumpCompressor --param Comment --value '"Sidechain mode detects channels 2-3 while applying gain reduction only to channels 0-1."' --agent
hise-cli dsp set --module InternallyKeyedPumpingCompressor --node MainStereo --param Folded --value true --agent
```

