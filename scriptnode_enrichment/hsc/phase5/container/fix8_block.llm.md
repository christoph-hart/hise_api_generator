---
id: container.fix8_block.event-raster-vibrato
node: container.fix8_block
domain: scriptnode
category: dsp-network
title: "Event-Raster Vibrato"
summary: "Splits the audio buffer into chunks of 8 samples for higher modulation update rates."
useCase: "Demonstrate that `container.fix8_block` provides the highest precision in the fixed-block family and is appropriate when subtle pitch modulation should update at event-raster resolution without per-sample frame processing."
difficulty: beginner
networkName: event_raster_vibrato
moduleType: ScriptFX
moduleId: EventRasterVibrato
tags:
  - container
  - fix8
  - block
  - block-size
  - processing-context
aliases:
  - event-raster vibrato
  - fix8 block container
relatedNodes:
  - container.fix8_block
  - container.modchain
  - container.no_midi
  - core.oscillator
  - math.sig2mod
  - core.peak
  - control.bipolar
parameters:
  Intensity: "Intensity -> VibratoDepth.Scale matched"
  Target: "Target range before connection: [0, 1]"
  Macro: "Macro range: [0, 1]"
  Default:: "Default: 1.0"
---

scriptnode example: container.fix8_block

Event-Raster Vibrato.

Demonstrate that `container.fix8_block` provides the highest precision in the fixed-block family and is appropriate when subtle pitch modulation should update at event-raster resolution without per-sample frame processing.

Graph:
```text
event_raster_vibrato
  EightSampleVibrato    container.fix8_block
    VibratoControl      container.modchain
      MidiIsolation     container.no_midi
        TriangleLfo     core.oscillator
        NormaliseLfo    math.sig2mod
        LfoValue        core.peak
      VibratoDepth      control.bipolar
    AudibleTone         core.oscillator
```

Host:
  Module: EventRasterVibrato
  Network: event_raster_vibrato
  Host context: Script FX
  Required channels: default stereo; isolated mono modulation path
  Module routing: default stereo
  Master routing: default stereo
  Type: `ScriptFX`
  Builder setup: `add ScriptFX as "EventRasterVibrato"`, then set its network to `event_raster_vibrato`.

Support nodes:
  Required: container.modchain, container.no_midi, core.oscillator, math.sig2mod, core.peak, control.bipolar
  `container.modchain` isolates the LFO from the audible path; `container.no_midi` prevents played notes from retuning the fixed-rate LFO; the triangle `core.oscillator` generates bipolar modulation; `math.sig2mod` converts it to 0 to 1; `core.peak` exports one value per child chunk; `control.bipolar` scales excursion around the neutral midpoint without shifting pitch; and the audible sine `core.oscillator` exposes stepped-pitch sidebands clearly because no saw harmonics mask them.

Key rules:
  - Before EightSampleVibrato: Eight samples mirrors HISE_EVENT_RASTER and is a maximum chunk size.
  - Before MidiIsolation: MIDI must not retune the fixed-rate triangle LFO.
  - Before the ratio range: Reciprocal ratio bounds create musically symmetric plus or minus 20-cent excursion.
  - Before AudibleTone: Sine mode exposes zipper sidebands that saw harmonics mask.
  - Before matching Intensity: Narrow VibratoDepth.Scale first because matching can copy the target range back to the root parameter.
  - Wrapping nodes that do not benefit: Block subdivision adds per-chunk call overhead. Nodes that are not modulated gain nothing from a smaller block size. Keep unmodulated processing outside the container.

Public controls:
  - Intensity -> VibratoDepth.Scale matched
  - Target range before connection: [0, 1]
  - Macro range: [0, 1]
  - Default: 1.0

