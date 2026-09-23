# container.chain - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/container/chain.md`
- Reference: `scriptnode_enrichment/output/container/chain.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: The nested serial chain and mono modulation chain were verified live. A `control.pma` inversion stage was added so the shared ascending Sweep macro can open the filter while lowering output gain without an invalid reversed macro range.

## Naming

- Module ID: `NestedMacroChain`
- Network ID: `nested_macro_chain`

## Builder Setup Applied

- Host context: `Script FX`
- Additional builder steps applied:
  - Added `GainInverter` after live inspection showed that directly reversing the Gain range also reversed the shared Sweep source range.
- Channel/routing setup verified:
  - Required channels: `default stereo; SweepControl uses an isolated mono control buffer`
  - Module routing: `default stereo`
  - Master routing: `default stereo`

## Verified Parameters

- `SweepRamp.PeriodTime` = `2000` range `0.1..2000` stepSize `0.1`
- `FilterAndLevel.Sweep` = `0` range `0..1` stepSize `0`
- `GainInverter.Value` = `0` range `0..1` stepSize `0`
- `GainInverter.Multiply` = `-1` range `-1..1` stepSize `0`
- `GainInverter.Add` = `1` range `-1..1` stepSize `0`
- `MovingFilter.Frequency` = `1000` range `200..8000` stepSize `0`
- `MovingFilter.Smoothing` = `0.02` range `0..1` stepSize `0`
- `OutputLevel.Gain` = `0` range `-12..-3` stepSize `0.1`

## Verified Connections

- `SweepPeak.0` -> `FilterAndLevel.Sweep` matched: false
- `FilterAndLevel.Sweep` -> `MovingFilter.Frequency` matched: false
- `FilterAndLevel.Sweep` -> `GainInverter.Value` matched: false
- `GainInverter.0` -> `OutputLevel.Gain` matched: false

## Trace Validation

- Parameter trace commands:
  - `hise-cli dsp trace --module NestedMacroChain --container nested_macro_chain --inject noise --gain 0.25 --seed 1234 --probe-recursive --probe-param FilterAndLevel.Sweep --probe-param GainInverter.Value --probe-param MovingFilter.Frequency --probe-param OutputLevel.Gain --trace-compact --agent`
- Parameter trace evidence:
  - `SweepPeak` exported `0.4927` to `FilterAndLevel.Sweep`; `GainInverter.Value` also received `0.4927`.
  - The same Sweep state mapped to `MovingFilter.Frequency=559.0326` and, after PMA inversion, `OutputLevel.Gain=-4.0589`.
- Signal trace commands:
  - `hise-cli dsp trace --module NestedMacroChain --container nested_macro_chain --inject noise --gain 0.25 --seed 1234 --probe-recursive --probe-param FilterAndLevel.Sweep --probe-param GainInverter.Value --probe-param MovingFilter.Frequency --probe-param OutputLevel.Gain --trace-compact --agent`
- Signal trace evidence:
  - `SweepControl` ran at 6 kHz, one channel, and 64-sample blocks; its generated ramp did not enter the root stereo signal.
  - `FilterAndLevel` ran at 48 kHz, two channels, and 512-sample blocks. Noise reached `MovingFilter` and then `OutputLevel` serially, with final traced ranges around `-0.0281..0.0203`.
- Trace caveats:
  - The filter Frequency range retains its logarithmic skew, so a Sweep value near `0.5` does not map to the arithmetic midpoint in Hz.
  - This is control-rate modulation, not sample-accurate modulation.

## Locked Build Values Applied

- `SweepRamp.PeriodTime` range = `0.1..2000`
- `SweepRamp.PeriodTime` = `2000`
- `GainInverter.Multiply` = `-1`
- `GainInverter.Add` = `1`
- `MovingFilter.Mode` = `LowPass` by default
- `MovingFilter.Smoothing` = `0.02`
- `FilterAndLevel.Sweep` range = `0..1`
- `MovingFilter.Frequency` range = `200..8000`
- `OutputLevel.Gain` range = `-12..-3`

## Interface Script Setup Applied

- None

## Optimized Public Shell Commands

These shell `hise-cli` commands are intended for Phase 4 conversion to public `.hsc`. They must not include `save` or `screenshot`.

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id NestedMacroChain --agent
hise-cli builder set --module NestedMacroChain --network nested_macro_chain --agent

hise-cli dsp add --module NestedMacroChain --type container.modchain --id SweepControl --agent
hise-cli dsp add --module NestedMacroChain --type core.ramp --id SweepRamp --parent SweepControl --agent
hise-cli dsp add --module NestedMacroChain --type core.peak --id SweepPeak --parent SweepControl --agent
hise-cli dsp add --module NestedMacroChain --type container.chain --id FilterAndLevel --agent
hise-cli dsp add --module NestedMacroChain --type control.pma --id GainInverter --parent FilterAndLevel --agent
hise-cli dsp add --module NestedMacroChain --type filters.svf --id MovingFilter --parent FilterAndLevel --agent
hise-cli dsp add --module NestedMacroChain --type core.gain --id OutputLevel --parent FilterAndLevel --agent

hise-cli dsp set --module NestedMacroChain --node SweepRamp --param PeriodTime --range "0.1,2000" --agent
hise-cli dsp set --module NestedMacroChain --node SweepRamp --param PeriodTime --value 2000 --agent
hise-cli dsp set --module NestedMacroChain --node GainInverter --param Multiply --value -1 --agent
hise-cli dsp set --module NestedMacroChain --node GainInverter --param Add --value 1 --agent
hise-cli dsp set --module NestedMacroChain --node MovingFilter --param Smoothing --value 0.02 --agent
hise-cli dsp set --module NestedMacroChain --node MovingFilter --param Frequency --range "200,8000" --agent
hise-cli dsp set --module NestedMacroChain --node OutputLevel --param Gain --range "-12,-3" --agent

hise-cli dsp create_parameter --module NestedMacroChain --container FilterAndLevel --id Sweep --range "0,1" --default 0 --agent
hise-cli dsp connect --module NestedMacroChain --source FilterAndLevel --source-param Sweep --target MovingFilter --param Frequency --agent
hise-cli dsp connect --module NestedMacroChain --source FilterAndLevel --source-param Sweep --target GainInverter --param Value --agent
hise-cli dsp connect --module NestedMacroChain --source GainInverter --target OutputLevel --param Gain --agent
hise-cli dsp connect --module NestedMacroChain --source SweepPeak --target FilterAndLevel --param Sweep --agent

hise-cli dsp set --module NestedMacroChain --node FilterAndLevel --param NodeColour --value 0xFF2F80ED --agent
hise-cli dsp set --module NestedMacroChain --node FilterAndLevel --param Comment --value '"**Nested macro chain** - Sweep fans one normalised control value out to cutoff and inverse output level."' --agent
hise-cli dsp set --module NestedMacroChain --node SweepControl --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module NestedMacroChain --node SweepControl --param Comment --value '"The modchain generates a mono control ramp without leaking it into the audible stereo path."' --agent
hise-cli dsp set --module NestedMacroChain --node SweepPeak --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module NestedMacroChain --node GainInverter --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module NestedMacroChain --node GainInverter --param Comment --value '"Invert Sweep before gain mapping so the level falls while the filter opens."' --agent
hise-cli dsp set --module NestedMacroChain --node MovingFilter --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module NestedMacroChain --node OutputLevel --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module NestedMacroChain --node SweepRamp --param Folded --value true --agent
```

