# container.fix64_block - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/container/fix64_block.md`
- Reference: `scriptnode_enrichment/output/container/fix64_block.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: Approved as a slowly evolving filter-tone example using a one-second smoothed parameter transition at a low-overhead 64-sample cadence.

## Naming

- Module ID: `SlowlyEvolvingFilterTone`
- Network ID: `slowly_evolving_filter_tone`

## Builder Setup Applied

- Host context: `Script FX`
- Additional builder steps applied:
  - Injected deterministic stereo noise so cutoff movement remained audible and traceable.
  - Placed the smoother before the filter inside the fixed block container.
  - Disabled filter-side smoothing so only `ToneSmoother` defines the transition.
- Channel/routing setup verified:
  - Required channels: `default stereo`
  - Module routing: `default stereo`
  - Master routing: `default stereo`

## Verified Parameters

- `slowly_evolving_filter_tone.Tone` = `0.25` range `0..1`
- `ToneSmoother.Value` range = `0..1`
- `ToneSmoother.SmoothingTime` = `1000` ms
- `ToneSmoother.Enabled` = `1`
- `ToneSmoother.Mode` property = `Linear Ramp`
- `EvolvingLowPass.Frequency` = `200` range `200..8000`, middle position `1000`
- `EvolvingLowPass.Q` = `0.7`
- `EvolvingLowPass.Smoothing` = `0`
- `EvolvingLowPass.Mode` = `0` (`LowPass`)

## Verified Connections

- `slowly_evolving_filter_tone.Tone` -> `ToneSmoother.Value` matched: true
- `ToneSmoother.0` -> `EvolvingLowPass.Frequency` scaled: true

## Trace Validation

- Parameter trace commands:
  - `hise-cli dsp trace --module SlowlyEvolvingFilterTone --container slowly_evolving_filter_tone --inject noise --gain 0.25 --seed 1234 --inject-param slowly_evolving_filter_tone.Tone=1 --probe-recursive --probe-changed-parameters --trace-compact --agent`
  - `hise-cli dsp trace --module SlowlyEvolvingFilterTone --container slowly_evolving_filter_tone --inject noise --gain 0.25 --seed 1234 --inject-param slowly_evolving_filter_tone.Tone=0 --probe-recursive --probe-changed-parameters --trace-compact --agent`
- Parameter trace evidence:
  - A root jump to Tone `1` left the smoother output at approximately `0.257` during the first host buffer, mapping to cutoff `289.8437` Hz instead of jumping to 8000 Hz.
  - The immediate reverse jump to Tone `0` produced a smoother value near `0.2498` and cutoff near `281.7883` Hz, confirming gradual motion in the opposite direction.
- Signal trace commands:
  - Same recursive deterministic-noise commands as above.
- Signal trace evidence:
  - Root specs reported `sampleRate=48000`, `numChannels=2`, `blockSize=512`.
  - `SixtyFourSampleMotion` reported `blockSize=64`.
  - Both `ToneSmoother` and `EvolvingLowPass` received and processed stereo noise.
  - Filter output remained nonzero during both transition directions.
- Trace caveats:
  - The smoother output changes throughout trace capture, so the probed parameter snapshot and touched-edge value can differ slightly.
  - Sixty-four samples is the maximum child chunk size; a final remainder can be shorter.

## Locked Build Values Applied

- Maximum child chunk size = `64` samples
- Smoothing mode = `Linear Ramp`
- Smoothing time = `1000` ms
- Cutoff range = `200..8000` Hz with middle position `1000` Hz
- Filter smoothing = exactly `0`

## Interface Script Setup Applied

- None

## Optimized Public Shell Commands

These commands are intended for Phase 4 conversion to public `.hsc`. They exclude pipeline-only save and screenshot operations.

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id SlowlyEvolvingFilterTone --agent
hise-cli builder set --module SlowlyEvolvingFilterTone --network slowly_evolving_filter_tone --agent

# Sixty-four samples is the default starting size for adjustable block containers and is sufficient for slow modulation.
hise-cli dsp add --module SlowlyEvolvingFilterTone --type container.fix64_block --id SixtyFourSampleMotion --agent
hise-cli dsp add --module SlowlyEvolvingFilterTone --type control.smoothed_parameter --id ToneSmoother --parent SixtyFourSampleMotion --agent
hise-cli dsp add --module SlowlyEvolvingFilterTone --type filters.svf --id EvolvingLowPass --parent SixtyFourSampleMotion --agent

hise-cli dsp set --module SlowlyEvolvingFilterTone --node ToneSmoother --param Mode --value '"Linear Ramp"' --agent
hise-cli dsp set --module SlowlyEvolvingFilterTone --node ToneSmoother --param SmoothingTime --value 1000 --agent
# Configure the skewed target range before connecting the normalised smoother output.
hise-cli dsp set --module SlowlyEvolvingFilterTone --node EvolvingLowPass --param Frequency --range "200,8000" --middlePosition 1000 --agent
hise-cli dsp set --module SlowlyEvolvingFilterTone --node EvolvingLowPass --param Frequency --value 200 --agent
hise-cli dsp set --module SlowlyEvolvingFilterTone --node EvolvingLowPass --param Q --value 0.7 --agent
# Keep this at zero so only ToneSmoother defines the transition.
hise-cli dsp set --module SlowlyEvolvingFilterTone --node EvolvingLowPass --param Smoothing --value 0 --agent

hise-cli dsp create_parameter --module SlowlyEvolvingFilterTone --container slowly_evolving_filter_tone --id Tone --range "0,1" --default 0.25 --agent
hise-cli dsp connect --module SlowlyEvolvingFilterTone --source slowly_evolving_filter_tone --source-param Tone --target ToneSmoother --param Value --matched --agent
hise-cli dsp connect --module SlowlyEvolvingFilterTone --source ToneSmoother --target EvolvingLowPass --param Frequency --agent

hise-cli dsp set --module SlowlyEvolvingFilterTone --node SixtyFourSampleMotion --param NodeColour --value 0xFF2F80ED --agent
hise-cli dsp set --module SlowlyEvolvingFilterTone --node SixtyFourSampleMotion --param Comment --value '"**Slowly evolving filter tone** - Sixty-four-sample chunks are sufficient for a one-second smoothed cutoff transition with low iteration overhead."' --agent
hise-cli dsp set --module SlowlyEvolvingFilterTone --node ToneSmoother --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module SlowlyEvolvingFilterTone --node ToneSmoother --param Comment --value '"Linear Ramp turns abrupt Tone changes into an exact one-second transition before the filter is updated."' --agent
hise-cli dsp set --module SlowlyEvolvingFilterTone --node EvolvingLowPass --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module SlowlyEvolvingFilterTone --node EvolvingLowPass --param Comment --value '"Its 200 to 8000 Hz range must be configured before connecting; Smoothing remains zero to avoid a second interpolation stage."' --agent
```

