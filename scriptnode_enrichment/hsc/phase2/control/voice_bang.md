# control.voice_bang - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/control/voice_bang.md`
- Reference: `scriptnode_enrichment/output/control/voice_bang.md`

## Naming

- Module ID: `PerVoicePanLatch`
- Network ID: `per_voice_pan_latch`

## Graph Plan

```text
per_voice_pan_latch [polyphonic]
  VoicePanValue          control.voice_bang
  VoiceOscillator        core.oscillator
  VoicePanner            jdsp.jpanner
  VoiceEnvelope          envelope.simple_ar
```

## Builder Setup

- Host context: `Polyphonic Script FX`
- Additional builder steps:
  - Create a Polyphonic Script FX module in a synthesiser voice effect chain; its host context creates the network as polyphonic.
  - Ensure MIDI reaches all children.
  - Hold overlapping notes while changing NextVoicePan.
- Channel/routing setup:
  - Required channels: default stereo in a polyphonic context
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: [polyphonic network required]

## Public Parameters

- NextVoicePan -> `VoicePanValue.Value` with macro range `[-1, 1]` mapped to target `[0, 1]`; default `0`

## Defaults To Omit

- `VoicePanValue.Value` default `0.0`

## Locked Build Values

- Network polyphony = inherited from the `Polyphonic Script FX` host
- `VoicePanValue` output -> `VoicePanner.Pan` range = `[-1, 1]`
- `VoiceOscillator.Mode = Saw`, Gain = `0.2`, Gate = `On`
- `VoicePanner.Rule` = `ConstantPower`
- `VoiceEnvelope.Attack` = `20`; Release = `1000`
- Audio order = oscillator, panner, envelope.

## Friction Comments To Weave In

- Before network creation: voice_bang reports an error outside a polyphonic context.
- Before NextVoicePan: changing Value only updates shared stored state; note-on delivers it to the new voice.
- Before verification: existing voices retain their latched pan while later voices receive the changed value.

## Cosmetic Plan

- Main node: `VoicePanValue`
- Accent colour: `0xFF8E44AD`
- Supporting relevant nodes: [`VoiceOscillator`, `VoicePanner`, `VoiceEnvelope`]
- Supporting colour: `0xFF7F6A91`
- Folded nodes: []
- Nodes that must stay visible: [`VoicePanValue`, `VoiceOscillator`, `VoicePanner`, `VoiceEnvelope`]

## Open Questions

- None
