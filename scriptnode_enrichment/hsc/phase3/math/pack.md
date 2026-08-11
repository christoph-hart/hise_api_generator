# math.pack - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/math/pack.md`
- Reference: `scriptnode_enrichment/output/math/pack.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: Live HISE build completed successfully with external SliderPack slot initialization from Interface `onInit`.

## Naming

- Module ID: `SliderPackLookupShaper`
- Network ID: `sliderpack_lookup_shaper`

## Builder Setup Applied

- Host context: `Script FX`
- Additional builder steps applied: None
- Channel/routing setup verified: default stereo routing

## Verified Parameters

- `SlowRamp.PeriodTime` = `1000`
- `PackLookup.SliderPack` complex data = `SliderPack`, slot `0`, data index `0`
- `packData.getNumSliders()` = `8`
- `packData.getValue(1)` = approximately `0.85`
- `packData.getValue(6)` = approximately `0.1`

## Verified Connections

- None

## Trace Validation

- Parameter trace commands:
  - None
- Parameter trace evidence:
  - Interface REPL verified the seeded SliderPack count and values: `packData.getNumSliders() == 8`, `packData.getValue(1) == 0.85`, and `packData.getValue(6) == 0.1`.
- Signal trace commands:
  - `hise-cli dsp trace --module SliderPackLookupShaper --container sliderpack_lookup_shaper --inject dc --gain 0.5 --inject-before PackLookup --probe-after PackLookup --agent`
- Signal trace evidence:
  - DC `0.5` injected directly before `PackLookup` produced `0.45` on both channels, proving the external SliderPack slot is read by `math.pack`.
- Trace caveats:
  - Trace requires the HISE audio engine to be running; otherwise probes can time out before processing executes.

## Locked Build Values Applied

- `SlowRamp.PeriodTime` = `1000`
- `PackLookup.SliderPack` external data index = `0`
- Interface `onInit` creates `packProcessor` with `Synth.getSliderPackProcessor("SliderPackLookupShaper")`
- Interface `onInit` creates `packData` with `packProcessor.getSliderPack(0)`
- SliderPack startup values = `[0.0, 0.85, 0.25, 1.0, 0.45, 0.7, 0.1, 0.55]`

## Interface Script Setup Applied

- `packData.setNumSliders(8)` sets the deterministic lookup resolution.
- `packData.setAllValues([0.0, 0.85, 0.25, 1.0, 0.45, 0.7, 0.1, 0.55])` writes the visible nonlinear shape.

## Optimized Public Shell Commands

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id SliderPackLookupShaper --agent
hise-cli builder set --module SliderPackLookupShaper --network sliderpack_lookup_shaper --agent
hise-cli dsp add --module SliderPackLookupShaper --type core.ramp --id SlowRamp --agent
hise-cli dsp set --module SliderPackLookupShaper --node SlowRamp --param PeriodTime --value 1000 --agent
hise-cli dsp add --module SliderPackLookupShaper --type math.pack --id PackLookup --agent
hise-cli dsp set-complex-data --module SliderPackLookupShaper --node PackLookup --type SliderPack --index 0 --agent
hise-cli dsp add --module SliderPackLookupShaper --type core.peak --id OutputPeak --agent
hise-cli dsp add --module SliderPackLookupShaper --type math.clear --id SignalClear --agent
hise-cli script set --module-id Interface --callback onInit --stdin --agent <<'HISESCRIPT'
Content.makeFrontInterface(600, 600);

const var packProcessor = Synth.getSliderPackProcessor("SliderPackLookupShaper");
const var packData = packProcessor.getSliderPack(0);

packData.setNumSliders(8);
packData.setAllValues([0.0, 0.85, 0.25, 1.0, 0.45, 0.7, 0.1, 0.55]);
HISESCRIPT
```

## Pipeline-Only Commands

```bash
hise-cli dsp save --module SliderPackLookupShaper --agent
hise-cli dsp screenshot --module SliderPackLookupShaper --scale 200% --output "scriptnode_enrichment/hsc/output/math/pack.png" --agent
```

## Comments To Preserve In HSC

- Before `set-complex-data`: this node has no automatable parameters, so the user-facing interaction is the connected SliderPack shape rather than a matched macro.
- Before `set-complex-data`: use an external slot because embedded complex data cannot be initialized from Interface script.

## Documentation Feedback

- Docs updated:
  - None
- General rules promoted:
  - Complex-data examples that need programmatic startup data must use external Table or SliderPack slots plus Interface `onInit` initialization.
- Local-only findings:
  - Trace requires the HISE audio engine to be running.

## Cosmetics Applied

- Main node: `PackLookup` colour `0xFF2F80ED`
- Support nodes: [`SlowRamp`, `OutputPeak`] colour `0xFF6F8FAF`
- Folded nodes: [`SignalClear`]
- Visible target nodes: [`SlowRamp`, `PackLookup`, `OutputPeak`]

## Defaults Omitted

- `OutputPeak.Value` default `0.0`
- `SignalClear.Value` default `0.0`

## Open Issues

- None
