# control.bipolar - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/control/bipolar.md`
- Reference: `scriptnode_enrichment/output/control/bipolar.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: Centre-preserving vibrato built and verified with a musically meaningful +/-20 cent ratio range.

## Naming

- Module ID: `CentrePreservingVibrato`
- Network ID: `centre_preserving_vibrato`

## Builder Setup Applied

- Host context: `Script FX`
- Additional builder steps applied:
  - Verify fractional values after narrowing `SawTone.Freq Ratio`.
- Channel/routing setup verified:
  - Required channels: `default stereo; LFO uses isolated mono control processing`
  - Module routing: `default`
  - Master routing: `default`

## Verified Parameters

- `TriangleLfo.Mode` = `Triangle` range `0..4`
- `TriangleLfo.Frequency` = `5` range `[0.5..8]`
- `SawTone.Mode` = `Saw`
- `SawTone.Freq Ratio` = `1` range `[0.988514..1.011619]` midpoint `1.0`
- `SymmetricDepth.Scale` range `[0..1]`
- `SymmetricDepth.Gamma` = `1.0` range `[0.5..2]`
- `VibratoDepth` range `[0..1]` default `0.5`

## Verified Connections

- `LfoPeak.0` -> `SymmetricDepth.Value` matched: false (modulation output uses raw normalized values)
- `SymmetricDepth.0` -> `SawTone.Freq Ratio` matched: false, runtime mode `scaled`
- `centre_preserving_vibrato.VibratoDepth` -> `SymmetricDepth.Scale` matched: true

## Trace Validation

- Parameter trace commands:
  - `hise-cli dsp trace --module CentrePreservingVibrato --container centre_preserving_vibrato --inject-param centre_preserving_vibrato.VibratoDepth=0 --probe-param SymmetricDepth.Scale --probe-param SymmetricDepth.Value --probe-param "SawTone.Freq Ratio" --agent`
  - `hise-cli dsp trace --module CentrePreservingVibrato --container centre_preserving_vibrato --inject-param centre_preserving_vibrato.VibratoDepth=1 --probe-param SymmetricDepth.Scale --probe-param SymmetricDepth.Value --probe-param "SawTone.Freq Ratio" --agent`
- Parameter trace evidence:
  - At `VibratoDepth=0`, `SymmetricDepth.Scale=0` and `SawTone.Freq Ratio=1.0`, confirming the neutral midpoint.
  - At `VibratoDepth=1`, the ratio remained in range at `1.0006`; the scaled connection reported `outOfRange=false`.
- Signal trace commands:
  - `hise-cli dsp trace --module CentrePreservingVibrato --container centre_preserving_vibrato --inject dirac --probe-recursive --agent`
- Signal trace evidence:
  - Runtime status was `ok=true`. Recursive trace returned non-silent stereo saw output with peak `1.0065`. `VibratoControl` and `MidiIsolation` used a mono control context at 6000 Hz and 64-sample blocks; the parent remained stereo at 48000 Hz and 512-sample blocks.
- Trace caveats:
  - A single trace block captures the current LFO phase, so it does not necessarily reach both ratio endpoints. The configured target range is the exact +/-20 cent interval.

## Locked Build Values Applied

- `TriangleLfo.Mode` = `Triangle`
- `TriangleLfo.Frequency` range = `[0.5, 8]`
- `TriangleLfo.Frequency` = `5`
- `TriangleLfo.Gate` = `On`
- `SymmetricDepth.Gamma` = `1.0`
- `SawTone.Freq Ratio` range = `[0.988514, 1.011619]`, midpoint `1.0`
- `SawTone.Mode` = `Saw`
- `SawTone.Gate` = `On`

## Interface Script Setup Applied

- None

## Optimized Public Shell Commands

These shell `hise-cli` commands are intended for Phase 4 conversion to public `.hsc`. They must not include `save` or `screenshot`.

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id CentrePreservingVibrato --parent "Master Chain.FX Chain" --agent
hise-cli builder set --module CentrePreservingVibrato --network centre_preserving_vibrato --agent
hise-cli dsp add --module CentrePreservingVibrato --type container.modchain --id VibratoControl --parent centre_preserving_vibrato --agent
hise-cli dsp add --module CentrePreservingVibrato --type container.no_midi --id MidiIsolation --parent VibratoControl --agent
hise-cli dsp add --module CentrePreservingVibrato --type core.oscillator --id TriangleLfo --parent MidiIsolation --agent
hise-cli dsp add --module CentrePreservingVibrato --type math.sig2mod --id Normalise --parent MidiIsolation --agent
hise-cli dsp add --module CentrePreservingVibrato --type core.peak --id LfoPeak --parent MidiIsolation --agent
hise-cli dsp add --module CentrePreservingVibrato --type control.bipolar --id SymmetricDepth --parent centre_preserving_vibrato --agent
hise-cli dsp add --module CentrePreservingVibrato --type core.oscillator --id SawTone --parent centre_preserving_vibrato --agent
hise-cli dsp set --module CentrePreservingVibrato --node TriangleLfo --param Mode --value 2 --agent
hise-cli dsp set --module CentrePreservingVibrato --node TriangleLfo --param Frequency --range "0.5,8" --agent
hise-cli dsp set --module CentrePreservingVibrato --node TriangleLfo --param Frequency --value 5 --agent
hise-cli dsp set --module CentrePreservingVibrato --node SawTone --param Mode --value 1 --agent
hise-cli dsp set --module CentrePreservingVibrato --node SawTone --param "Freq Ratio" --range "0.988514,1.011619" --middlePosition 1.0 --agent
hise-cli dsp set --module CentrePreservingVibrato --node SymmetricDepth --param Scale --range "0,1" --agent
hise-cli dsp set --module CentrePreservingVibrato --node SymmetricDepth --param Gamma --value 1.0 --agent
hise-cli dsp create_parameter --module CentrePreservingVibrato --container centre_preserving_vibrato --id VibratoDepth --range "0,1" --default 0.5 --agent
hise-cli dsp connect --module CentrePreservingVibrato --source LfoPeak --target SymmetricDepth --param Value --agent
hise-cli dsp connect --module CentrePreservingVibrato --source SymmetricDepth --target SawTone --param "Freq Ratio" --agent
hise-cli dsp connect --module CentrePreservingVibrato --source centre_preserving_vibrato --source-param VibratoDepth --target SymmetricDepth --param Scale --matched --agent
hise-cli dsp set --module CentrePreservingVibrato --node SymmetricDepth --param NodeColour --value 0xFF8E44AD --agent
hise-cli dsp set --module CentrePreservingVibrato --node TriangleLfo --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module CentrePreservingVibrato --node LfoPeak --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module CentrePreservingVibrato --node SawTone --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module CentrePreservingVibrato --node MidiIsolation --param Comment --value '\"**Fixed-rate LFO context** - Blocks MIDI so note events cannot retune the triangle oscillator.\"' --agent
hise-cli dsp set --module CentrePreservingVibrato --node SymmetricDepth --param Comment --value '\"**Centre-preserving depth** - Scale controls symmetric deviation around 0.5, which maps to neutral ratio 1.0.\"' --agent
hise-cli dsp set --module CentrePreservingVibrato --node SawTone --param Comment --value '\"**Audible MIDI oscillator** - The ratio range 0.988514..1.011619 represents -20 to +20 cents around midpoint 1.0.\"' --agent
hise-cli dsp set --module CentrePreservingVibrato --node Normalise --param Folded --value true --agent
```

