# envelope.ahdsr - HSC Construction Artifact

## Source
- Phase 2: `scriptnode_enrichment/hsc/phase2/envelope/ahdsr.md`
- Reference: `scriptnode_enrichment/output/envelope/ahdsr.md`

## Status
- Built in HISE: true
- User approved: true
- Notes: Built as a Script Envelope Modulator on a SineSynth gain modulation chain.

## Naming
- Module ID: `ScriptEnvelopeAhdsr`
- Network ID: `script_envelope_ahdsr`

## Builder Setup Applied
- Host context: `Script Envelope`
- Additional builder steps applied: added a SineSynth host and attached the Script Envelope Modulator to its Gain Modulation chain.
- Channel/routing setup verified: default stereo control signal routing.

## Verified Parameters
- `MainEnvelope.Attack` = `10`, range `[1, 200]`
- `MainEnvelope.Decay` = `300`, range `[40, 800]`
- `MainEnvelope.Sustain` = `0.5`, range `[0.2, 0.9]`
- `MainEnvelope.Release` = `160`, range `[20, 500]`

## Verified Connections
- `script_envelope_ahdsr.Attack -> MainEnvelope.Attack` matched
- `script_envelope_ahdsr.Decay -> MainEnvelope.Decay` matched
- `script_envelope_ahdsr.Sustain -> MainEnvelope.Sustain` matched
- `script_envelope_ahdsr.Release -> MainEnvelope.Release` matched
- `MainEnvelope.Gate -> VoiceKill.Kill Voice` (HSC-only named parameter)

## Optimized Public Shell Commands

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type SineSynth --id EnvelopeHost --agent
hise-cli builder add --type ScriptEnvelopeModulator --id ScriptEnvelopeAhdsr --parent EnvelopeHost --chain "Gain Modulation" --agent
hise-cli builder set --module ScriptEnvelopeAhdsr --network script_envelope_ahdsr --agent
hise-cli dsp add --module ScriptEnvelopeAhdsr --type math.fill1 --id EnvelopeSeed --agent
hise-cli dsp add --module ScriptEnvelopeAhdsr --type envelope.ahdsr --id MainEnvelope --agent
hise-cli dsp add --module ScriptEnvelopeAhdsr --type envelope.voice_manager --id VoiceKill --agent
hise-cli dsp create_parameter --module ScriptEnvelopeAhdsr --container script_envelope_ahdsr --id Attack --range "1,200" --default 10 --agent
hise-cli dsp create_parameter --module ScriptEnvelopeAhdsr --container script_envelope_ahdsr --id Decay --range "40,800" --default 300 --agent
hise-cli dsp create_parameter --module ScriptEnvelopeAhdsr --container script_envelope_ahdsr --id Sustain --range "0.2,0.9" --default 0.5 --agent
hise-cli dsp create_parameter --module ScriptEnvelopeAhdsr --container script_envelope_ahdsr --id Release --range "20,500" --default 160 --agent
hise-cli dsp connect --module ScriptEnvelopeAhdsr --source script_envelope_ahdsr --source-param Attack --target MainEnvelope --param Attack --matched --agent
hise-cli dsp connect --module ScriptEnvelopeAhdsr --source script_envelope_ahdsr --source-param Decay --target MainEnvelope --param Decay --matched --agent
hise-cli dsp connect --module ScriptEnvelopeAhdsr --source script_envelope_ahdsr --source-param Sustain --target MainEnvelope --param Sustain --matched --agent
hise-cli dsp connect --module ScriptEnvelopeAhdsr --source script_envelope_ahdsr --source-param Release --target MainEnvelope --param Release --matched --agent
```

## Key rules
- Generate a constant signal with `math.fill1` and use the envelope as a control signal.
- Connect the Gate output to `VoiceKill.Kill Voice` for proper voice lifecycle cleanup.
