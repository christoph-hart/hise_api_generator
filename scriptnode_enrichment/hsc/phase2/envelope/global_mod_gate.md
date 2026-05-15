# envelope.global_mod_gate - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/envelope/global_mod_gate.md`
- Reference: `scriptnode_enrichment/output/envelope/global_mod_gate.md`

## Naming

- Module ID: `GlobalModCleanup`
- Network ID: `global_mod_cleanup`

## Graph Plan

```text
global_mod_cleanup
  GlobalModValue        core.global_mod
  GlobalEnvelopeGate    envelope.global_mod_gate
  VoiceKill             envelope.voice_manager
```

## Builder Setup

- Host context: `HISE global mod setup`
- Additional builder steps:
  - Add a `GlobalModulatorContainer` in HISE before building the scriptnode graph.
  - Add one `AHDSR` envelope modulator to that container.
- Channel/routing setup:
  - Required channels: default stereo; the gate logic is about per-voice global envelope state rather than channel routing
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: []

## Public Parameters

- None

## Defaults To Omit

- `VoiceKill.Kill Voice` default `1.0`

## Locked Build Values

- `GlobalModValue.Index` = `0`
- `GlobalEnvelopeGate.Index` = `0`

## Friction Comments To Weave In

- Before the global-mod setup: create a `GlobalModulatorContainer` with an `AHDSR` first, because this example depends on a real envelope-type global modulator.
- Before the paired `Index` notes: `core.global_mod` and `envelope.global_mod_gate` both stay at index `0` so they reference the first envelope in the container.
- Before the modulation connection to `VoiceKill.Kill Voice`: the gate output is the lifecycle signal; `core.global_mod` provides the continuous companion value.

## Cosmetic Plan

- Main node: `GlobalEnvelopeGate`
- Accent colour: `0xFF8E44AD`
- Supporting relevant nodes: [`GlobalModValue`, `VoiceKill`]
- Supporting colour: `0xFF7F6A91`
- Folded nodes: []
- Nodes that must stay visible: [`GlobalModValue`, `GlobalEnvelopeGate`, `VoiceKill`]

## Open Questions

- None
