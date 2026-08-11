---
id: fx.reverb.wet-reverb-wrapper
node: fx.reverb
domain: scriptnode
category: dsp-network
title: Wet reverb wrapper
summary: Wraps the wet-only fx.reverb node in a dry/wet template and exposes mix, size, and damping as public root controls.
useCase: Use this when an insert effect needs algorithmic reverb blended with the dry signal.
difficulty: beginner
networkName: wet_reverb_wrapper
moduleType: ScriptFX
moduleId: WetReverbWrapper
tags:
  - reverb
  - dry-wet
  - spatial
aliases:
  - Freeverb wrapper
  - room reverb insert
relatedNodes:
  - fx.reverb
  - template.dry_wet
  - control.xfader
parameters:
  Mix: Public root parameter matched to RoomMix.DryWet.
  Size: Public root parameter matched to RoomVerb.Size.
  Damping: Public root parameter matched to RoomVerb.Damping.
---

scriptnode example: fx.reverb

Wet reverb wrapper.
Use this to turn the wet-only `fx.reverb` node into a practical insert effect.

Graph:
```text
wet_reverb_wrapper
  RoomMix               template.dry_wet
    RoomMix_dry_path
      RoomMix_dry_wet_mixer
      RoomMix_dry_gain
    RoomMix_wet_path
      RoomVerb          fx.reverb
      RoomMix_wet_gain
```

Host:
  Module: `WetReverbWrapper`
  Type: `ScriptFX`
  Network: `wet_reverb_wrapper`
  Routing: default stereo

Support nodes:
  Required: `template.dry_wet`

Key rules:
  - `fx.reverb` outputs wet signal only; use a dry/wet wrapper for insert-style use.
  - The template creates `RoomMix_dry_wet_mixer.1 -> RoomMix_wet_gain.Gain`; keep `RoomMix_wet_gain` after the wet processing so the mix control scales the processed signal.
  - Omit `Width` for now because exploration found the current setter writes damping instead of actual width.
  - Reverb-tail signal verification needs delayed trace; immediate dirac traces can miss the wet output.

Public controls:
  - `Mix` -> `RoomMix.DryWet`, matched, range `0..1`, default `0.35`
  - `Size` -> `RoomVerb.Size`, matched, range `0.1..0.9`, default `0.65`
  - `Damping` -> `RoomVerb.Damping`, matched, range `0..1`, default `0.45`

HISE CLI build commands:
```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id WetReverbWrapper --agent
hise-cli builder set --module WetReverbWrapper --network wet_reverb_wrapper --agent
hise-cli dsp add --module WetReverbWrapper --type template.dry_wet --id RoomMix --agent
hise-cli dsp add --module WetReverbWrapper --type fx.reverb --id RoomVerb --parent RoomMix_wet_path --agent
hise-cli dsp remove --module WetReverbWrapper --node RoomMix_dummy --agent
hise-cli dsp set --module WetReverbWrapper --node RoomVerb --index 0 --agent
hise-cli dsp set --module WetReverbWrapper --node RoomMix_wet_gain --index 1 --agent
hise-cli dsp set --module WetReverbWrapper --node RoomMix --param DryWet --value 0.35 --agent
hise-cli dsp set --module WetReverbWrapper --node RoomVerb --param Size --range "0.1,0.9" --agent
hise-cli dsp set --module WetReverbWrapper --node RoomVerb --param Size --value 0.65 --agent
hise-cli dsp set --module WetReverbWrapper --node RoomVerb --param Damping --value 0.45 --agent
hise-cli dsp create_parameter --module WetReverbWrapper --container wet_reverb_wrapper --id Mix --range "0,1" --default 0.35 --agent
hise-cli dsp create_parameter --module WetReverbWrapper --container wet_reverb_wrapper --id Size --range "0.1,0.9" --default 0.65 --agent
hise-cli dsp create_parameter --module WetReverbWrapper --container wet_reverb_wrapper --id Damping --range "0,1" --default 0.45 --agent
hise-cli dsp connect --module WetReverbWrapper --source wet_reverb_wrapper --source-param Mix --target RoomMix --param DryWet --matched --agent
hise-cli dsp connect --module WetReverbWrapper --source wet_reverb_wrapper --source-param Size --target RoomVerb --param Size --matched --agent
hise-cli dsp connect --module WetReverbWrapper --source wet_reverb_wrapper --source-param Damping --target RoomVerb --param Damping --matched --agent
hise-cli dsp set --module WetReverbWrapper --node RoomVerb --param NodeColour --value 0xFF2F80ED --agent
hise-cli dsp set --module WetReverbWrapper --node RoomMix --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module WetReverbWrapper --node RoomMix_dry_wet_mixer --param Folded --value true --agent
hise-cli dsp set --module WetReverbWrapper --node RoomMix_dry_gain --param Folded --value true --agent
hise-cli dsp set --module WetReverbWrapper --node RoomMix_wet_gain --param Folded --value true --agent
```
