---
id: container.repitch.repitched-reverb-space
node: container.repitch
domain: scriptnode
category: dsp-network
title: "Repitched Reverb Space"
summary: "A serial container that resamples audio before and after child processing to change the effective pitch."
useCase: "Demonstrate how `container.repitch` alters sample-rate-dependent child behaviour rather than pitch-shifting the final mixed signal like a conventional pitch effect."
difficulty: advanced
networkName: repitched_reverb_space
moduleType: ScriptFX
moduleId: RepitchedReverbSpace
tags:
  - container
  - repitch
aliases:
  - repitched reverb space
  - repitch container
relatedNodes:
  - container.repitch
  - template.dry_wet
  - fx.reverb
parameters:
  RepitchFactor: "RepitchFactor -> ReverbResampler.RepitchFactor matched"
  Target: "Target range before connection: [0.5, 2], logarithmic centre 1"
  Macro: "Macro range: [0.5, 2], logarithmic centre 1"
  Default:: "Default: 1"
  Mix: "Mix -> ReverbMix.DryWet matched"
  Target: "Target range before connection: [0, 1]"
  Macro: "Macro range: [0, 1]"
  Default:: "Default: 0.4"
---

scriptnode example: container.repitch

Repitched Reverb Space.

Demonstrate how `container.repitch` alters sample-rate-dependent child behaviour rather than pitch-shifting the final mixed signal like a conventional pitch effect.

Graph:
```text
repitched_reverb_space
  ReverbMix              template.dry_wet
    ReverbMix_wet_path
      ReverbResampler    container.repitch
        WetReverb        fx.reverb
      ReverbMix_wet_gain
```

Host:
  Module: RepitchedReverbSpace
  Network: repitched_reverb_space
  Type: `ScriptFX`
  Builder setup: `add ScriptFX as "RepitchedReverbSpace"`, then set its network to `repitched_reverb_space`.

Support nodes:
  Required: template.dry_wet, fx.reverb
  `fx.reverb` provides an obviously sample-rate-dependent network of comb and allpass delays whose colour and tail respond to resampling; `template.dry_wet` restores the unprocessed signal because the reverb itself outputs only wet audio.

Key rules:
  - Using more than two audio channels: Repitch only processes 1 or 2 channels. With more channels, the audio passes through unmodified with no warning.

Public controls:
  - RepitchFactor -> ReverbResampler.RepitchFactor matched
  - Target range before connection: [0.5, 2], logarithmic centre 1
  - Macro range: [0.5, 2], logarithmic centre 1
  - Default: 1
  - Mix -> ReverbMix.DryWet matched
  - Target range before connection: [0, 1]
  - Macro range: [0, 1]
  - Default: 0.4

HISE CLI build commands:
```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id RepitchedReverbSpace --agent
hise-cli builder set --module RepitchedReverbSpace --network repitched_reverb_space --agent

hise-cli dsp add --module RepitchedReverbSpace --type template.dry_wet --id ReverbMix --agent
# Only the wet reverb is placed in the changed sample-rate context.
hise-cli dsp add --module RepitchedReverbSpace --type container.repitch --id ReverbResampler --parent ReverbMix_wet_path --agent
hise-cli dsp add --module RepitchedReverbSpace --type fx.reverb --id WetReverb --parent ReverbResampler --agent
hise-cli dsp remove --module RepitchedReverbSpace --node ReverbMix_dummy --agent
hise-cli dsp set --module RepitchedReverbSpace --node ReverbResampler --index 0 --agent
# Preserve the generated wet gain as the last wet-path node.
hise-cli dsp set --module RepitchedReverbSpace --node ReverbMix_wet_gain --index 1 --agent

hise-cli dsp set --module RepitchedReverbSpace --node ReverbResampler --param RepitchFactor --range "0.5,2" --stepSize 0 --middlePosition 1 --agent
hise-cli dsp set --module RepitchedReverbSpace --node ReverbResampler --param RepitchFactor --value 1 --agent
hise-cli dsp set --module RepitchedReverbSpace --node WetReverb --param Size --value 0.7 --agent
hise-cli dsp set --module RepitchedReverbSpace --node WetReverb --param Damping --value 0.45 --agent
hise-cli dsp set --module RepitchedReverbSpace --node WetReverb --param Width --value 0.8 --agent

hise-cli dsp create_parameter --module RepitchedReverbSpace --container repitched_reverb_space --id RepitchFactor --range "0.5,2" --default 1 --middlePosition 1 --agent
hise-cli dsp create_parameter --module RepitchedReverbSpace --container repitched_reverb_space --id Mix --range "0,1" --default 0.4 --agent
hise-cli dsp connect --module RepitchedReverbSpace --source repitched_reverb_space --source-param RepitchFactor --target ReverbResampler --param RepitchFactor --matched --agent
hise-cli dsp connect --module RepitchedReverbSpace --source repitched_reverb_space --source-param Mix --target ReverbMix --param DryWet --matched --agent

# Expose both inner container targets so their root cables are visible.
hise-cli dsp set --module RepitchedReverbSpace --node ReverbMix --param ShowParameters --value true --agent
hise-cli dsp set --module RepitchedReverbSpace --node ReverbResampler --param ShowParameters --value true --agent

hise-cli dsp set --module RepitchedReverbSpace --node ReverbResampler --param NodeColour --value 0xFF2F80ED --agent
hise-cli dsp set --module RepitchedReverbSpace --node ReverbResampler --param Comment --value '"Changes the effective sample rate seen by WetReverb. Effects-only pitch direction can seem inverted, so verify both factor endpoints by ear."' --agent
hise-cli dsp set --module RepitchedReverbSpace --node ReverbMix --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module RepitchedReverbSpace --node ReverbMix --param Comment --value '"Only the wet reverb is repitched. The dry signal remains at the host sample rate."' --agent
hise-cli dsp set --module RepitchedReverbSpace --node WetReverb --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module RepitchedReverbSpace --node WetReverb --param Comment --value '"This 100 percent wet reverb runs at the effective sample rate supplied by ReverbResampler."' --agent
hise-cli dsp set --module RepitchedReverbSpace --node ReverbMix_wet_path --param Comment --value '"Keep ReverbMix_wet_gain last after the resampled reverb."' --agent
hise-cli dsp set --module RepitchedReverbSpace --node repitched_reverb_space --param Comment --value '"repitch supports mono or stereo only. Additional channels pass unchanged, and unreported resampling latency rules out an uncompensated parallel path."' --agent
hise-cli dsp set --module RepitchedReverbSpace --node ReverbMix_wet_gain --param Folded --value true --agent
```

