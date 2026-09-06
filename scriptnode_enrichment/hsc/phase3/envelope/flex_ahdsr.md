# envelope.flex_ahdsr - HSC Construction Artifact

## Source
- Phase 2: `scriptnode_enrichment/hsc/phase2/envelope/flex_ahdsr.md`
- Reference: `scriptnode_enrichment/output/envelope/flex_ahdsr.md`

## Status
- Built in HISE: true
- User approved: true
- Notes: Live HISE construction completed successfully.

## Naming
- Module ID: `ScriptEnvelopeFlexAhdsr`
- Network ID: `script_envelope_flex_ahdsr`

## Builder Setup Applied
- Host context: `Script Envelope`
- Additional builder steps applied: topology and lifecycle setup from Phase 2.
- Channel/routing setup verified: default stereo routing.

## Verified Parameters
- Parameters and locked values match the Phase 2 plan and live node metadata.

## Verified Connections
- Public parameter connections match the Phase 4 script.
- Lifecycle output connections were verified live where available.

## Optimized Public Shell Commands

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type SineSynth --id EnvelopeHost --agent
hise-cli builder add --type ScriptEnvelopeModulator --id ScriptEnvelopeFlexAhdsr --parent EnvelopeHost --chain "Gain Modulation" --agent
hise-cli builder set --module ScriptEnvelopeFlexAhdsr --network script_envelope_flex_ahdsr --agent
hise-cli dsp add --module ScriptEnvelopeFlexAhdsr --type math.fill1 --id EnvelopeSeed --agent
hise-cli dsp add --module ScriptEnvelopeFlexAhdsr --type envelope.flex_ahdsr --id FlexEnvelope --agent
hise-cli dsp add --module ScriptEnvelopeFlexAhdsr --type envelope.voice_manager --id VoiceKill --agent
hise-cli dsp create_parameter --module ScriptEnvelopeFlexAhdsr --container script_envelope_flex_ahdsr --id Mode --range "0,2" --default 1 --agent
hise-cli dsp create_parameter --module ScriptEnvelopeFlexAhdsr --container script_envelope_flex_ahdsr --id Attack --range "1,250" --default 5 --agent
hise-cli dsp create_parameter --module ScriptEnvelopeFlexAhdsr --container script_envelope_flex_ahdsr --id Decay --range "20,800" --default 100 --agent
hise-cli dsp create_parameter --module ScriptEnvelopeFlexAhdsr --container script_envelope_flex_ahdsr --id Sustain --range "0.2,0.9" --default 0.5 --agent
hise-cli dsp create_parameter --module ScriptEnvelopeFlexAhdsr --container script_envelope_flex_ahdsr --id Release --range "40,1200" --default 300 --agent
hise-cli dsp connect --module ScriptEnvelopeFlexAhdsr --source script_envelope_flex_ahdsr --source-param Mode --target FlexEnvelope --param Mode --matched --agent
hise-cli dsp connect --module ScriptEnvelopeFlexAhdsr --source script_envelope_flex_ahdsr --source-param Attack --target FlexEnvelope --param Attack --matched --agent
hise-cli dsp connect --module ScriptEnvelopeFlexAhdsr --source script_envelope_flex_ahdsr --source-param Decay --target FlexEnvelope --param Decay --matched --agent
hise-cli dsp connect --module ScriptEnvelopeFlexAhdsr --source script_envelope_flex_ahdsr --source-param Sustain --target FlexEnvelope --param Sustain --matched --agent
hise-cli dsp connect --module ScriptEnvelopeFlexAhdsr --source script_envelope_flex_ahdsr --source-param Release --target FlexEnvelope --param Release --matched --agent
```

## Key rules
- Keep lifecycle nodes in a polyphonic envelope or effect context.
- Use explicit gate cleanup when the source exposes a gate; otherwise use silence detection.
