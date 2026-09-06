# envelope.silent_killer - HSC Construction Artifact

## Source
- Phase 2: `scriptnode_enrichment/hsc/phase2/envelope/silent_killer.md`
- Reference: `scriptnode_enrichment/output/envelope/silent_killer.md`

## Status
- Built in HISE: true
- User approved: true
- Notes: Live HISE construction completed successfully.

## Naming
- Module ID: `SilentEnvelopeCleanup`
- Network ID: `silent_envelope_cleanup`

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
hise-cli builder add --type ScriptEnvelopeModulator --id SilentEnvelopeCleanup --parent EnvelopeHost --chain "Gain Modulation" --agent
hise-cli builder set --module SilentEnvelopeCleanup --network silent_envelope_cleanup --agent
hise-cli dsp add --module SilentEnvelopeCleanup --type math.fill1 --id EnvelopeSeed --agent
hise-cli dsp add --module SilentEnvelopeCleanup --type envelope.simple_ar --id ReleaseEnvelope --agent
hise-cli dsp add --module SilentEnvelopeCleanup --type envelope.silent_killer --id SilentCleanup --agent
hise-cli dsp create_parameter --module SilentEnvelopeCleanup --container silent_envelope_cleanup --id CleanupActive --range "0,1" --default 1 --agent
hise-cli dsp connect --module SilentEnvelopeCleanup --source silent_envelope_cleanup --source-param CleanupActive --target SilentCleanup --param Active --matched --agent
```

## Key rules
- Keep lifecycle nodes in a polyphonic envelope or effect context.
- Use explicit gate cleanup when the source exposes a gate; otherwise use silence detection.
