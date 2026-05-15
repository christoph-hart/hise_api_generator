# envelope.ahdsr - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/envelope/ahdsr.md`
- Reference: `scriptnode_enrichment/output/envelope/ahdsr.md`

## Naming

- Module ID: `ScriptEnvelopeAhdsr`
- Network ID: `script_envelope_ahdsr`

## Graph Plan

```text
script_envelope_ahdsr
  EnvelopeSeed          math.fill1
  MainEnvelope          envelope.ahdsr
  VoiceKill             envelope.voice_manager
```

## Builder Setup

- Host context: `Script Envelope`
- Additional builder steps:
  - Create a HISE Script Envelope module and build this network inside it.
- Channel/routing setup:
  - Required channels: default stereo inside the Script Envelope; the graph carries a duplicated modulation signal rather than an audio voice path
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: [Script Envelope control signal on normal stereo lanes, gate output used for lifecycle rather than audio]

## Public Parameters

- Attack -> `MainEnvelope.Attack` matched
- Target range before connection: `[1, 200]`
- Macro range: `[1, 200]`
- Default: `10`
- Decay -> `MainEnvelope.Decay` matched
- Target range before connection: `[40, 800]`
- Macro range: `[40, 800]`
- Default: `300`
- Sustain -> `MainEnvelope.Sustain` matched
- Target range before connection: `[0.2, 0.9]`
- Macro range: `[0.2, 0.9]`
- Default: `0.5`
- Release -> `MainEnvelope.Release` matched
- Target range before connection: `[20, 500]`
- Macro range: `[20, 500]`
- Default: `160`

## Defaults To Omit

- `EnvelopeSeed.Value` default `0.0`
- `MainEnvelope.AttackLevel` default `1.0`
- `MainEnvelope.AttackCurve` default `0.5`
- `MainEnvelope.Retrigger` default `Off`
- `MainEnvelope.Gate` default `Off`

## Locked Build Values

- None

## Friction Comments To Weave In

- Before `EnvelopeSeed`: this is the standard Script Envelope pattern where a constant 1.0 signal is shaped into the module's output.
- Before the modulation connection to `VoiceKill.Kill Voice`: wire the envelope Gate output into voice management or the example never demonstrates proper voice cleanup.

## Cosmetic Plan

- Main node: `MainEnvelope`
- Accent colour: `0xFF8E44AD`
- Supporting relevant nodes: [`EnvelopeSeed`, `VoiceKill`]
- Supporting colour: `0xFF7F6A91`
- Folded nodes: []
- Nodes that must stay visible: [`EnvelopeSeed`, `MainEnvelope`, `VoiceKill`]

## Open Questions

- None
