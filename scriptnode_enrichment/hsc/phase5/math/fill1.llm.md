---
id: math.fill1.envelope-seed-source
node: math.fill1
domain: scriptnode
category: dsp-network
title: Envelope seed source
summary: Uses math.fill1 to provide a constant 1.0 source for an envelope-style control signal.
useCase: Use this to create a constant modulation source that can be shaped by a downstream envelope.
difficulty: beginner
networkName: envelope_seed_source
moduleType: ScriptEnvelopeModulator
moduleId: EnvelopeSeedSource
tags:
  - constant
  - dc-source
  - envelope
aliases:
  - fill one source
  - constant envelope seed
relatedNodes:
  - math.fill1
  - envelope.simple_ar
  - math.clear
parameters:
  Release: Public envelope release control connected to ShapeEnvelope.Release.
  EnvelopeSeed.Value: Unused interface parameter; math.fill1 always writes 1.0.
---

scriptnode example: math.fill1

Envelope seed source.
Use this to show why `math.fill1` exists: it discards incoming audio and creates a constant 1.0 control source for envelope shaping inside a Script Envelope Modulator.

Graph:
```text
envelope_seed_source
  EnvelopeSeed          math.fill1
  ShapeEnvelope         envelope.simple_ar
  SignalClear           math.clear
```

Host:
  Module: `EnvelopeSeedSource`
  Type: `ScriptEnvelopeModulator`
  Network: `envelope_seed_source`
  Builder setup: add a `SineSynth` named `EnvelopeHost`, add `ScriptEnvelopeModulator` as `EnvelopeSeedSource` to its Gain Modulation chain, then set its network to `envelope_seed_source`.

Support nodes:
  Required: `envelope.simple_ar`, `math.clear`

Key rules:
  - `math.fill1` replaces the input with a constant 1.0 source.
  - Treat the signal as an envelope-style control source, not an oscillator.
  - Clear the shaped signal before it reaches the audio output.

Public controls:
  - `Release` -> `ShapeEnvelope.Release`, matched, range `40..500`, default `180`

HISE CLI build commands:
```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type SineSynth --id EnvelopeHost --agent
hise-cli builder add --type ScriptEnvelopeModulator --id EnvelopeSeedSource --parent EnvelopeHost --chain "Gain Modulation" --agent
hise-cli builder set --module EnvelopeSeedSource --network envelope_seed_source --agent
hise-cli dsp add --module EnvelopeSeedSource --type math.fill1 --id EnvelopeSeed --agent
hise-cli dsp add --module EnvelopeSeedSource --type envelope.simple_ar --id ShapeEnvelope --agent
hise-cli dsp set --module EnvelopeSeedSource --node ShapeEnvelope --param Attack --value 10 --agent
hise-cli dsp set --module EnvelopeSeedSource --node ShapeEnvelope --param Release --range "40,500" --stepSize 1 --agent
hise-cli dsp set --module EnvelopeSeedSource --node ShapeEnvelope --param Release --value 180 --agent
hise-cli dsp set --module EnvelopeSeedSource --node ShapeEnvelope --param Gate --value 1 --agent
hise-cli dsp add --module EnvelopeSeedSource --type math.clear --id SignalClear --agent
hise-cli dsp create_parameter --module EnvelopeSeedSource --container envelope_seed_source --id Release --range "40,500" --default 180 --agent
hise-cli dsp connect --module EnvelopeSeedSource --source envelope_seed_source --source-param Release --target ShapeEnvelope --param Release --matched --agent
```
