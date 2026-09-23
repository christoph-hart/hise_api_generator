---
id: container.frame2_block.midi-tuned-pseudo-stereo-karplus-resonator
node: container.frame2_block
domain: scriptnode
category: dsp-network
title: "MIDI-Tuned Pseudo-Stereo Karplus Resonator"
summary: "Enables per-sample processing for child nodes on two stereo channels."
useCase: "Demonstrate a practical stereo frame-processing use case: a minimal Karplus-Strong-style resonator requiring per-sample feedback and MIDI-tuned sub-millisecond delay control."
difficulty: advanced
networkName: midi_tuned_stereo_resonator
moduleType: ScriptFX
moduleId: MidiTunedStereoResonator
tags:
  - container
  - frame2
  - block
  - block-size
  - processing-context
aliases:
  - midi-tuned pseudo-stereo karplus resonator
  - frame2 block container
relatedNodes:
  - container.frame2_block
  - container.midichain
  - core.oscillator
  - envelope.ahdsr
  - control.midi
  - control.pma_unscaled
  - control.converter
  - template.feedback_delay
  - container.multi
  - jdsp.jdelay_cubic
  - filters.one_pole
parameters:
  Feedback: "Feedback -> ResonantLoop_fb_out.Feedback matched"
  Target: "Target range before connection: [0, 0.995]"
  Macro: "Macro range: [0, 0.995]"
  Default:: "Default: 0.985"
  Damping: "Damping -> LoopDamping.Frequency matched"
  Target: "Target range before connection: [500, 12000]"
  Macro: "Macro range: [500, 12000]"
  Default:: "Default: 6000"
---

scriptnode example: container.frame2_block

MIDI-Tuned Pseudo-Stereo Karplus Resonator.

Demonstrate a practical stereo frame-processing use case: a minimal Karplus-Strong-style resonator requiring per-sample feedback and MIDI-tuned sub-millisecond delay control.

Graph:
```text
midi_tuned_stereo_resonator
  MidiContext               container.midichain
    Exciter                  container.chain
      ExciterNoise           core.oscillator
      ExciterEnvelope        envelope.ahdsr
    StereoFrames             container.frame2_block
      NoteFrequency         control.midi
      FrequencyHz           control.pma_unscaled
      PeriodMs              control.converter
      LeftPeriod            control.pma_unscaled
      RightPeriod           control.pma_unscaled
      ResonantLoop          template.feedback_delay
        ResonantLoop_fb_out routing.receive
        StereoDelays        container.multi
          LeftDelay         jdsp.jdelay_cubic
          RightDelay        jdsp.jdelay_cubic
        LoopDamping         filters.one_pole
        ResonantLoop_fb_in  routing.send
```

Host:
  Module: MidiTunedStereoResonator
  Network: midi_tuned_stereo_resonator
  Type: `ScriptFX`
  Builder setup: `add ScriptFX as "MidiTunedStereoResonator"`, then set its network to `midi_tuned_stereo_resonator`.

Support nodes:
  Required: container.midichain, core.oscillator, envelope.ahdsr, control.midi, control.pma_unscaled, control.converter, template.feedback_delay, container.multi, jdsp.jdelay_cubic, filters.one_pole
  `container.midichain` delivers note events in a Script FX; a Noise-mode `core.oscillator` and short `envelope.ahdsr` create the excitation burst; `control.midi` extracts normalized note frequency; PMA scales it to raw Hz; `control.converter` converts frequency to period milliseconds; two further PMAs apply subtle stereo delay ratios; the feedback template supplies receive/send routing; `container.multi` gives each channel an independent delay; cubic interpolation supports fractional tuned periods; and a one-pole low-pass damps the feedback decay.

Key rules:
  - A MIDI note both tunes and excites the resonator.
  - Restore raw Hertz before Freq2Ms conversion.
  - The slight period multipliers create pseudo-stereo decay.
  - Remove only the template delay; preserve receive/send routing and keep send last.
  - Warn about approximate tuning and interpreted frame CPU cost.

Public controls:
  - Feedback -> ResonantLoop_fb_out.Feedback matched
  - Target range before connection: [0, 0.995]
  - Macro range: [0, 0.995]
  - Default: 0.985
  - Damping -> LoopDamping.Frequency matched
  - Target range before connection: [500, 12000]
  - Macro range: [500, 12000]
  - Default: 6000