## Pipeline-Only Commands

These commands are not included in public `.hsc`.

```bash
hise-cli dsp save --module NestedMacroChain --agent
hise-cli dsp screenshot --module NestedMacroChain --scale 200% --output "scriptnode_enrichment/hsc/output/container/chain.png" --agent
```

## Comments To Preserve In HSC

- Before `SweepControl`: The modchain keeps its generated ramp out of the audible stereo path.
- Before `FilterAndLevel.Sweep`: The nested macro is the modulation boundary and fans one source out to two targets.
- Before `GainInverter`: Invert Sweep with PMA instead of reversing the shared macro range.
- Before the gain connection: The PMA inversion lowers output as the filter opens.

## Documentation Feedback

- Docs updated:
  - `scriptnode_enrichment/hsc/phase1/container/chain.md`: Added the verified PMA inversion topology.
  - `scriptnode_enrichment/hsc/phase2/container/chain.md`: Normalized the topology, ranges, comments, and cosmetic plan after live validation.
- General rules promoted:
  - None; the shared-range rule already exists in the style guide through the requirement to use a control combiner or transform when target mappings differ.
- Local-only findings:
  - A direct reversed Gain range also reversed the shared nested macro range, so this example requires an explicit inversion stage.

## Cosmetics Applied

- Main node: `FilterAndLevel` colour `0xFF2F80ED`
- Support nodes: [`SweepControl`, `SweepPeak`, `GainInverter`, `MovingFilter`, `OutputLevel`] colour `0xFF6F8FAF`
- Folded nodes: [`SweepRamp`]
- Visible target nodes: [`SweepControl`, `FilterAndLevel`, `SweepPeak`, `GainInverter`, `MovingFilter`, `OutputLevel`]

## Defaults Omitted

- `GainInverter.Value` default `0`
- `MovingFilter.Mode` default `LowPass`
- `MovingFilter.Q` default `1`
- `OutputLevel.Smoothing` default `20`

## Open Issues

- None
