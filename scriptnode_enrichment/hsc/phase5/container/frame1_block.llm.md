---
id: container.frame1_block.antiphase-stereo-sample-accurate-chorus
node: container.frame1_block
domain: scriptnode
category: dsp-network
title: "Antiphase Stereo Sample-Accurate Chorus"
summary: "Enables per-sample processing for child nodes on a single mono channel."
useCase: "Demonstrate the one-channel contract of `container.frame1_block` without requiring a mono host, while showing a practical stereo use case where two independent frame processors provide sample-accurate antiphase chorus modulation."
difficulty: advanced
networkName: antiphase_stereo_chorus
moduleType: ScriptFX
moduleId: AntiphaseStereoChorus
tags:
  - container
  - frame1
  - block
  - block-size
  - processing-context
aliases:
  - antiphase stereo sample-accurate chorus
  - frame1 block container
relatedNodes:
  - container.frame1_block
  - template.dry_wet
  - container.multi
  - container.modchain
  - core.ramp
  - math.pi
  - math.sin
  - math.mul
  - math.sig2mod
  - core.peak
  - jdsp.jdelay_cubic
parameters:
  Rate: "Rate -> LeftRamp.PeriodTime and RightRamp.PeriodTime matched"
  Target: "Target ranges before connection: [200, 6000]"
  Macro: "Macro range: [200, 6000] ms period"
  Default:: "Default: 5000"
  Mix: "Mix -> ChorusMix.DryWet matched"
  Target: "Target range before connection: [0, 1]"
  Macro: "Macro range: [0, 1]"
  Default:: "Default: 0.5"
  LfoGate: "LfoGate -> LeftRamp.Gate and RightRamp.Gate matched"
  Macro: "Macro range: Off/On"
  Default:: "Default: On"
  Construction: "Construction reset: set LfoGate to Off, then On after both connections are present"
---

scriptnode example: container.frame1_block

Antiphase Stereo Sample-Accurate Chorus.

Demonstrate the one-channel contract of `container.frame1_block` without requiring a mono host, while showing a practical stereo use case where two independent frame processors provide sample-accurate antiphase chorus modulation.

Graph:
```text
antiphase_stereo_chorus
  ChorusMix                    template.dry_wet
    ChorusMix_wet_path
      StereoWetChannels        container.multi
        LeftFrames             container.frame1_block
          LeftDelayLfo         container.modchain
            LeftRamp           core.ramp
            LeftCycle          math.pi
            LeftSine           math.sin
            LeftNormalise      math.sig2mod
            LeftDelayControl   core.peak
          LeftDelay            jdsp.jdelay_cubic
        RightFrames            container.frame1_block
          RightDelayLfo        container.modchain
            RightRamp          core.ramp
            RightCycle         math.pi
            RightSine          math.sin
            InvertRight        math.mul
            RightNormalise     math.sig2mod
            RightDelayControl  core.peak
          RightDelay           jdsp.jdelay_cubic
      ChorusMix_wet_gain
```

Host:
  Module: AntiphaseStereoChorus
  Network: antiphase_stereo_chorus
  Host context: Script FX
  Type: `ScriptFX`
  Builder setup: `add ScriptFX as "AntiphaseStereoChorus"`, then set its network to `antiphase_stereo_chorus`.

Support nodes:
  Required: template.dry_wet, container.multi, container.modchain, core.ramp, math.pi, math.sin, math.mul, math.sig2mod, core.peak, jdsp.jdelay_cubic
  `template.dry_wet` supplies a shared linear chorus mix; `container.multi` gives each stereo channel its own mono child; each `container.frame1_block` processes one channel per sample; ramp, pi, sine, normalization, and peak nodes create delay modulation; `math.mul` inverts the right sine; and cubic delays provide interpolation suitable for chorus.

Key rules:
  - Each container.multi child receives one mono channel.
  - Invert the right bipolar sine before normalization.
  - Set DelayTime middle position to 7 before connecting.
  - Preserve the template wet gain as the final wet child.
  - Toggle shared LfoGate off and on to synchronize independently created ramps.
  - Warn that interpreted dual-frame processing is extremely CPU-intensive and should be compiled to C++.
  - Using in a stereo network expecting both channels: frame1_block fixes the channel count to 1 (mono). In a stereo network, only channel 0 is processed by the children. Channel 1 passes through without modification, which is rarely the intended behaviour.

Public controls:
  - Rate -> LeftRamp.PeriodTime and RightRamp.PeriodTime matched
  - Target ranges before connection: [200, 6000]
  - Macro range: [200, 6000] ms period
  - Default: 5000
  - Mix -> ChorusMix.DryWet matched
  - Target range before connection: [0, 1]
  - Macro range: [0, 1]
  - Default: 0.5
  - LfoGate -> LeftRamp.Gate and RightRamp.Gate matched
  - Macro range: Off/On
  - Default: On
  - Construction reset: set LfoGate to Off, then On after both connections are present

