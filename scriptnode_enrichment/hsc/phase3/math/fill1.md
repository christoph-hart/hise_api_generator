# math.fill1 - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/math/fill1.md`
- Reference: `scriptnode_enrichment/output/math/fill1.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: Live HISE build completed successfully inside a Script Envelope Modulator attached to a SineSynth host.

## Naming

- Module ID: `EnvelopeSeedSource`
- Network ID: `envelope_seed_source`

## Builder Setup Applied

- Host context: `Script Envelope`
- Additional builder steps applied: `SineSynth` host with `ScriptEnvelopeModulator` in its Gain Modulation chain
- Channel/routing setup verified: single-channel control-rate envelope output

## Verified Parameters

- `ShapeEnvelope.Attack` = `10`
- `ShapeEnvelope.Release` = `180`, range `40..500`
- `ShapeEnvelope.Gate` = `1`
- `Release` = `180`, range `40..500`

## Verified Connections

- `Release` -> `ShapeEnvelope.Release`, matched: true

## Optimized Public Shell Commands

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

## Comments To Preserve In HSC

- `math.fill1` discards its input and replaces it with a constant `1.0` source.
- This is an envelope-style control-signal example, not an oscillator patch.
- Clear the shaped control signal before it can leak to the audio output.

## Cosmetics

- Main node: `EnvelopeSeed`, colour `0xFF2F80ED`
- Supporting node: `ShapeEnvelope`, colour `0xFF6F8FAF`
- Folded nodes: `SignalClear`
- Visible nodes: `EnvelopeSeed`, `ShapeEnvelope`