HISE CLI build commands:
```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id EventRasterVibrato --agent
hise-cli builder set --module EventRasterVibrato --network event_raster_vibrato --agent

# Eight samples mirrors HISE_EVENT_RASTER and is the maximum child chunk size; a final remainder can be shorter.
hise-cli dsp add --module EventRasterVibrato --type container.fix8_block --id EightSampleVibrato --agent
hise-cli dsp add --module EventRasterVibrato --type container.modchain --id VibratoControl --parent EightSampleVibrato --agent
# MIDI isolation prevents played notes from retuning the fixed-rate LFO.
hise-cli dsp add --module EventRasterVibrato --type container.no_midi --id MidiIsolation --parent VibratoControl --agent
hise-cli dsp add --module EventRasterVibrato --type core.oscillator --id TriangleLfo --parent MidiIsolation --agent
hise-cli dsp add --module EventRasterVibrato --type math.sig2mod --id NormaliseLfo --parent MidiIsolation --agent
hise-cli dsp add --module EventRasterVibrato --type core.peak --id LfoValue --parent MidiIsolation --agent
hise-cli dsp add --module EventRasterVibrato --type control.bipolar --id VibratoDepth --parent VibratoControl --agent
# Sine mode reveals subtle stepped-pitch sidebands that saw harmonics would mask.
hise-cli dsp add --module EventRasterVibrato --type core.oscillator --id AudibleTone --parent EightSampleVibrato --agent

hise-cli dsp set --module EventRasterVibrato --node TriangleLfo --param Mode --value 2 --agent
hise-cli dsp set --module EventRasterVibrato --node TriangleLfo --param Frequency --range "0.5,8" --agent
hise-cli dsp set --module EventRasterVibrato --node TriangleLfo --param Frequency --value 5 --agent
hise-cli dsp set --module EventRasterVibrato --node AudibleTone --param Mode --value 0 --agent
hise-cli dsp set --module EventRasterVibrato --node AudibleTone --param Frequency --value 220 --agent
hise-cli dsp set --module EventRasterVibrato --node AudibleTone --param Gain --value 0.125 --agent
# Reciprocal frequency-ratio bounds create symmetric plus or minus 20-cent pitch excursion.
hise-cli dsp set --module EventRasterVibrato --node AudibleTone --param 'Freq Ratio' --range "0.9885140204,1.0116194403" --middlePosition 1 --agent

hise-cli dsp connect --module EventRasterVibrato --source LfoValue --target VibratoDepth --param Value --agent
hise-cli dsp connect --module EventRasterVibrato --source VibratoDepth --target AudibleTone --param 'Freq Ratio' --agent

# Set the Scale target range before matching. A matched connection can copy the target range back to the root parameter.
hise-cli dsp set --module EventRasterVibrato --node VibratoDepth --param Scale --range "0,1" --agent
hise-cli dsp create_parameter --module EventRasterVibrato --container event_raster_vibrato --id Intensity --range "0,1" --default 1 --agent
hise-cli dsp connect --module EventRasterVibrato --source event_raster_vibrato --source-param Intensity --target VibratoDepth --param Scale --matched --agent

hise-cli dsp set --module EventRasterVibrato --node EightSampleVibrato --param NodeColour --value 0xFF2F80ED --agent
hise-cli dsp set --module EventRasterVibrato --node EightSampleVibrato --param Comment --value '"**Event-raster vibrato** - Eight-sample chunks mirror HISE_EVENT_RASTER for high-resolution pitch modulation."' --agent
hise-cli dsp set --module EventRasterVibrato --node VibratoControl --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module EventRasterVibrato --node MidiIsolation --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module EventRasterVibrato --node MidiIsolation --param Comment --value '"Blocks MIDI from retuning the fixed-rate triangle LFO."' --agent
hise-cli dsp set --module EventRasterVibrato --node TriangleLfo --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module EventRasterVibrato --node NormaliseLfo --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module EventRasterVibrato --node LfoValue --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module EventRasterVibrato --node VibratoDepth --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module EventRasterVibrato --node VibratoDepth --param Comment --value '"Set Scale to 0..1 before matching Intensity; matched connections can copy the target range back to the root parameter."' --agent
hise-cli dsp set --module EventRasterVibrato --node AudibleTone --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module EventRasterVibrato --node AudibleTone --param Comment --value '"Sine mode exposes subtle stepped-pitch sidebands that saw harmonics would mask; the ratio range is exactly plus or minus 20 cents."' --agent
hise-cli dsp set --module EventRasterVibrato --node NormaliseLfo --param Folded --value true --agent
```

