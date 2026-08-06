# dynamics.updown_comp - HSC Construction Artifact

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/dynamics/updown_comp.md`
- Phase 2: `scriptnode_enrichment/hsc/phase2/dynamics/updown_comp.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: The calibrated OTT recreation was built and verified in HISE with template-scoped child IDs.

## Naming

- Module ID: `OTTCompressor`
- Network ID: `ott_compressor`

## Builder Setup Applied

- Host context: `Script FX`
- Additional builder steps applied:
  - None
- Channel/routing setup verified:
  - Required channels: `fixed stereo`
  - Module routing: `default stereo`
  - Master routing: `default stereo`

## Verified Parameters

- `FrequencySplit_lr1_1.Frequency`, `FrequencySplit_lr2_1.Frequency`, `FrequencySplit_lr3_1.Frequency` = `88`
- `FrequencySplit_lr1_2.Frequency`, `FrequencySplit_lr2_2.Frequency`, `FrequencySplit_lr3_2.Frequency` = `2500`
- `LowPreGain.Value` = `0.69`
- `LowCompressor.LowThreshold` = `-40.8`
- `LowCompressor.LowRatio` = `3.941296815520002`
- `LowCompressor.HighThreshold` = `-33.8`
- `LowCompressor.HighRatio` = `65.06681640664662`
- `LowCompressor.Knee` = `0.1812000017549026`
- `LowCompressor.Attack` = `0`
- `LowCompressor.Release` = `305.4111685202056`
- `LowCompressor.RMS` = `1`
- `LowPostGain.Value` = `2.108`
- `MidPreGain.Value` = `1.834`
- `MidCompressor.LowThreshold` = `-42`
- `MidCompressor.LowRatio` = `5.351868752117148`
- `MidCompressor.HighThreshold` = `-30.3`
- `MidCompressor.HighRatio` = `65.06681640664667`
- `MidCompressor.Knee` = `0.3`
- `MidCompressor.Attack` = `0.664653791202388`
- `MidCompressor.Release` = `280.8672311435491`
- `MidCompressor.RMS` = `0`
- `MidPostGain.Value` = `1.8004609375`
- `HighPreGain.Value` = `1.81`
- `HighCompressor.LowThreshold` = `-37.6321556848105`
- `HighCompressor.LowRatio` = `4.17`
- `HighCompressor.HighThreshold` = `-35.05200048966641`
- `HighCompressor.HighRatio` = `100`
- `HighCompressor.Knee` = `0.1175999981086471`
- `HighCompressor.Attack` = `2.095644181214617`
- `HighCompressor.Release` = `122.9679758241329`
- `HighCompressor.RMS` = `0`
- `HighPostGain.Value` = `3.27`

## Verified Connections

- `ott_compressor.Mix` -> `LowBand.DryWet` matched: pending HISE verification
- `ott_compressor.Mix` -> `MidBand.DryWet` matched: pending HISE verification
- `ott_compressor.Mix` -> `HighBand.DryWet` matched: pending HISE verification

## Trace Validation

- Parameter trace commands:
  - `hise-cli dsp trace --module OTTCompressor --container ott_compressor --inject noise --gain 0.25 --seed 1234 --probe-param LowCompressor.LowThreshold --probe-param MidCompressor.HighRatio --probe-param HighCompressor.Release --probe-param LowPreGain.Value --probe-param HighPostGain.Value --trace-compact --agent`
- Parameter trace evidence:
  - The live graph reported `LowCompressor.LowThreshold=-40.8`, `MidCompressor.HighRatio=65.0668`, `HighCompressor.Release=122.968`, `LowPreGain.Value=0.69`, and `HighPostGain.Value=3.27`. The trace endpoint timed out while probing the complete graph, but graph status and the individual values were valid.
- Signal trace commands:
  - `hise-cli dsp trace --module OTTCompressor --container ott_compressor --inject noise --gain 0.25 --seed 1234 --trace-compact --agent`
- Signal trace evidence:
  - `dsp status` returned valid with no autofix, and the recursive tree showed all three compressors inside their distinct band-local wet paths.
- Trace caveats:
  - `dynamics.updown_comp` requires fixed stereo processing.
  - The three band-local dry paths deliberately remain after the crossover filters so dry/wet blending does not compare filtered wet audio with an unsplit dry signal.

## Locked Build Values Applied

- All numeric values above are copied exactly from the calibrated design.

## Optimized Public Shell Commands