## Pipeline-Only Commands

These commands are not included in public `.hsc`.

```bash
hise-cli dsp status --module CentrePreservingVibrato --agent
hise-cli dsp trace --module CentrePreservingVibrato --container centre_preserving_vibrato --inject dirac --probe-recursive --agent
hise-cli dsp save --module CentrePreservingVibrato --agent
hise-cli dsp screenshot --module CentrePreservingVibrato --scale 200% --output "scriptnode_enrichment/hsc/output/control/bipolar.png" --agent
```

## Comments To Preserve In HSC

- Before `MidiIsolation`: note events must not retune the fixed-rate triangle LFO.
- Before `SymmetricDepth`: Scale zero outputs 0.5, which maps to the neutral ratio 1.0 rather than shifting pitch.
- Before the target connection: use `[0.988514, 1.011619]` for the exact +/-20 cent interval around ratio 1.0.

## Documentation Feedback

- Docs updated:
  - `scriptnode_enrichment/hsc/phase1/control/bipolar.md`: replaced approximate ratio range with equal-temperament +/-20 cent ratios.
  - `scriptnode_enrichment/hsc/phase2/control/bipolar.md`: replaced approximate ratio range and documented the raw peak connection.
- General rules promoted:
  - Use equal-temperament frequency ratios for musically meaningful cent intervals.
- Local-only findings:
  - The LFO trace phase varies between runs, so endpoint validation uses parameter range and midpoint checks.

## Cosmetics Applied

- Main node: `SymmetricDepth` colour `0xFF8E44AD`
- Support nodes: [`TriangleLfo`, `LfoPeak`, `SawTone`] colour `0xFF7F6A91`
- Folded nodes: [`Normalise`]
- ShowParameters containers: []
- Visible target nodes: [`SymmetricDepth`, `TriangleLfo`, `LfoPeak`, `SawTone`]

## Defaults Omitted

- `Normalise.Value` default `0.0`
- `LfoPeak.Value` default `0.0`
- `SymmetricDepth.Scale` default `0.0`
- `SymmetricDepth.Gamma` default `1.0`

## Open Issues

- None
