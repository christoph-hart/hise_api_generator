# envelope.voice_manager - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/envelope/voice_manager.md`
- Reference: `scriptnode_enrichment/output/envelope/voice_manager.md`

## Naming

- Module ID: `GateBasedVoiceCleanup`
- Network ID: `gate_based_voice_cleanup`

## Graph Plan

```text
gate_based_voice_cleanup
  EnvelopeSeed          math.fill1
  MainEnvelope          envelope.ahdsr
  VoiceKill             envelope.voice_manager
```

## Builder Setup

- Host context: `Script Envelope`
- Additional builder steps:
  - Create a HISE Script Envelope module and build this network inside it.
- Channel/routing setup:
  - Required channels: default stereo inside the Script Envelope; the graph carries a duplicated modulation signal and a gate side-output
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: [voice manager is lifecycle-only and should not be treated as an audio processor]

## Public Parameters

- None

## Defaults To Omit

- `EnvelopeSeed.Value` default `0.0`

## Locked Build Values

- None

## Friction Comments To Weave In

- Before the modulation connection to `VoiceKill.Kill Voice`: the default value of 1.0 never kills a voice, so the gate hookup is the whole point of the node.
- Before the graph explanation: do not route audio through `VoiceKill`; it is control-only lifecycle logic.

## Cosmetic Plan

- Main node: `VoiceKill`
- Accent colour: `0xFF8E44AD`
- Supporting relevant nodes: [`EnvelopeSeed`, `MainEnvelope`]
- Supporting colour: `0xFF7F6A91`
- Folded nodes: []
- Nodes that must stay visible: [`EnvelopeSeed`, `MainEnvelope`, `VoiceKill`]

## Open Questions

- None
