# fx.haas - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/fx/haas.md`
- Reference: `scriptnode_enrichment/output/fx/haas.md`

## Naming

- Module ID: `VoiceHaasScatter`
- Network ID: `voice_haas_scatter`

## Graph Plan

```text
voice_haas_scatter
  NoteTrigger      control.voice_bang
  VoicePosition    control.random
  SpreadScale      control.bipolar
  StereoScatter    fx.haas
```

## Builder Setup

- Host context: `PolyScriptFX`
- Additional builder steps:
  - Add a Polyphonic Script FX module (`PolyScriptFX` internally), not a normal Script FX (`ScriptFX`), because the example must process each active voice independently.
  - Place the module in a voice-level/polyphonic FX context when building outside the Playground.
- Channel/routing setup:
  - Required channels: stereo; `fx.haas` requires two channels
  - Module routing: default stereo
  - Master routing: default stereo
  - Channel-specific comments needed: [Haas positioning only works on stereo signal]

## Public Parameters

- Spread -> `SpreadScale.Scale` matched
- Target range before connection: `[0, 1]`
- Macro range: `[0, 1]`
- Default: `0.65`

## Defaults To Omit

- `StereoScatter.Position` default `0`
- `SpreadScale.Value` default `0`
- `SpreadScale.Gamma` default `1`

## Locked Build Values

- `NoteTrigger.Value` = `1`
- `SpreadScale.Scale.range` = `[0, 1]`
- `NoteTrigger` feeds `VoicePosition.Value`
- `VoicePosition` feeds `SpreadScale.Value`
- `Spread` root parameter feeds `SpreadScale.Scale`
- `SpreadScale` feeds `StereoScatter.Position`
- Do not narrow `StereoScatter.Position`; the public Spread control narrows the random range by scaling `SpreadScale` around centre.

## Friction Comments To Weave In

- Before the builder setup: use Polyphonic Script FX; a normal Script FX processes the mixed signal once and cannot demonstrate per-voice Haas positions.
- Before `control.voice_bang`: `control.voice_bang` must live in a polyphonic context because it emits one trigger per note-on voice.
- Before `control.bipolar`: centre and scale the random value before it reaches `fx.haas.Position`; this lets Spread collapse to centre at `0` and reach the full random width at `1` without adding a second direct connection to Position.
- Before `fx.haas`: `fx.haas` is not amplitude panning; it delays one stereo channel by up to 20 ms at full Position.
- Before the Spread macro: drive `SpreadScale.Scale`, not `StereoScatter.Position`, so the random per-voice position remains centred and scalable.

## Cosmetic Plan

- Main node: `StereoScatter`
- Accent colour: `0xFF2F80ED`
- Supporting relevant nodes: [`NoteTrigger`, `VoicePosition`, `SpreadScale`]
- Supporting colour: `0xFF6F8FAF`
- Folded nodes: []
- Nodes that must stay visible: [`NoteTrigger`, `VoicePosition`, `SpreadScale`, `StereoScatter`]

## Open Questions

- Phase 3 must verify the exact builder command for adding the Polyphonic Script FX module (`PolyScriptFX`) and whether additional parent synth setup is required in the current HISE Playground.
