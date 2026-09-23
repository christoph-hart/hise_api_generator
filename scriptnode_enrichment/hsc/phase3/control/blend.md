# control.blend - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/control/blend.md`
- Reference: `scriptnode_enrichment/output/control/blend.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: Noise branch updated with sample-and-hold and long smoother stages to make the humanised motion audible.

## Naming

- Module ID: `HumanisedLfoBlend`
- Network ID: `humanised_lfo_blend`

## Builder Setup Applied

- Host context: `Script FX`
- Additional builder steps applied:
  - None
- Channel/routing setup verified:
  - Required channels: `default stereo; both sources are isolated in a mono modchain`
  - Module routing: `default`
  - Master routing: `default`

## Verified Parameters

- `SineLfo.Mode` = `Sine`
- `SineLfo.Frequency` = `0.5` range `[0.1..5]`
- `NoiseSource.Mode` = `Noise`
- `sampleandhold.Counter` = `412` range `[1..1000]`
- `smoother.SmoothingTime` = `772.6` range `[0.1..2000]`
- `MovingFilter.Frequency` range `[250..7000]` skewed
- `MovingFilter.Mode` = `LowPass`
- `MovingFilter.Smoothing` = `0.03`
- `HumaniseBlend.Alpha` range `[0..1]`
- `Humanise` range `[0..1]` default `0.35`
- `CutoffNormalise.Value` range `[0..1]`

## Verified Connections

- `SinePeak.0` -> `HumaniseBlend.Value1` matched: false (modulation output)
- `NoisePeak.0` -> `HumaniseBlend.Value2` matched: false (modulation output)
- `HumaniseBlend.0` -> `CutoffNormalise.Value` matched: false
- `CutoffNormalise.0` -> `MovingFilter.Frequency` matched: false, runtime mode `scaled`
- `humanised_lfo_blend.Humanise` -> `HumaniseBlend.Alpha` matched: true

## Trace Validation

- Parameter trace commands:
  - `hise-cli dsp trace --module HumanisedLfoBlend --container humanised_lfo_blend --inject-param humanised_lfo_blend.Humanise=0 --probe-param HumaniseBlend.Alpha --probe-param HumaniseBlend.Value1 --probe-param HumaniseBlend.Value2 --probe-param CutoffNormalise.Value --probe-param MovingFilter.Frequency --agent`
  - `hise-cli dsp trace --module HumanisedLfoBlend --container humanised_lfo_blend --inject-param humanised_lfo_blend.Humanise=1 --probe-param HumaniseBlend.Alpha --probe-param HumaniseBlend.Value1 --probe-param HumaniseBlend.Value2 --probe-param CutoffNormalise.Value --probe-param MovingFilter.Frequency --agent`
- Parameter trace evidence:
  - At `Humanise=0`, `HumaniseBlend.Alpha=0`, the blend equals `Value1=0.0648` and maps to `MovingFilter.Frequency=250.7369 Hz` with `outOfRange=false`.
  - At `Humanise=1`, `HumaniseBlend.Alpha=1`, the blend equals `Value2=0.511` and maps to `MovingFilter.Frequency=970.0179 Hz` with `outOfRange=false`.
- Signal trace commands:
  - `hise-cli dsp trace --module HumanisedLfoBlend --container humanised_lfo_blend --inject dirac --probe-recursive --agent`
- Signal trace evidence:
  - Runtime status was `ok=true`. Recursive trace returned non-silent stereo output with peak `1.3634`. The noise branch showed sample-and-hold output followed by smoother output, and both control wrappers used a mono 6000 Hz, 64-sample context.
- Trace caveats:
  - Random noise and LFO phase vary between trace runs. Endpoint checks validate source selection and mapping rather than fixed source values.

## Locked Build Values Applied

- `SineLfo.Mode` = `Sine`
- `SineLfo.Frequency` range = `[0.1, 5]`
- `SineLfo.Frequency` = `0.5`
- `NoiseSource.Mode` = `Noise`
- `sampleandhold.Counter` = `412`
- `smoother.SmoothingTime` range = `[0.1, 2000]`
- `smoother.SmoothingTime` = `772.6`
- `MovingFilter.Frequency` range = `[250, 7000]`, skewed
- `MovingFilter.Mode` = `LowPass`
- `MovingFilter.Smoothing` = `0.03`

## Interface Script Setup Applied

- None

## Optimized Public Shell Commands

These shell `hise-cli` commands are intended for Phase 4 conversion to public `.hsc`. They must not include `save` or `screenshot`.

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id HumanisedLfoBlend --parent "Master Chain.FX Chain" --agent
hise-cli builder set --module HumanisedLfoBlend --network humanised_lfo_blend --agent
hise-cli dsp add --module HumanisedLfoBlend --type container.modchain --id ModulationSources --parent humanised_lfo_blend --agent
hise-cli dsp add --module HumanisedLfoBlend --type container.split --id SourceSplit --parent ModulationSources --agent
hise-cli dsp add --module HumanisedLfoBlend --type container.no_midi --id RegularMotion --parent SourceSplit --agent
hise-cli dsp add --module HumanisedLfoBlend --type core.oscillator --id SineLfo --parent RegularMotion --agent
hise-cli dsp add --module HumanisedLfoBlend --type math.sig2mod --id SineNormalise --parent RegularMotion --agent
hise-cli dsp add --module HumanisedLfoBlend --type core.peak --id SinePeak --parent RegularMotion --agent
hise-cli dsp add --module HumanisedLfoBlend --type container.no_midi --id RandomMotion --parent SourceSplit --agent
hise-cli dsp add --module HumanisedLfoBlend --type core.oscillator --id NoiseSource --parent RandomMotion --agent
hise-cli dsp add --module HumanisedLfoBlend --type fx.sampleandhold --id sampleandhold --parent RandomMotion --agent
hise-cli dsp add --module HumanisedLfoBlend --type core.smoother --id smoother --parent RandomMotion --agent
hise-cli dsp add --module HumanisedLfoBlend --type math.sig2mod --id NoiseNormalise --parent RandomMotion --agent
hise-cli dsp add --module HumanisedLfoBlend --type core.peak --id NoisePeak --parent RandomMotion --agent
hise-cli dsp add --module HumanisedLfoBlend --type control.blend --id HumaniseBlend --parent ModulationSources --agent
hise-cli dsp add --module HumanisedLfoBlend --type control.normaliser --id CutoffNormalise --parent humanised_lfo_blend --agent
hise-cli dsp add --module HumanisedLfoBlend --type filters.svf --id MovingFilter --parent humanised_lfo_blend --agent
hise-cli dsp set --module HumanisedLfoBlend --node SineLfo --param Mode --value 0 --agent
hise-cli dsp set --module HumanisedLfoBlend --node SineLfo --param Frequency --range "0.1,5" --agent
hise-cli dsp set --module HumanisedLfoBlend --node SineLfo --param Frequency --value 0.5 --agent
hise-cli dsp set --module HumanisedLfoBlend --node NoiseSource --param Mode --value 4 --agent
hise-cli dsp set --module HumanisedLfoBlend --node sampleandhold --param Counter --value 412 --agent
hise-cli dsp set --module HumanisedLfoBlend --node smoother --param SmoothingTime --range "0.1,2000" --agent
hise-cli dsp set --module HumanisedLfoBlend --node smoother --param SmoothingTime --value 772.6 --agent
hise-cli dsp set --module HumanisedLfoBlend --node MovingFilter --param Frequency --range "250,7000" --skewFactor 0.3 --agent
hise-cli dsp set --module HumanisedLfoBlend --node MovingFilter --param Mode --value LP --agent
hise-cli dsp set --module HumanisedLfoBlend --node MovingFilter --param Smoothing --value 0.03 --agent
hise-cli dsp set --module HumanisedLfoBlend --node HumaniseBlend --param Alpha --range "0,1" --agent
hise-cli dsp set --module HumanisedLfoBlend --node CutoffNormalise --param Value --range "0,1" --agent
hise-cli dsp create_parameter --module HumanisedLfoBlend --container humanised_lfo_blend --id Humanise --range "0,1" --default 0.35 --agent
hise-cli dsp connect --module HumanisedLfoBlend --source SinePeak --target HumaniseBlend --param Value1 --agent
hise-cli dsp connect --module HumanisedLfoBlend --source NoisePeak --target HumaniseBlend --param Value2 --agent
hise-cli dsp connect --module HumanisedLfoBlend --source HumaniseBlend --target CutoffNormalise --param Value --agent
hise-cli dsp connect --module HumanisedLfoBlend --source CutoffNormalise --target MovingFilter --param Frequency --agent
hise-cli dsp connect --module HumanisedLfoBlend --source humanised_lfo_blend --source-param Humanise --target HumaniseBlend --param Alpha --matched --agent
hise-cli dsp set --module HumanisedLfoBlend --node HumaniseBlend --param NodeColour --value 0xFF8E44AD --agent
hise-cli dsp set --module HumanisedLfoBlend --node SineLfo --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module HumanisedLfoBlend --node NoiseSource --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module HumanisedLfoBlend --node sampleandhold --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module HumanisedLfoBlend --node smoother --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module HumanisedLfoBlend --node MovingFilter --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module HumanisedLfoBlend --node CutoffNormalise --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module HumanisedLfoBlend --node SourceSplit --param Comment --value '\"**Independent control branches** - Each branch receives its own copy before its value is exported.\"' --agent
hise-cli dsp set --module HumanisedLfoBlend --node RandomMotion --param Comment --value '\"**Humanised noise motion** - Sample-and-hold reduces updates and the long smoother time turns them into slow drift.\"' --agent
hise-cli dsp set --module HumanisedLfoBlend --node HumaniseBlend --param Comment --value '\"**Linear humanise blend** - Alpha 0 selects sine, Alpha 1 selects filtered noise, and intermediate values interpolate linearly.\"' --agent
hise-cli dsp set --module HumanisedLfoBlend --node CutoffNormalise --param Comment --value '\"**Cutoff range bridge** - Converts the raw 0..1 blend output for the 250..7000 Hz filter range.\"' --agent
hise-cli dsp set --module HumanisedLfoBlend --node SineNormalise --param Folded --value true --agent
hise-cli dsp set --module HumanisedLfoBlend --node SinePeak --param Folded --value true --agent
hise-cli dsp set --module HumanisedLfoBlend --node NoiseNormalise --param Folded --value true --agent
hise-cli dsp set --module HumanisedLfoBlend --node NoisePeak --param Folded --value true --agent
```

