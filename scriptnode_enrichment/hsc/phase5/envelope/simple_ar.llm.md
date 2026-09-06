---
id: envelope.simple_ar.timer-gated-ar
node: envelope.simple_ar
domain: scriptnode
category: dsp-network
title: Timer-gated attack release modulator
summary: Uses a timer to gate a simple attack-release envelope inside a modulation chain.
useCase: Use this for periodic internal modulation in a ScriptFX.
difficulty: intermediate
aliases:
  - timer gated AR
networkName: timer_gated_ar_modulator
moduleType: ScriptFX
moduleId: TimerGatedArModulator
tags:
  - envelope
  - modulation
  - timer
relatedNodes:
  - envelope.simple_ar
  - container.modchain
  - control.timer
parameters:
  Attack: Attack time.
  Release: Release time.
  PulseRate: Timer interval mapping.
---
scriptnode example: envelope.simple_ar

Timer-gated internal AR modulator

A lightweight attack-release envelope with curve shaping and a fixed sustain at full level.

Context:
  A monophonic Script FX needs a small internal modulation pulse for a DSP parameter, independent of incoming MIDI notes. A `control.timer` periodically drives the `Gate` parameter of `envelope.simple_ar` inside a `container.modchain`, while `math.fill1` supplies the constant 1.0 signal that the envelope shapes.

Use this when:
  Demonstrate how `envelope.simple_ar` can be used as a manually gated attack/release shaper for internal modulation inside a Script FX network.

Graph:
```text
timer_gated_ar_modulator
  InternalModHost       container.modchain
    PulseTimer          control.timer
    EnvelopeSeed        math.fill1
    ArEnvelope          envelope.simple_ar
  ModTarget             core.gain
```

Host:
  Module: TimerGatedArModulator
  Network: timer_gated_ar_modulator
  Host context: Script FX
  Additional builder steps applied: used the corrected `container.modchain` factory and `control.timer.Interval` parameter.
  Channel/routing setup verified: default stereo routing.

Support nodes:
  Required: container.modchain, math.fill1, control.timer
  Optional: core.gain
  `container.modchain` demonstrates an internal modulation setup in a monophonic Script FX context. `control.timer` drives the manual Gate input, and `math.fill1` provides the static signal that becomes the AR-shaped modulation source.

Public controls:
  - Attack -> `ArEnvelope.Attack` matched
  - Target range before connection: `[1, 150]`
  - Macro range: `[1, 150]`
  - Default: `10`
  - Release -> `ArEnvelope.Release` matched
  - Target range before connection: `[20, 400]`
  - Macro range: `[20, 400]`
  - Default: `120`
  - AttackCurve -> `ArEnvelope.AttackCurve` matched
  - Target range before connection: `[0.0, 1.0]`
  - Macro range: `[0.0, 1.0]`
  - Default: `0.0`
  - PulseRate -> `PulseTimer.Interval` matched
  - Target range before connection: `[125, 2000]`
  - Macro range: `[125, 2000]`
  - Default: `500`

Verified connections:
  - `PulseTimer -> ArEnvelope.Gate`
  - `timer_gated_ar_modulator.Attack -> ArEnvelope.Attack` matched
  - `timer_gated_ar_modulator.Release -> ArEnvelope.Release` matched
  - `timer_gated_ar_modulator.AttackCurve -> ArEnvelope.AttackCurve` matched
  - `timer_gated_ar_modulator.PulseRate -> PulseTimer.Interval` matched
  - `ArEnvelope -> ModTarget.Gain`

Key rules:
  - Use container.modchain and control.timer.Interval.

Common mistakes:
  - Sustain is always at full level: This envelope has only two stages: attack (ramp to 1.0) and release (ramp to 0.0). There is no sustain parameter.
  - Default AttackCurve differs from AHDSR: Unlike the AHDSR envelope where 0.5 is the default (linear), simple_ar defaults to 0.0 (exponential). Adjust to 0.5 for linear attack behaviour.

HISE CLI build commands:
```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id TimerGatedArModulator --agent
hise-cli builder set --module TimerGatedArModulator --network timer_gated_ar_modulator --agent
hise-cli dsp add --module TimerGatedArModulator --type container.modchain --id InternalModHost --agent
hise-cli dsp add --module TimerGatedArModulator --type control.timer --id PulseTimer --parent InternalModHost --agent
hise-cli dsp set --module TimerGatedArModulator --node PulseTimer --param Interval --range "125,2000" --agent
hise-cli dsp set --module TimerGatedArModulator --node PulseTimer --param Interval --value 500 --agent
hise-cli dsp add --module TimerGatedArModulator --type math.fill1 --id EnvelopeSeed --parent InternalModHost --agent
hise-cli dsp add --module TimerGatedArModulator --type envelope.simple_ar --id ArEnvelope --parent InternalModHost --agent
hise-cli dsp add --module TimerGatedArModulator --type core.gain --id ModTarget --agent
hise-cli dsp create_parameter --module TimerGatedArModulator --container timer_gated_ar_modulator --id Attack --range "1,150" --default 10 --agent
hise-cli dsp create_parameter --module TimerGatedArModulator --container timer_gated_ar_modulator --id Release --range "20,400" --default 120 --agent
hise-cli dsp create_parameter --module TimerGatedArModulator --container timer_gated_ar_modulator --id AttackCurve --range "0,1" --default 0 --agent
hise-cli dsp create_parameter --module TimerGatedArModulator --container timer_gated_ar_modulator --id PulseRate --range "125,2000" --default 500 --agent
hise-cli dsp connect --module TimerGatedArModulator --source PulseTimer --target ArEnvelope --param Gate --agent
hise-cli dsp connect --module TimerGatedArModulator --source timer_gated_ar_modulator --source-param Attack --target ArEnvelope --param Attack --matched --agent
hise-cli dsp connect --module TimerGatedArModulator --source timer_gated_ar_modulator --source-param Release --target ArEnvelope --param Release --matched --agent
hise-cli dsp connect --module TimerGatedArModulator --source timer_gated_ar_modulator --source-param AttackCurve --target ArEnvelope --param AttackCurve --matched --agent
hise-cli dsp connect --module TimerGatedArModulator --source timer_gated_ar_modulator --source-param PulseRate --target PulseTimer --param Interval --matched --agent
hise-cli dsp connect --module TimerGatedArModulator --source ArEnvelope --target ModTarget --param Gain --agent
```
