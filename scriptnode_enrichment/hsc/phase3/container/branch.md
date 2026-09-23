# container.branch - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/container/branch.md`
- Reference: `scriptnode_enrichment/output/container/branch.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: The three expression branches were verified independently after the math.expr runtime fix. Mode selects exactly one immediate, non-crossfaded transfer function.

## Naming

- Module ID: `SelectableWaveshaper`
- Network ID: `selectable_waveshaper`

## Builder Setup Applied

- Host context: `Script FX`
- Additional builder steps applied:
  - Setting the first expression Code caused HISE to enable network compilation automatically.
- Channel/routing setup verified:
  - Required channels: `default stereo`
  - Module routing: `default stereo`
  - Master routing: `default stereo`

## Verified Parameters

- `selectable_waveshaper.Mode` = `0` range `0..2` stepSize `1`
- `ShapeModes.Index` = `0` range `0..2` stepSize `1`
- `TanhShape.Value` = `0.5` range `0..1` stepSize `0`
- `HiseSaturation.Value` = `0.75` range `0..1` stepSize `0`
- `SineFold.Value` = `0.5` range `0..1` stepSize `0`

## Verified Connections

- `selectable_waveshaper.Mode` -> `ShapeModes.Index` matched: true

## Trace Validation

- Parameter trace commands:
  - `hise-cli dsp trace --module SelectableWaveshaper --container selectable_waveshaper --inject-param selectable_waveshaper.Mode=2 --probe-param ShapeModes.Index --trace-compact --agent`
- Parameter trace evidence:
  - Injecting `Mode=2` probed `ShapeModes.Index=2`, confirming the matched root parameter connection.
- Signal trace commands:
  - `hise-cli dsp trace --module SelectableWaveshaper --container selectable_waveshaper --inject dirac --gain 0.5 --inject-param selectable_waveshaper.Mode=0 --probe-after ShapeModes --trace-compact --agent`
  - `hise-cli dsp trace --module SelectableWaveshaper --container selectable_waveshaper --inject dirac --gain 0.5 --inject-param selectable_waveshaper.Mode=1 --probe-after ShapeModes --trace-compact --agent`
  - `hise-cli dsp trace --module SelectableWaveshaper --container selectable_waveshaper --inject dirac --gain 0.5 --inject-param selectable_waveshaper.Mode=2 --probe-after ShapeModes --trace-compact --agent`
- Signal trace evidence:
  - A `0.5` Dirac input produced stereo peaks of `0.9414` for TanhShape, `0.8` for HiseSaturation, and `0.5985` for SineFold.
  - All traces reported stereo, 48 kHz, 512-sample blocks, monophonic processing, and no MIDI processing.
- Trace caveats:
  - Branch switching is immediate and does not crossfade.

## Locked Build Values Applied

- `TanhShape.Code` = `Math.tanh(input * (1.0f + value * 5.0f))`
- `TanhShape.Value` = `0.5`
- `HiseSaturation.Code` = `(1.0f + value / (1.0f - value)) * input / (1.0f + value / (1.0f - value) * Math.abs(input))`
- `HiseSaturation.Value` = `0.75`
- `SineFold.Code` = `Math.sin(input * (1.0f + value * 8.0f))`
- `SineFold.Value` = `0.5`
- Branch child order = `TanhShape`, `HiseSaturation`, `SineFold`

## Interface Script Setup Applied

- None

## Optimized Public Shell Commands

These shell `hise-cli` commands are intended for Phase 4 conversion to public `.hsc`. They must not include `save` or `screenshot`.

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id SelectableWaveshaper --agent
hise-cli builder set --module SelectableWaveshaper --network selectable_waveshaper --agent

hise-cli dsp add --module SelectableWaveshaper --type container.branch --id ShapeModes --agent
hise-cli dsp add --module SelectableWaveshaper --type math.expr --id TanhShape --parent ShapeModes --agent
hise-cli dsp add --module SelectableWaveshaper --type math.expr --id HiseSaturation --parent ShapeModes --agent
hise-cli dsp add --module SelectableWaveshaper --type math.expr --id SineFold --parent ShapeModes --agent

hise-cli dsp set --module SelectableWaveshaper --node TanhShape --param Code --value '"Math.tanh(input * (1.0f + value * 5.0f))"' --agent
hise-cli dsp set --module SelectableWaveshaper --node TanhShape --param Value --value 0.5 --agent
hise-cli dsp set --module SelectableWaveshaper --node HiseSaturation --param Code --value '"(1.0f + value / (1.0f - value)) * input / (1.0f + value / (1.0f - value) * Math.abs(input))"' --agent
hise-cli dsp set --module SelectableWaveshaper --node HiseSaturation --param Value --value 0.75 --agent
hise-cli dsp set --module SelectableWaveshaper --node SineFold --param Code --value '"Math.sin(input * (1.0f + value * 8.0f))"' --agent
hise-cli dsp set --module SelectableWaveshaper --node SineFold --param Value --value 0.5 --agent
hise-cli dsp set --module SelectableWaveshaper --node ShapeModes --param Index --range "0,2" --stepSize 1 --agent

hise-cli dsp create_parameter --module SelectableWaveshaper --container selectable_waveshaper --id Mode --range "0,2" --default 0 --stepSize 1 --agent
hise-cli dsp connect --module SelectableWaveshaper --source selectable_waveshaper --source-param Mode --target ShapeModes --param Index --matched --agent
# Expose Index so the root Mode cable is visible on the inner container.
hise-cli dsp set --module SelectableWaveshaper --node ShapeModes --param ShowParameters --value true --agent

hise-cli dsp set --module SelectableWaveshaper --node ShapeModes --param NodeColour --value 0xFFE67E22 --agent
hise-cli dsp set --module SelectableWaveshaper --node ShapeModes --param Comment --value '"**Selectable waveshaper** - Only the child selected by Mode processes audio; switching is immediate without a crossfade."' --agent
hise-cli dsp set --module SelectableWaveshaper --node TanhShape --param NodeColour --value 0xFF8C6D55 --agent
hise-cli dsp set --module SelectableWaveshaper --node TanhShape --param Comment --value '"Tanh transfer with a locked amount for a consistent algorithm comparison."' --agent
hise-cli dsp set --module SelectableWaveshaper --node HiseSaturation --param NodeColour --value 0xFF8C6D55 --agent
hise-cli dsp set --module SelectableWaveshaper --node HiseSaturation --param Comment --value '"HISE-style rational saturation with a locked amount."' --agent
hise-cli dsp set --module SelectableWaveshaper --node SineFold --param NodeColour --value 0xFF8C6D55 --agent
hise-cli dsp set --module SelectableWaveshaper --node SineFold --param Comment --value '"Sine folding transfer with a locked amount."' --agent
```

## Pipeline-Only Commands

These commands are not included in public `.hsc`.

```bash
hise-cli dsp save --module SelectableWaveshaper --agent
hise-cli dsp screenshot --module SelectableWaveshaper --scale 200% --output "scriptnode_enrichment/hsc/output/container/branch.png" --agent
```

## Comments To Preserve In HSC

- Before `ShapeModes`: Only the selected prepared child processes audio, and Index switches immediately without a crossfade.
- Before the expression values: Lock each amount so Mode compares transfer functions rather than unrelated gain settings.

## Documentation Feedback

- Docs updated:
  - None
- General rules promoted:
  - None
- Local-only findings:
  - Setting the first math.expr Code automatically enabled network compilation in the live CLI workflow.

## Cosmetics Applied

- Main node: `ShapeModes` colour `0xFFE67E22`
- Support nodes: [`TanhShape`, `HiseSaturation`, `SineFold`] colour `0xFF8C6D55`
- Folded nodes: []
- ShowParameters containers: [`ShapeModes`]
- Visible target nodes: [`ShapeModes`, `TanhShape`, `HiseSaturation`, `SineFold`]

## Defaults Omitted

- `ShapeModes.Index` default `0`

## Open Issues

- None
