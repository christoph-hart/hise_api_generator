# envelope.voice_manager - HSC Construction Artifact

## Source
- Phase 2: `scriptnode_enrichment/hsc/phase2/envelope/voice_manager.md`
- Reference: `scriptnode_enrichment/output/envelope/voice_manager.md`

## Status
- Built in HISE: true
- User approved: true
- Notes: Live HISE construction completed successfully.

## Naming
- Module ID: `GateBasedVoiceCleanup`
- Network ID: `gate_based_voice_cleanup`

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
hise-cli builder add --type ScriptEnvelopeModulator --id GateBasedVoiceCleanup --parent EnvelopeHost --chain "Gain Modulation" --agent
hise-cli builder set --module GateBasedVoiceCleanup --network gate_based_voice_cleanup --agent
hise-cli dsp add --module GateBasedVoiceCleanup --type math.fill1 --id EnvelopeSeed --agent
hise-cli dsp add --module GateBasedVoiceCleanup --type envelope.ahdsr --id MainEnvelope --agent
hise-cli dsp add --module GateBasedVoiceCleanup --type envelope.voice_manager --id VoiceKill --agent
hise-cli dsp connect --module GateBasedVoiceCleanup --source MainEnvelope --source-output Gate --target VoiceKill --param 'Kill Voice' --agent
```

## Key rules
- Keep lifecycle nodes in a polyphonic envelope or effect context.
- Use explicit gate cleanup when the source exposes a gate; otherwise use silence detection.
