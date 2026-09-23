# envelope.global_mod_gate - HSC Construction Artifact

## Source
- Phase 2: `scriptnode_enrichment/hsc/phase2/envelope/global_mod_gate.md`
- Reference: `scriptnode_enrichment/output/envelope/global_mod_gate.md`

## Status
- Built in HISE: true
- User approved: true
- Notes: Live HISE construction completed successfully.

## Naming
- Module ID: `GlobalModCleanup`
- Network ID: `global_mod_cleanup`

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
hise-cli builder add --type GlobalModulatorContainer --id GlobalSource --agent
hise-cli builder add --type AHDSR --id GlobalEnvelope --parent GlobalSource --chain "Global Modulators" --agent
hise-cli builder add --type SineSynth --id EnvelopeHost --agent
hise-cli builder add --type ScriptEnvelopeModulator --id GlobalModCleanup --parent EnvelopeHost --chain "Gain Modulation" --agent
hise-cli builder set --module GlobalModCleanup --network global_mod_cleanup --agent
hise-cli dsp add --module GlobalModCleanup --type core.global_mod --id GlobalModValue --agent
hise-cli dsp add --module GlobalModCleanup --type envelope.global_mod_gate --id GlobalEnvelopeGate --agent
hise-cli dsp add --module GlobalModCleanup --type envelope.voice_manager --id VoiceKill --agent
hise-cli dsp connect --module GlobalModCleanup --source GlobalEnvelopeGate --target VoiceKill --param 'Kill Voice' --agent
```

## Key rules
- Keep lifecycle nodes in a polyphonic envelope or effect context.
- Use explicit gate cleanup when the source exposes a gate; otherwise use silence detection.
