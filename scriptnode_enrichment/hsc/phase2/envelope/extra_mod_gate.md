# envelope.extra_mod_gate - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/envelope/extra_mod_gate.md`
- Reference: `scriptnode_enrichment/output/envelope/extra_mod_gate.md`

## Naming

- Module ID: `ExtraModCleanup`
- Network ID: `extra_mod_cleanup`

## Graph Plan

```text
extra_mod_cleanup
  ExtraModHost          container.modchain
    ExtraModValue       core.extra_mod
    ExtraEnvelopeGate   envelope.extra_mod_gate
    VoiceKill           envelope.voice_manager
```

## Builder Setup

- Host context: `PolyScriptFX`
- Additional builder steps:
  - Create a polyphonic Script FX module before building the graph.
  - Configure one extra modulation slot for that module type.
  - Create a root parameter with `ExternalModulation Combined` before adding `core.extra_mod`.
- Channel/routing setup:
  - Required channels: default stereo in a polyphonic Script FX context; the node's lifecycle logic is per-voice rather than channel-topology driven
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: [polyphonic Script FX context is required so the extra modulation gate reports per-voice release state]

## Public Parameters

- ModInput -> external modulation slot `0`
- Target range before connection: `[0, 1]`
- Macro range: `[0, 1]`
- Default: `1`
- External modulation mode: `Combined`

## Defaults To Omit

- `VoiceKill.Kill Voice` default `1.0`

## Locked Build Values

- `ExtraModValue.Index` = `0`
- `ExtraEnvelopeGate.Index` = `0`
- `ExtraModValue.ProcessSignal` = `Enabled`

## Friction Comments To Weave In

- Before `ExtraModHost`: build this in a polyphonic Script FX, not a monophonic utility network.
- Before the paired `Index` assignments: `core.extra_mod` and `envelope.extra_mod_gate` must both monitor slot `0`, the only slot enabled by `HISE_NUM_SCRIPTNODE_FX_MODS=1`.
- Before `set ExtraModValue.ProcessSignal`: enable `ProcessSignal` so `core.extra_mod` writes the raw extra-mod chain to the signal path and the effect behaves as a gain modulator.
- Before the runtime target hookup: this example depends on an actual extra modulation chain feeding the selected slot; otherwise the gate stays active.

## Cosmetic Plan

- Main node: `ExtraEnvelopeGate`
- Accent colour: `0xFF8E44AD`
- Supporting relevant nodes: [`ExtraModValue`, `VoiceKill`]
- Supporting colour: `0xFF7F6A91`
- Folded nodes: []
- Nodes that must stay visible: [`ExtraModHost`, `ExtraModValue`, `ExtraEnvelopeGate`, `VoiceKill`]

## Open Questions

- None