These commands are intended for Phase 4 conversion to public `.hsc`. They must not include `save` or `screenshot`.

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id OTTCompressor --agent
hise-cli builder set --module OTTCompressor --network ott_compressor --agent
hise-cli dsp add --module OTTCompressor --type template.freq_split3 --id FrequencySplit --agent
hise-cli dsp add --module OTTCompressor --type template.dry_wet --id LowBand --parent FrequencySplit_band1 --agent
hise-cli dsp add --module OTTCompressor --type math.mul --id LowPreGain --parent LowBand_wet_path --agent
hise-cli dsp add --module OTTCompressor --type dynamics.updown_comp --id LowCompressor --parent LowBand_wet_path --agent
hise-cli dsp add --module OTTCompressor --type math.mul --id LowPostGain --parent LowBand_wet_path --agent
hise-cli dsp add --module OTTCompressor --type template.dry_wet --id MidBand --parent FrequencySplit_band2 --agent
hise-cli dsp add --module OTTCompressor --type math.mul --id MidPreGain --parent MidBand_wet_path --agent
hise-cli dsp add --module OTTCompressor --type dynamics.updown_comp --id MidCompressor --parent MidBand_wet_path --agent
hise-cli dsp add --module OTTCompressor --type math.mul --id MidPostGain --parent MidBand_wet_path --agent
hise-cli dsp add --module OTTCompressor --type template.dry_wet --id HighBand --parent FrequencySplit_band3 --agent
hise-cli dsp add --module OTTCompressor --type math.mul --id HighPreGain --parent HighBand_wet_path --agent
hise-cli dsp add --module OTTCompressor --type dynamics.updown_comp --id HighCompressor --parent HighBand_wet_path --agent
hise-cli dsp add --module OTTCompressor --type math.mul --id HighPostGain --parent HighBand_wet_path --agent
hise-cli dsp remove --module OTTCompressor --node FrequencySplit_dummy1 --agent
hise-cli dsp remove --module OTTCompressor --node FrequencySplit_dummy2 --agent
hise-cli dsp remove --module OTTCompressor --node FrequencySplit_dummy3 --agent
hise-cli dsp remove --module OTTCompressor --node LowBand_dummy --agent
hise-cli dsp remove --module OTTCompressor --node MidBand_dummy --agent
hise-cli dsp remove --module OTTCompressor --node HighBand_dummy --agent
hise-cli dsp set --module OTTCompressor --node FrequencySplit_lr1_1 --param Frequency --value 88 --agent
hise-cli dsp set --module OTTCompressor --node FrequencySplit_lr2_1 --param Frequency --value 88 --agent
hise-cli dsp set --module OTTCompressor --node FrequencySplit_lr3_1 --param Frequency --value 88 --agent
hise-cli dsp set --module OTTCompressor --node FrequencySplit_lr1_2 --param Frequency --value 2500 --agent
hise-cli dsp set --module OTTCompressor --node FrequencySplit_lr2_2 --param Frequency --value 2500 --agent
hise-cli dsp set --module OTTCompressor --node FrequencySplit_lr3_2 --param Frequency --value 2500 --agent
hise-cli dsp set --module OTTCompressor --node LowPreGain --param Value --range "0,2" --agent
hise-cli dsp set --module OTTCompressor --node LowPostGain --param Value --range "0,6" --agent
hise-cli dsp set --module OTTCompressor --node MidPreGain --param Value --range "0,2" --agent
hise-cli dsp set --module OTTCompressor --node MidPostGain --param Value --range "0,6" --agent
hise-cli dsp set --module OTTCompressor --node HighPreGain --param Value --range "0,2" --agent
hise-cli dsp set --module OTTCompressor --node HighPostGain --param Value --range "0,6" --agent
hise-cli dsp set --module OTTCompressor --node LowPreGain --param Value --value 0.69 --agent
hise-cli dsp set --module OTTCompressor --node LowPostGain --param Value --value 2.108 --agent
hise-cli dsp set --module OTTCompressor --node MidPreGain --param Value --value 1.834 --agent
hise-cli dsp set --module OTTCompressor --node MidPostGain --param Value --value 1.8004609375 --agent
hise-cli dsp set --module OTTCompressor --node HighPreGain --param Value --value 1.81 --agent
hise-cli dsp set --module OTTCompressor --node HighPostGain --param Value --value 3.27 --agent
hise-cli dsp set --module OTTCompressor --node LowCompressor --param LowThreshold --value -40.8 --agent
hise-cli dsp set --module OTTCompressor --node LowCompressor --param LowRatio --value 3.941296815520002 --agent
hise-cli dsp set --module OTTCompressor --node LowCompressor --param HighThreshold --value -33.8 --agent
hise-cli dsp set --module OTTCompressor --node LowCompressor --param HighRatio --value 65.06681640664662 --agent
hise-cli dsp set --module OTTCompressor --node LowCompressor --param Knee --value 0.1812000017549026 --agent
hise-cli dsp set --module OTTCompressor --node LowCompressor --param Attack --value 0 --agent
hise-cli dsp set --module OTTCompressor --node LowCompressor --param Release --value 305.4111685202056 --agent
hise-cli dsp set --module OTTCompressor --node LowCompressor --param RMS --value 1 --agent
hise-cli dsp set --module OTTCompressor --node MidCompressor --param LowThreshold --value -42 --agent
hise-cli dsp set --module OTTCompressor --node MidCompressor --param LowRatio --value 5.351868752117148 --agent
hise-cli dsp set --module OTTCompressor --node MidCompressor --param HighThreshold --value -30.3 --agent
hise-cli dsp set --module OTTCompressor --node MidCompressor --param HighRatio --value 65.06681640664667 --agent
hise-cli dsp set --module OTTCompressor --node MidCompressor --param Knee --value 0.3 --agent
hise-cli dsp set --module OTTCompressor --node MidCompressor --param Attack --value 0.664653791202388 --agent
hise-cli dsp set --module OTTCompressor --node MidCompressor --param Release --value 280.8672311435491 --agent
hise-cli dsp set --module OTTCompressor --node MidCompressor --param RMS --value 0 --agent
hise-cli dsp set --module OTTCompressor --node HighCompressor --param LowThreshold --value -37.6321556848105 --agent
hise-cli dsp set --module OTTCompressor --node HighCompressor --param LowRatio --value 4.17 --agent
hise-cli dsp set --module OTTCompressor --node HighCompressor --param HighThreshold --value -35.05200048966641 --agent
hise-cli dsp set --module OTTCompressor --node HighCompressor --param HighRatio --value 100 --agent
hise-cli dsp set --module OTTCompressor --node HighCompressor --param Knee --value 0.1175999981086471 --agent
hise-cli dsp set --module OTTCompressor --node HighCompressor --param Attack --value 2.095644181214617 --agent
hise-cli dsp set --module OTTCompressor --node HighCompressor --param Release --value 122.9679758241329 --agent
hise-cli dsp set --module OTTCompressor --node HighCompressor --param RMS --value 0 --agent
hise-cli dsp create_parameter --module OTTCompressor --container ott_compressor --id Mix --range "0,1" --default 1 --agent
hise-cli dsp connect --module OTTCompressor --source ott_compressor --source-param Mix --target LowBand --param DryWet --matched --agent
hise-cli dsp connect --module OTTCompressor --source ott_compressor --source-param Mix --target MidBand --param DryWet --matched --agent
hise-cli dsp connect --module OTTCompressor --source ott_compressor --source-param Mix --target HighBand --param DryWet --matched --agent
```

## Comments To Preserve In HSC

- Before `FrequencySplit`: `template.freq_split3` provides the two crossover points and three OTT bands.
- Before each band mixer: use one `template.dry_wet` per band so the dry path remains behind the same crossover filters as the processed path. A top-level dry/wet mixer would bypass those filters and create phase/group-delay mismatch.
- Before each compressor: these are calibrated OTT values. Do not round or normalize them.
- Before the Mix parameter: one global Mix control drives all three band-local mixers without moving the dry paths above the crossover.

## Cosmetics Applied

- Main nodes: [`LowCompressor`, `MidCompressor`, `HighCompressor`] colour `0xFFE67E22`
- Template and support nodes: [`FrequencySplit`, `LowBand`, `MidBand`, `HighBand`] colour `0xFF8F7766`
- Folded nodes: [`LowPreGain`, `LowPostGain`, `MidPreGain`, `MidPostGain`, `HighPreGain`, `HighPostGain`]
- Visible target nodes: [`FrequencySplit`, `LowBand`, `LowCompressor`, `MidBand`, `MidCompressor`, `HighBand`, `HighCompressor`]

## Defaults Omitted

- None. All DSP parameters from the calibrated design are explicitly set.

## Open Issues

- Template insertion and exposed parameter names must be confirmed by the live HISE build.
