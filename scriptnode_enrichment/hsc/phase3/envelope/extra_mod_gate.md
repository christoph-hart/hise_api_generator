# envelope.extra_mod_gate - HSC Construction Artifact

## Source
- Phase 2: `scriptnode_enrichment/hsc/phase2/envelope/extra_mod_gate.md`
- Reference: `scriptnode_enrichment/output/envelope/extra_mod_gate.md`

## Status
- Built in HISE: true
- User approved: true
- Notes: Live HISE construction completed successfully.

## Naming
- Module ID: `ExtraModCleanup`
- Network ID: `extra_mod_cleanup`

## Builder Setup Applied
- Host context: `PolyScriptFX`
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
hise-cli builder add --type SineSynth --id EffectHost --agent
hise-cli builder add --type PolyScriptFX --id ExtraModCleanup --parent EffectHost --chain "FX Chain" --agent
hise-cli builder set --module ExtraModCleanup --network extra_mod_cleanup --agent
hise-cli dsp create_parameter --module ExtraModCleanup --container extra_mod_cleanup --id ModInput --range "0,1" --default 1 --external-modulation Combined --agent
hise-cli dsp add --module ExtraModCleanup --type container.modchain --id ExtraModHost --agent
hise-cli dsp add --module ExtraModCleanup --type core.extra_mod --id ExtraModValue --parent ExtraModHost --agent
hise-cli dsp add --module ExtraModCleanup --type envelope.extra_mod_gate --id ExtraEnvelopeGate --parent ExtraModHost --agent
hise-cli dsp add --module ExtraModCleanup --type envelope.voice_manager --id VoiceKill --parent ExtraModHost --agent
hise-cli dsp connect --module ExtraModCleanup --source ExtraEnvelopeGate --target VoiceKill --param 'Kill Voice' --agent
```

## Key rules
- Keep lifecycle nodes in a polyphonic envelope or effect context.
- Use explicit gate cleanup when the source exposes a gate; otherwise use silence detection.