HISE CLI build commands:
```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id MidiTunedStereoResonator --agent
hise-cli builder set --module MidiTunedStereoResonator --network midi_tuned_stereo_resonator --agent

hise-cli dsp add --module MidiTunedStereoResonator --type container.midichain --id MidiContext --agent
# Compact self-contained noise-burst exciter.
hise-cli dsp add --module MidiTunedStereoResonator --type container.chain --id Exciter --parent MidiContext --agent
hise-cli dsp set --module MidiTunedStereoResonator --node Exciter --param IsVertical --value false --agent
hise-cli dsp add --module MidiTunedStereoResonator --type core.oscillator --id ExciterNoise --parent Exciter --agent
hise-cli dsp add --module MidiTunedStereoResonator --type envelope.ahdsr --id ExciterEnvelope --parent Exciter --agent
hise-cli dsp add --module MidiTunedStereoResonator --type container.frame2_block --id StereoFrames --parent MidiContext --agent

hise-cli dsp add --module MidiTunedStereoResonator --type control.midi --id NoteFrequency --parent StereoFrames --agent
hise-cli dsp add --module MidiTunedStereoResonator --type control.pma_unscaled --id FrequencyHz --parent StereoFrames --agent
hise-cli dsp add --module MidiTunedStereoResonator --type control.converter --id PeriodMs --parent StereoFrames --agent
hise-cli dsp add --module MidiTunedStereoResonator --type control.pma_unscaled --id LeftPeriod --parent StereoFrames --agent
hise-cli dsp add --module MidiTunedStereoResonator --type control.pma_unscaled --id RightPeriod --parent StereoFrames --agent
hise-cli dsp add --module MidiTunedStereoResonator --type template.feedback_delay --id ResonantLoop --parent StereoFrames --agent

# Replace the template delay with independent fractional stereo delays.
hise-cli dsp remove --module MidiTunedStereoResonator --node ResonantLoop_delay --agent
hise-cli dsp add --module MidiTunedStereoResonator --type container.multi --id StereoDelays --parent ResonantLoop --agent
hise-cli dsp add --module MidiTunedStereoResonator --type jdsp.jdelay_cubic --id LeftDelay --parent StereoDelays --agent
hise-cli dsp add --module MidiTunedStereoResonator --type jdsp.jdelay_cubic --id RightDelay --parent StereoDelays --agent
hise-cli dsp add --module MidiTunedStereoResonator --type filters.one_pole --id LoopDamping --parent ResonantLoop --agent
hise-cli dsp set --module MidiTunedStereoResonator --node ResonantLoop_fb_out --index 0 --agent
hise-cli dsp set --module MidiTunedStereoResonator --node StereoDelays --index 1 --agent
hise-cli dsp set --module MidiTunedStereoResonator --node LoopDamping --index 2 --agent
# The feedback send must remain last so it captures the delayed and damped signal.
hise-cli dsp set --module MidiTunedStereoResonator --node ResonantLoop_fb_in --index 3 --agent

hise-cli dsp set --module MidiTunedStereoResonator --node ExciterNoise --param Mode --value 4 --agent
hise-cli dsp set --module MidiTunedStereoResonator --node ExciterNoise --param Gain --value 0.25 --agent
hise-cli dsp set --module MidiTunedStereoResonator --node ExciterEnvelope --param Attack --value 0 --agent
hise-cli dsp set --module MidiTunedStereoResonator --node ExciterEnvelope --param Hold --value 1 --agent
hise-cli dsp set --module MidiTunedStereoResonator --node ExciterEnvelope --param Decay --value 8 --agent
hise-cli dsp set --module MidiTunedStereoResonator --node ExciterEnvelope --param Sustain --value 0 --agent
hise-cli dsp set --module MidiTunedStereoResonator --node ExciterEnvelope --param Release --value 5 --agent
hise-cli dsp set --module MidiTunedStereoResonator --node ExciterEnvelope --param NumParameters --value 3 --agent

# Frequency mode emits note Hz divided by 20000, so restore raw Hertz before Freq2Ms conversion.
hise-cli dsp set --module MidiTunedStereoResonator --node NoteFrequency --param Mode --value '"Frequency"' --agent
hise-cli dsp set --module MidiTunedStereoResonator --node FrequencyHz --param Multiply --range "0,20000" --agent
hise-cli dsp set --module MidiTunedStereoResonator --node FrequencyHz --param Multiply --value 20000 --agent
hise-cli dsp set --module MidiTunedStereoResonator --node PeriodMs --param Mode --value '"Freq2Ms"' --agent
hise-cli dsp set --module MidiTunedStereoResonator --node LeftPeriod --param Multiply --range "0,2" --agent
hise-cli dsp set --module MidiTunedStereoResonator --node LeftPeriod --param Multiply --value 0.998 --agent
hise-cli dsp set --module MidiTunedStereoResonator --node RightPeriod --param Multiply --range "0,2" --agent
hise-cli dsp set --module MidiTunedStereoResonator --node RightPeriod --param Multiply --value 1.002 --agent
hise-cli dsp set --module MidiTunedStereoResonator --node LeftDelay --param Limit --value 30 --agent
hise-cli dsp set --module MidiTunedStereoResonator --node LeftDelay --param DelayTime --range "0,30" --agent
hise-cli dsp set --module MidiTunedStereoResonator --node RightDelay --param Limit --value 30 --agent
hise-cli dsp set --module MidiTunedStereoResonator --node RightDelay --param DelayTime --range "0,30" --agent

hise-cli dsp connect --module MidiTunedStereoResonator --source NoteFrequency --target FrequencyHz --param Value --agent
hise-cli dsp connect --module MidiTunedStereoResonator --source FrequencyHz --target PeriodMs --param Value --agent
hise-cli dsp connect --module MidiTunedStereoResonator --source PeriodMs --target LeftPeriod --param Value --agent
hise-cli dsp connect --module MidiTunedStereoResonator --source PeriodMs --target RightPeriod --param Value --agent
hise-cli dsp connect --module MidiTunedStereoResonator --source LeftPeriod --target LeftDelay --param DelayTime --agent
hise-cli dsp connect --module MidiTunedStereoResonator --source RightPeriod --target RightDelay --param DelayTime --agent

hise-cli dsp set --module MidiTunedStereoResonator --node LoopDamping --param Frequency --range "500,12000" --middlePosition 3000 --agent
hise-cli dsp set --module MidiTunedStereoResonator --node LoopDamping --param Frequency --value 6000 --agent
hise-cli dsp set --module MidiTunedStereoResonator --node LoopDamping --param Smoothing --value 0 --agent
hise-cli dsp set --module MidiTunedStereoResonator --node ResonantLoop_fb_out --param Feedback --range "0,0.995" --agent
hise-cli dsp set --module MidiTunedStereoResonator --node ResonantLoop_fb_out --param Feedback --value 0.985 --agent
hise-cli dsp create_parameter --module MidiTunedStereoResonator --container midi_tuned_stereo_resonator --id Feedback --range "0,0.995" --default 0.985 --agent
hise-cli dsp create_parameter --module MidiTunedStereoResonator --container midi_tuned_stereo_resonator --id Damping --range "500,12000" --default 6000 --middlePosition 3000 --agent
hise-cli dsp connect --module MidiTunedStereoResonator --source midi_tuned_stereo_resonator --source-param Feedback --target ResonantLoop_fb_out --param Feedback --matched --agent
hise-cli dsp connect --module MidiTunedStereoResonator --source midi_tuned_stereo_resonator --source-param Damping --target LoopDamping --param Frequency --matched --agent

# Interpreted stereo frame feedback is expensive; compile this network to C++ for practical use.
hise-cli dsp set --module MidiTunedStereoResonator --node midi_tuned_stereo_resonator --param Comment --value '"**CPU warning** - Interpreted stereo frame feedback is expensive. Compile this network to a C++ node before practical use."' --agent
hise-cli dsp set --module MidiTunedStereoResonator --node StereoFrames --param NodeColour --value 0xFF8E44AD --agent
hise-cli dsp set --module MidiTunedStereoResonator --node StereoFrames --param Comment --value '"**MIDI-tuned stereo resonator** - One-sample frame feedback creates a simple Karplus-Strong-style decay."' --agent
hise-cli dsp set --module MidiTunedStereoResonator --node MidiContext --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module MidiTunedStereoResonator --node Exciter --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module MidiTunedStereoResonator --node ExciterNoise --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module MidiTunedStereoResonator --node ExciterEnvelope --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module MidiTunedStereoResonator --node NoteFrequency --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module MidiTunedStereoResonator --node FrequencyHz --param Folded --value true --agent
hise-cli dsp set --module MidiTunedStereoResonator --node PeriodMs --param Folded --value true --agent
hise-cli dsp set --module MidiTunedStereoResonator --node LeftPeriod --param Folded --value true --agent
hise-cli dsp set --module MidiTunedStereoResonator --node RightPeriod --param Folded --value true --agent
hise-cli dsp set --module MidiTunedStereoResonator --node ResonantLoop_fb_out --param Folded --value true --agent
hise-cli dsp set --module MidiTunedStereoResonator --node ResonantLoop_fb_in --param Folded --value true --agent
```