## Pipeline-Only Commands

These commands are not included in public `.hsc`.

```bash
hise-cli dsp status --module HumanisedLfoBlend --agent
hise-cli dsp trace --module HumanisedLfoBlend --container humanised_lfo_blend --inject dirac --probe-recursive --agent
hise-cli dsp save --module HumanisedLfoBlend --agent
hise-cli dsp screenshot --module HumanisedLfoBlend --scale 200% --output "scriptnode_enrichment/hsc/output/control/blend.png" --agent
```

## Comments To Preserve In HSC

- Before `SourceSplit`: each branch receives its own control buffer copy before results are exported.
- Before `RandomMotion`: sample-and-hold reduces random update frequency and the long smoother time turns the steps into slow audible drift.
- Before `HumaniseBlend`: Alpha 0 selects sine exactly, Alpha 1 selects filtered noise exactly, and intermediate values are linear interpolation.
- Before `CutoffNormalise`: the raw blend output must be normalized before targeting the ranged filter frequency.

## Documentation Feedback

- Docs updated:
  - `scriptnode_enrichment/hsc/phase1/control/blend.md`: replaced the one-pole noise stage with sample-and-hold and smoother stages and added the cutoff normalizer.
  - `scriptnode_enrichment/hsc/phase2/control/blend.md`: synchronized the live topology, settings, and cosmetic plan.
- General rules promoted:
  - Raw control outputs require an explicit normalization bridge before a ranged target when trace reports out-of-range values.
- Local-only findings:
  - Noise and LFO trace values vary by run; endpoint tests validate selection and mapping.

## Cosmetics Applied

- Main node: `HumaniseBlend` colour `0xFF8E44AD`
- Support nodes: [`SineLfo`, `NoiseSource`, `sampleandhold`, `smoother`, `CutoffNormalise`, `MovingFilter`] colour `0xFF7F6A91`
- Folded nodes: [`SineNormalise`, `SinePeak`, `NoiseNormalise`, `NoisePeak`]
- ShowParameters containers: []
- Visible target nodes: [`HumaniseBlend`, `SineLfo`, `NoiseSource`, `sampleandhold`, `smoother`, `CutoffNormalise`, `MovingFilter`]

## Defaults Omitted

- `HumaniseBlend.Alpha` default `0.0`
- `HumaniseBlend.Value1` default `0.0`
- `HumaniseBlend.Value2` default `0.0`

## Open Issues

- None