HISE CLI build commands:
```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id AntiphaseStereoChorus --agent
hise-cli builder set --module AntiphaseStereoChorus --network antiphase_stereo_chorus --agent
# Add a direct MIDI audition source for the chorus.
hise-cli builder add --type WaveSynth --id "Waveform Generator" --agent

hise-cli dsp add --module AntiphaseStereoChorus --type template.dry_wet --id ChorusMix --agent
hise-cli dsp add --module AntiphaseStereoChorus --type container.multi --id StereoWetChannels --parent ChorusMix_wet_path --agent
hise-cli dsp remove --module AntiphaseStereoChorus --node ChorusMix_dummy --agent
# Preserve the template wet gain and keep it after the stereo frame processor.
hise-cli dsp set --module AntiphaseStereoChorus --node StereoWetChannels --index 0 --agent
hise-cli dsp set --module AntiphaseStereoChorus --node ChorusMix_wet_gain --index 1 --agent

# Each multi child receives one mono channel, making frame1 safe in a default stereo host.
hise-cli dsp add --module AntiphaseStereoChorus --type container.frame1_block --id LeftFrames --parent StereoWetChannels --agent
hise-cli dsp add --module AntiphaseStereoChorus --type container.modchain --id LeftDelayLfo --parent LeftFrames --agent
hise-cli dsp add --module AntiphaseStereoChorus --type core.ramp --id LeftRamp --parent LeftDelayLfo --agent
hise-cli dsp add --module AntiphaseStereoChorus --type math.pi --id LeftCycle --parent LeftDelayLfo --agent
hise-cli dsp add --module AntiphaseStereoChorus --type math.sin --id LeftSine --parent LeftDelayLfo --agent
hise-cli dsp add --module AntiphaseStereoChorus --type math.sig2mod --id LeftNormalise --parent LeftDelayLfo --agent
hise-cli dsp add --module AntiphaseStereoChorus --type core.peak --id LeftDelayControl --parent LeftDelayLfo --agent
hise-cli dsp add --module AntiphaseStereoChorus --type jdsp.jdelay_cubic --id LeftDelay --parent LeftFrames --agent

hise-cli dsp add --module AntiphaseStereoChorus --type container.frame1_block --id RightFrames --parent StereoWetChannels --agent
hise-cli dsp add --module AntiphaseStereoChorus --type container.modchain --id RightDelayLfo --parent RightFrames --agent
hise-cli dsp add --module AntiphaseStereoChorus --type core.ramp --id RightRamp --parent RightDelayLfo --agent
hise-cli dsp add --module AntiphaseStereoChorus --type math.pi --id RightCycle --parent RightDelayLfo --agent
hise-cli dsp add --module AntiphaseStereoChorus --type math.sin --id RightSine --parent RightDelayLfo --agent
# Invert the bipolar sine before normalization so the right delay moves opposite to the left.
hise-cli dsp add --module AntiphaseStereoChorus --type math.mul --id InvertRight --parent RightDelayLfo --agent
hise-cli dsp add --module AntiphaseStereoChorus --type math.sig2mod --id RightNormalise --parent RightDelayLfo --agent
hise-cli dsp add --module AntiphaseStereoChorus --type core.peak --id RightDelayControl --parent RightDelayLfo --agent
hise-cli dsp add --module AntiphaseStereoChorus --type jdsp.jdelay_cubic --id RightDelay --parent RightFrames --agent

hise-cli dsp set --module AntiphaseStereoChorus --node LeftRamp --param PeriodTime --range "200,6000" --agent
hise-cli dsp set --module AntiphaseStereoChorus --node LeftRamp --param PeriodTime --value 5000 --agent
hise-cli dsp set --module AntiphaseStereoChorus --node RightRamp --param PeriodTime --range "200,6000" --agent
hise-cli dsp set --module AntiphaseStereoChorus --node RightRamp --param PeriodTime --value 5000 --agent
hise-cli dsp set --module AntiphaseStereoChorus --node InvertRight --param Value --range "-1,1" --agent
hise-cli dsp set --module AntiphaseStereoChorus --node InvertRight --param Value --value -1 --agent
hise-cli dsp set --module AntiphaseStereoChorus --node LeftDelay --param Limit --value 20 --agent
# Set a linear midpoint explicitly; retaining the original delay skew would make complementary values asymmetric.
hise-cli dsp set --module AntiphaseStereoChorus --node LeftDelay --param DelayTime --range "4,10" --middlePosition 7 --agent
hise-cli dsp set --module AntiphaseStereoChorus --node RightDelay --param Limit --value 20 --agent
hise-cli dsp set --module AntiphaseStereoChorus --node RightDelay --param DelayTime --range "4,10" --middlePosition 7 --agent
hise-cli dsp connect --module AntiphaseStereoChorus --source LeftDelayControl --target LeftDelay --param DelayTime --agent
hise-cli dsp connect --module AntiphaseStereoChorus --source RightDelayControl --target RightDelay --param DelayTime --agent

hise-cli dsp create_parameter --module AntiphaseStereoChorus --container antiphase_stereo_chorus --id Rate --range "200,6000" --default 5000 --stepSize 0.1 --agent
hise-cli dsp create_parameter --module AntiphaseStereoChorus --container antiphase_stereo_chorus --id Mix --range "0,1" --default 0.5 --agent
hise-cli dsp create_parameter --module AntiphaseStereoChorus --container antiphase_stereo_chorus --id LfoGate --range "0,1" --default 1 --stepSize 1 --agent
hise-cli dsp connect --module AntiphaseStereoChorus --source antiphase_stereo_chorus --source-param Rate --target LeftRamp --param PeriodTime --matched --agent
hise-cli dsp connect --module AntiphaseStereoChorus --source antiphase_stereo_chorus --source-param Rate --target RightRamp --param PeriodTime --matched --agent
hise-cli dsp connect --module AntiphaseStereoChorus --source antiphase_stereo_chorus --source-param Mix --target ChorusMix --param DryWet --matched --agent
hise-cli dsp connect --module AntiphaseStereoChorus --source antiphase_stereo_chorus --source-param LfoGate --target LeftRamp --param Gate --matched --agent
hise-cli dsp connect --module AntiphaseStereoChorus --source antiphase_stereo_chorus --source-param LfoGate --target RightRamp --param Gate --matched --agent
# Expose DryWet so the root Mix cable is visible on the inner template container.
hise-cli dsp set --module AntiphaseStereoChorus --node ChorusMix --param ShowParameters --value true --agent
# Restart both independently created ramps on one shared parameter callback.
hise-cli dsp set --module AntiphaseStereoChorus --node antiphase_stereo_chorus --param LfoGate --value 0 --agent
hise-cli dsp set --module AntiphaseStereoChorus --node antiphase_stereo_chorus --param LfoGate --value 1 --agent

# This warning is load-bearing documentation for interpreted use.
hise-cli dsp set --module AntiphaseStereoChorus --node antiphase_stereo_chorus --param Comment --value '"**CPU warning** - Two interpreted frame1 branches are extremely expensive. Compile this network to a C++ node before practical use."' --agent
hise-cli dsp set --module AntiphaseStereoChorus --node ChorusMix --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module AntiphaseStereoChorus --node ChorusMix --param Comment --value '"**Antiphase stereo chorus** - The module-tree WaveSynth provides an immediate audition source for two independent mono frame-processed delay paths."' --agent
hise-cli dsp set --module AntiphaseStereoChorus --node StereoWetChannels --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module AntiphaseStereoChorus --node StereoWetChannels --param Comment --value '"Splits default stereo into one mono frame1 processor for each channel."' --agent
hise-cli dsp set --module AntiphaseStereoChorus --node LeftFrames --param NodeColour --value 0xFF8E44AD --agent
hise-cli dsp set --module AntiphaseStereoChorus --node LeftFrames --param Comment --value '"Processes the left channel with one DelayTime update per sample."' --agent
hise-cli dsp set --module AntiphaseStereoChorus --node RightFrames --param NodeColour --value 0xFF8E44AD --agent
hise-cli dsp set --module AntiphaseStereoChorus --node RightFrames --param Comment --value '"Processes the right channel with polarity-inverted sample-accurate modulation."' --agent
hise-cli dsp set --module AntiphaseStereoChorus --node LeftDelayLfo --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module AntiphaseStereoChorus --node RightDelayLfo --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module AntiphaseStereoChorus --node LeftDelay --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module AntiphaseStereoChorus --node RightDelay --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module AntiphaseStereoChorus --node LeftCycle --param Folded --value true --agent
hise-cli dsp set --module AntiphaseStereoChorus --node LeftSine --param Folded --value true --agent
hise-cli dsp set --module AntiphaseStereoChorus --node LeftNormalise --param Folded --value true --agent
hise-cli dsp set --module AntiphaseStereoChorus --node LeftDelayControl --param Folded --value true --agent
hise-cli dsp set --module AntiphaseStereoChorus --node RightCycle --param Folded --value true --agent
hise-cli dsp set --module AntiphaseStereoChorus --node RightSine --param Folded --value true --agent
hise-cli dsp set --module AntiphaseStereoChorus --node InvertRight --param Folded --value true --agent
hise-cli dsp set --module AntiphaseStereoChorus --node RightNormalise --param Folded --value true --agent
hise-cli dsp set --module AntiphaseStereoChorus --node RightDelayControl --param Folded --value true --agent
hise-cli dsp set --module AntiphaseStereoChorus --node ChorusMix_wet_gain --param Folded --value true --agent
```

