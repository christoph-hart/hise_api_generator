---
id: fx.phase_delay.phase-fx-recreation
node: fx.phase_delay
domain: scriptnode
category: dsp-network
title: PhaseFX-style swept allpass phaser
summary: Builds a six-stage feedback phaser from fx.phase_delay nodes with external modulation and dry/wet mixing.
useCase: Use this to recreate a PhaseFX-style phaser or to learn how allpass stages form a resonant swept effect.
difficulty: advanced
aliases:
  - PhaseFX recreation
  - feedback phaser
  - swept allpass phaser
networkName: phase_fx_recreation
moduleType: ScriptFX
moduleId: PhaseFXRecreation
tags:
  - phase-delay
  - phaser
  - feedback
  - external-modulation
  - allpass
relatedNodes:
  - fx.phase_delay
  - core.extra_mod
  - control.minmax
  - template.feedback_delay
  - template.dry_wet
parameters:
  Mix: Public dry/wet control matched to PhaseMix.DryWet.
  Feedback: Public feedback control matched to ResonantLoop_fb_out.Feedback.
  Frequency1: Lower bound of the shared allpass sweep.
  Frequency2: Upper bound of the shared allpass sweep.
  ModDepth: Root parameter assigned to ExternalModulation Combined for PhaseMod slot 0.
---
scriptnode example: fx.phase_delay

PhaseFX-style swept allpass phaser

A first-order allpass filter that shifts the phase of the signal without changing its amplitude, intended for building comb filters.

Context:
  A synth or guitar insert needs a close scriptnode recreation of HISE's PhaseFX module. The network feeds a small amount of the previous allpass-cascade output back into the cascade, sweeps all `fx.phase_delay` stages together, then sums the shifted output with the dry signal for the characteristic resonant phaser notches.

Use this when:
  Demonstrate that `fx.phase_delay` is the allpass building block in a feedback phaser topology, not a complete PhaseFX replacement by itself.

Graph:
```text
phase_fx_recreation
  MidiContext              container.midichain
    FramePhaseFX           container.frame2_block
      PhaseMod             core.extra_mod
      SweepRange            control.minmax
      PhaseMix              template.dry_wet -> container.split
        PhaseMix_dry_path   container.chain
          PhaseMix_dry_wet_mixer  control.xfader
          PhaseMix_dry_gain       core.gain
        PhaseMix_wet_path   container.chain
          ResonantLoop      template.feedback_delay -> container.fix32_block
            ResonantLoop_fb_out  routing.receive
            Stage1            fx.phase_delay
            Stage2            fx.phase_delay
            Stage3            fx.phase_delay
            Stage4            fx.phase_delay
            Stage5            fx.phase_delay
            Stage6            fx.phase_delay
            ResonantLoop_fb_in   routing.send
          PhaseMix_wet_gain  core.gain
```

Host:
  Host context: Script FX
  Module ID: PhaseFXRecreation
  Network ID: phase_fx_recreation

Support nodes:
  Required: template.feedback_delay, template.dry_wet, container.midichain, container.frame2_block, core.extra_mod, control.minmax, fx.phase_delay
  Optional: core.gain
  The feedback template supplies the safe feedback routing needed to approximate PhaseFX resonance, the dry/wet template supplies the final insert-style mix, `core.extra_mod` and `control.minmax` provide the external sweep, and multiple `fx.phase_delay` nodes form the allpass cascade.

Public controls:
  - Mix -> `PhaseMix.DryWet` matched
  - Target range before connection: `[0, 1]`
  - Macro range: `[0, 1]`
  - Default: `0.75`
  - Feedback -> internal feedback gain parameter of `ResonantLoop` matched
  - Target range before connection: `[0, 0.99]`
  - Macro range: `[0, 1]`
  - Default: `0.7`
  - Frequency1 -> `SweepRange.Minimum` matched
  - Target range before connection: `[20, 20000]`
  - Macro range: `[20, 20000]`
  - Default: `400`
  - Frequency2 -> `SweepRange.Maximum` matched
  - Target range before connection: `[20, 20000]`
  - Macro range: `[20, 20000]`
  - Default: `1600`

Key rules:
  - `core.extra_mod` reads modulation slot 0, which is assigned by the root `ModDepth` parameter using `ExternalModulation Combined`.
  - Keep `container.midichain` outside `container.frame2_block`; the frame container needs sample-by-sample processing while the MIDI context supplies event handling.
  - Remove the feedback template delay so the loop uses the frame feedback state rather than an echo delay.
  - All six allpass stages share the same swept frequency, and feedback must remain below unity.

Common mistakes:
  - Not a comb filter on its own: The node outputs only the phase-shifted signal. Comb filtering requires mixing this with the original signal, which a parallel container provides automatically.

