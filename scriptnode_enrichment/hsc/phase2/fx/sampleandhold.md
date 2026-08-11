# fx.sampleandhold - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/fx/sampleandhold.md`
- Reference: `scriptnode_enrichment/output/fx/sampleandhold.md`

## Naming

- Module ID: `SteppedNoiseTexture`
- Network ID: `stepped_noise_texture`

## Graph Plan

```text
stepped_noise_texture
  NoiseSource      core.oscillator
  StepHolder       fx.sampleandhold
  TextureTrim      core.gain
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - None
- Channel/routing setup:
  - Required channels: default stereo
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: []

## Public Parameters

- Counter -> `StepHolder.Counter` matched
- Target range before connection: `[2, 64]`
- Macro range: `[2, 64]`
- Default: `16`

## Defaults To Omit

- `StepHolder.Counter` default `1`

## Locked Build Values

- `NoiseSource.Mode` = `4` Noise
- `NoiseSource.Gain` = `0.25`
- `StepHolder.Counter.range` = `[2, 64]`
- `StepHolder.Counter.stepSize` = `1`
- `TextureTrim.Gain` = `-12` dB if `core.gain` uses dB units in live CLI; otherwise use the equivalent safe attenuation

## Friction Comments To Weave In

- Before `StepHolder`: `Counter` is the only parameter and means the number of samples held per captured value.
- Before public Counter: Counter `1` is pass-through, so the public range starts at `2` for an audible decimation example.
- Before trace notes: random noise makes exact sample-value assertions inappropriate; verify structure and changed Counter behaviour instead.

## Cosmetic Plan

- Main node: `StepHolder`
- Accent colour: `0xFF2F80ED`
- Supporting relevant nodes: [`NoiseSource`]
- Supporting colour: `0xFF6F8FAF`
- Folded nodes: [`TextureTrim`]
- Nodes that must stay visible: [`NoiseSource`, `StepHolder`]

## Open Questions

- Phase 3 should decide whether a deterministic non-noise source makes validation clearer than the intended noise texture.
