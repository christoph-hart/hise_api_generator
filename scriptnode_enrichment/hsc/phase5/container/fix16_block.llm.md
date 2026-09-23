---
id: container.fix16_block.snappy-filter-envelope
node: container.fix16_block
domain: scriptnode
category: dsp-network
title: "Snappy Filter Envelope"
summary: "Splits the audio buffer into chunks of 16 samples for higher modulation update rates."
useCase: "Demonstrate why `container.fix16_block` is a practical compromise for fast filter envelopes that need tighter updates than ordinary control-rate processing without paying the iteration cost of 8-sample pitch modulation."
difficulty: beginner
networkName: snappy_filter_envelope
moduleType: ScriptSynth
moduleId: SnappyFilterEnvelope
tags:
  - container
  - fix16
  - block
  - block-size
  - processing-context
aliases:
  - snappy filter envelope
  - fix16 block container
relatedNodes:
  - container.fix16_block
  - core.oscillator
  - envelope.ahdsr
  - filters.svf
  - envelope.voice_manager
parameters:
  None: "None"
---

scriptnode example: container.fix16_block

Snappy Filter Envelope.

Demonstrate why `container.fix16_block` is a practical compromise for fast filter envelopes that need tighter updates than ordinary control-rate processing without paying the iteration cost of 8-sample pitch modulation.

Graph:
```text
snappy_filter_envelope
  SixteenSampleVoice     container.fix16_block
    SawVoice             core.oscillator
    FilterEnvelope       envelope.ahdsr
    SnappyLowPass        filters.svf
    VoiceLifecycle       envelope.voice_manager
```

Host:
  Module: SnappyFilterEnvelope
  Network: snappy_filter_envelope
  Host context: `Scriptnode Synthesiser` (`ScriptSynth`)
  Required channels: default stereo in a polyphonic synth voice context
  Module routing: default stereo
  Master routing: default stereo
  Type: `ScriptSynth`
  Builder setup: `add ScriptSynth as "SnappyFilterEnvelope"`, then set its network to `snappy_filter_envelope`.

Support nodes:
  Required: core.oscillator, envelope.ahdsr, filters.svf, envelope.voice_manager
  The Scriptnode Synthesiser root already supplies the required voice and MIDI context; `core.oscillator` provides a harmonically rich saw source; `envelope.ahdsr` shapes amplitude and exports the fast CV; `filters.svf` exposes a stable modulatable cutoff with smoothing explicitly disabled; and `envelope.voice_manager` uses the envelope Gate output for proper voice cleanup.

Key rules:
  - Before SixteenSampleVoice: The synth root already supplies MIDI and voice context; no extra midichain is needed.
  - Before the filter setup: Smoothing must be zero so the fixed-block cadence remains visible and audible.
  - Before the frequency connection: Configure the broad skewed cutoff range first.
  - Before VoiceLifecycle: Connect AHDSR Gate output 1, not CV output 0.
  - Before validation: Use --trigger-note to allocate a synth voice before probing.

Public controls:
  - None

HISE CLI build commands:
```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptSynth --id SnappyFilterEnvelope --agent
hise-cli builder set --module SnappyFilterEnvelope --network snappy_filter_envelope --agent

# The Scriptnode Synthesiser root already supplies MIDI and voice context, so no extra midichain is required.
# Sixteen samples is the maximum child chunk size; a final remainder may be shorter.
hise-cli dsp add --module SnappyFilterEnvelope --type container.fix16_block --id SixteenSampleVoice --agent
hise-cli dsp add --module SnappyFilterEnvelope --type core.oscillator --id SawVoice --parent SixteenSampleVoice --agent
hise-cli dsp add --module SnappyFilterEnvelope --type envelope.ahdsr --id FilterEnvelope --parent SixteenSampleVoice --agent
hise-cli dsp add --module SnappyFilterEnvelope --type filters.svf --id SnappyLowPass --parent SixteenSampleVoice --agent
hise-cli dsp add --module SnappyFilterEnvelope --type envelope.voice_manager --id VoiceLifecycle --parent SixteenSampleVoice --agent

hise-cli dsp set --module SnappyFilterEnvelope --node SawVoice --param Mode --value 1 --agent
hise-cli dsp set --module SnappyFilterEnvelope --node SawVoice --param Gain --value 0.125 --agent
hise-cli dsp set --module SnappyFilterEnvelope --node FilterEnvelope --param Attack --value 1 --agent
hise-cli dsp set --module SnappyFilterEnvelope --node FilterEnvelope --param Hold --value 0 --agent
hise-cli dsp set --module SnappyFilterEnvelope --node FilterEnvelope --param Decay --value 300 --agent
hise-cli dsp set --module SnappyFilterEnvelope --node FilterEnvelope --param Sustain --value 0.5 --agent
hise-cli dsp set --module SnappyFilterEnvelope --node FilterEnvelope --param Release --value 50 --agent
hise-cli dsp set --module SnappyFilterEnvelope --node FilterEnvelope --param NumParameters --value 2 --agent

# Smoothing must be zero or filter interpolation will hide the sixteen-sample envelope updates.
hise-cli dsp set --module SnappyFilterEnvelope --node SnappyLowPass --param Frequency --range "120,12000" --middlePosition 1000 --agent
hise-cli dsp set --module SnappyFilterEnvelope --node SnappyLowPass --param Frequency --value 120 --agent
hise-cli dsp set --module SnappyFilterEnvelope --node SnappyLowPass --param Q --value 0.8 --agent
hise-cli dsp set --module SnappyFilterEnvelope --node SnappyLowPass --param Smoothing --value 0 --agent
hise-cli dsp connect --module SnappyFilterEnvelope --source FilterEnvelope --source-output 0 --target SnappyLowPass --param Frequency --agent
# Use the envelope Gate output, not CV, for voice cleanup.
hise-cli dsp connect --module SnappyFilterEnvelope --source FilterEnvelope --source-output 1 --target VoiceLifecycle --param 'Kill Voice' --agent

hise-cli dsp set --module SnappyFilterEnvelope --node SixteenSampleVoice --param NodeColour --value 0xFF2F80ED --agent
hise-cli dsp set --module SnappyFilterEnvelope --node SixteenSampleVoice --param Comment --value '"**Snappy filter envelope** - Sixteen-sample chunks provide fast cutoff updates without the iteration cost of eight-sample pitch modulation."' --agent
hise-cli dsp set --module SnappyFilterEnvelope --node SawVoice --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module SnappyFilterEnvelope --node FilterEnvelope --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module SnappyFilterEnvelope --node FilterEnvelope --param Comment --value '"The Scriptnode Synthesiser root already supplies MIDI and voice context; a redundant midichain is unnecessary."' --agent
hise-cli dsp set --module SnappyFilterEnvelope --node SnappyLowPass --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module SnappyFilterEnvelope --node SnappyLowPass --param Comment --value '"Smoothing must remain at zero so interpolation does not hide the sixteen-sample envelope updates."' --agent
hise-cli dsp set --module SnappyFilterEnvelope --node VoiceLifecycle --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module SnappyFilterEnvelope --node VoiceLifecycle --param Comment --value '"The envelope Gate output kills each voice after release; do not connect the CV output here."' --agent
hise-cli dsp set --module SnappyFilterEnvelope --node VoiceLifecycle --param Folded --value true --agent
```