HISE CLI build commands:
```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id PhaseFXRecreation --agent
hise-cli builder set --module PhaseFXRecreation --network phase_fx_recreation --agent
hise-cli dsp create_parameter --module PhaseFXRecreation --container phase_fx_recreation --id Mix --range "0,1" --default 0.75 --agent
hise-cli dsp create_parameter --module PhaseFXRecreation --container phase_fx_recreation --id Feedback --range "0,1" --default 0.7 --agent
hise-cli dsp create_parameter --module PhaseFXRecreation --container phase_fx_recreation --id Frequency1 --range "20,20000" --default 400 --agent
hise-cli dsp create_parameter --module PhaseFXRecreation --container phase_fx_recreation --id Frequency2 --range "20,20000" --default 1600 --agent
hise-cli dsp create_parameter --module PhaseFXRecreation --container phase_fx_recreation --id ModDepth --range "0,1" --default 0.5 --externalModulation Combined --agent
hise-cli dsp add --module PhaseFXRecreation --type container.midichain --id MidiContext --agent
hise-cli dsp add --module PhaseFXRecreation --type container.frame2_block --id FramePhaseFX --parent MidiContext --agent
hise-cli dsp add --module PhaseFXRecreation --type core.extra_mod --id PhaseMod --parent FramePhaseFX --agent
hise-cli dsp set --module PhaseFXRecreation --node PhaseMod --param Index --value 0 --agent
hise-cli dsp add --module PhaseFXRecreation --type control.minmax --id SweepRange --parent FramePhaseFX --agent
hise-cli dsp add --module PhaseFXRecreation --type template.dry_wet --id PhaseMix --parent FramePhaseFX --agent
hise-cli dsp add --module PhaseFXRecreation --type template.feedback_delay --id ResonantLoop --parent PhaseMix_wet_path --agent
hise-cli dsp remove --module PhaseFXRecreation --node PhaseMix_dummy --agent
hise-cli dsp remove --module PhaseFXRecreation --node ResonantLoop_delay --agent
hise-cli dsp add --module PhaseFXRecreation --type fx.phase_delay --id Stage1 --parent ResonantLoop --agent
hise-cli dsp add --module PhaseFXRecreation --type fx.phase_delay --id Stage2 --parent ResonantLoop --agent
hise-cli dsp add --module PhaseFXRecreation --type fx.phase_delay --id Stage3 --parent ResonantLoop --agent
hise-cli dsp add --module PhaseFXRecreation --type fx.phase_delay --id Stage4 --parent ResonantLoop --agent
hise-cli dsp add --module PhaseFXRecreation --type fx.phase_delay --id Stage5 --parent ResonantLoop --agent
hise-cli dsp add --module PhaseFXRecreation --type fx.phase_delay --id Stage6 --parent ResonantLoop --agent
hise-cli dsp set --module PhaseFXRecreation --node ResonantLoop_fb_in --index 7 --agent
hise-cli dsp set --module PhaseFXRecreation --node ResonantLoop --index 0 --agent
hise-cli dsp set --module PhaseFXRecreation --node PhaseMix --param DryWet --value 0.75 --agent
hise-cli dsp set --module PhaseFXRecreation --node ResonantLoop_fb_out --param Feedback --range "0,0.99" --agent
hise-cli dsp set --module PhaseFXRecreation --node ResonantLoop_fb_out --param Feedback --value 0.7 --agent
hise-cli dsp set --module PhaseFXRecreation --node SweepRange --param Minimum --range "20,20000" --agent
hise-cli dsp set --module PhaseFXRecreation --node SweepRange --param Maximum --range "20,20000" --agent
hise-cli dsp set --module PhaseFXRecreation --node SweepRange --param Minimum --value 400 --agent
hise-cli dsp set --module PhaseFXRecreation --node SweepRange --param Maximum --value 1600 --agent
hise-cli dsp connect --module PhaseFXRecreation --source PhaseMod --target SweepRange --param Value --agent
hise-cli dsp connect --module PhaseFXRecreation --source SweepRange --target Stage1 --param Frequency --agent
hise-cli dsp connect --module PhaseFXRecreation --source SweepRange --target Stage2 --param Frequency --agent
hise-cli dsp connect --module PhaseFXRecreation --source SweepRange --target Stage3 --param Frequency --agent
hise-cli dsp connect --module PhaseFXRecreation --source SweepRange --target Stage4 --param Frequency --agent
hise-cli dsp connect --module PhaseFXRecreation --source SweepRange --target Stage5 --param Frequency --agent
hise-cli dsp connect --module PhaseFXRecreation --source SweepRange --target Stage6 --param Frequency --agent
hise-cli dsp connect --module PhaseFXRecreation --source phase_fx_recreation --source-param Mix --target PhaseMix --param DryWet --matched --agent
hise-cli dsp connect --module PhaseFXRecreation --source phase_fx_recreation --source-param Feedback --target ResonantLoop_fb_out --param Feedback --matched --agent
hise-cli dsp connect --module PhaseFXRecreation --source phase_fx_recreation --source-param Frequency1 --target SweepRange --param Minimum --matched --agent
hise-cli dsp connect --module PhaseFXRecreation --source phase_fx_recreation --source-param Frequency2 --target SweepRange --param Maximum --matched --agent
```