## Pipeline-Only Commands

```bash
hise-cli dsp save --module SlowlyEvolvingFilterTone --agent
hise-cli dsp screenshot --module SlowlyEvolvingFilterTone --scale 200% --output "scriptnode_enrichment/hsc/output/container/fix64_block.png" --agent
```

## Comments To Preserve In HSC

- Before `SixtyFourSampleMotion`: Sixty-four samples is a low-overhead default for slowly evolving modulation.
- Before `ToneSmoother`: Linear Ramp reaches its target in exactly 1000 ms.
- Before filter range setup: Configure the target range before connecting the normalized smoother.
- Before filter smoothing: Keep it at zero to avoid stacking a second interpolation stage.
- Before validation: Use noise or another harmonically rich input because silence cannot reveal cutoff movement.

## Documentation Feedback

- Docs updated:
  - `scriptnode_enrichment/hsc/phase1/container/fix64_block.md`: Replaced the additive staircase with a smoothed filter-tone scenario.
  - `scriptnode_enrichment/hsc/phase2/container/fix64_block.md`: Added final values, connections, comments, and cosmetics.
- General rules promoted:
  - None
- Local-only findings:
  - A one-second smoother changes by only a small amount during one host buffer, demonstrating why 64-sample updates are sufficient.

## Cosmetics Applied

- Main node: `SixtyFourSampleMotion` colour `0xFF2F80ED`
- Support nodes: [`ToneSmoother`, `EvolvingLowPass`] colour `0xFF6F8FAF`
- Folded nodes: []
- Visible target nodes: [`SixtyFourSampleMotion`, `ToneSmoother`, `EvolvingLowPass`]

## Defaults Omitted

- `ToneSmoother.Value` default `0`
- `ToneSmoother.Enabled` default `On`
- `EvolvingLowPass.Mode` default `LowPass`
- `EvolvingLowPass.Gain` default `0`
- `EvolvingLowPass.Enabled` default `On`

## Open Issues

- None blocking this artifact.
