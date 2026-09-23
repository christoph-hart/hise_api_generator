# container.clone - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/container/clone.md`
- Reference: `scriptnode_enrichment/output/container/clone.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: Eight physical unison chains were created and confirmed in the UI. Setting the clone container's NumClones value through the CLI performs a special structural rebuild after the first child is complete.

## Naming

- Module ID: `DynamicSawUnison`
- Network ID: `dynamic_saw_unison`

## Builder Setup Applied

- Host context: `Script FX`
- Additional builder steps applied:
  - Built and styled the generated first clone chain before setting `UnisonLayers.NumClones` to `8`.
  - The NumClones CLI value mutation silently rebuilt the first child into eight physical chains.
  - Placed all clone cables in a horizontal `container.offline` control strip.
- Channel/routing setup verified:
  - Required channels: `default stereo`
  - Module routing: `default stereo`
  - Master routing: `default stereo`

## Verified Parameters

- `dynamic_saw_unison.NumClones` = `4` range `1..8` stepSize `1`
- `dynamic_saw_unison.Spread` = `0.5` range `0..1` stepSize `0`
- `UnisonLayers.NumClones` = `8` range `1..8` stepSize `1` during structural construction
- `UnisonLayers.SplitSignal` = `1` range `0..2` stepSize `1`
- `PitchSpread.NumClones` = `1` range `1..8` stepSize `1`
- `PanSpread.NumClones` = `1` range `1..8` stepSize `1`
- `GainCompensation.NumClones` = `1` range `1..8` stepSize `1`
- `GainCompensation.Mode` = `Ducker`
- `SawLayer.Mode` = `1` (`Saw`)
- `SawLayer.Frequency` = `220` range `20..20000` stepSize `0.1`
- `SawLayer.Freq Ratio` = `1` range `0.5..2` stepSize `0`, middle position `1`
- `LayerPan.Pan` = `0` range `-1..1` stepSize `0`
- `LayerPan.Rule` = `2` (`Sine3dB`)

## Verified Connections

- `dynamic_saw_unison.NumClones` -> `UnisonLayers.NumClones` matched: true
- `dynamic_saw_unison.NumClones` -> `PitchSpread.NumClones` matched: true
- `dynamic_saw_unison.NumClones` -> `PanSpread.NumClones` matched: true
- `dynamic_saw_unison.NumClones` -> `GainCompensation.NumClones` matched: true
- `dynamic_saw_unison.Spread` -> `PitchSpread.Value` matched: true
- `dynamic_saw_unison.Spread` -> `PanSpread.Value` matched: true
- `PitchSpread.0` -> `SawLayer.Freq Ratio` matched: false
- `PanSpread.0` -> `LayerPan.Pan` matched: false
- `GainCompensation.0` -> `SawLayer.Gain` matched: false

## Trace Validation

- Parameter trace commands:
  - `hise-cli dsp trace --module DynamicSawUnison --container dynamic_saw_unison --inject silence --inject-param dynamic_saw_unison.NumClones=8 --inject-param dynamic_saw_unison.Spread=1 --probe-changed-parameters --trace-compact --agent`
- Parameter trace evidence:
  - Eight physical layers received frequency ratios `0.5`, `0.5687`, `0.706`, `0.8916`, `1.1179`, `1.38`, `1.6749`, and `2`.
  - Their pan positions were distributed evenly from `-1` through `1`.
  - A separate explicit probe confirmed Ducker gain `0.125` at eight active clones.
- Signal trace commands:
  - `hise-cli dsp trace --module DynamicSawUnison --container dynamic_saw_unison --inject silence --inject-param dynamic_saw_unison.NumClones=8 --inject-param dynamic_saw_unison.Spread=1 --probe-changed-parameters --trace-compact --agent`
- Signal trace evidence:
  - The clone container generated non-silent stereo output from silence in Parallel mode.
  - Trace specs reported stereo, 48 kHz, 512-sample blocks, monophonic network processing, and no MIDI processing.
- Trace caveats:
  - `dsp tree` lists every physical child after the NumClones structural mutation; the representative target connections remain attached to the first child IDs and are distributed clone-aware.
  - The live verification network used the temporary ID `dynamic_saw_unison_clone_fix` because the previously saved canonical XML already existed. Public commands use the approved canonical ID.

## Locked Build Values Applied

- `UnisonLayers.NumClones` range = `1..8`
- `UnisonLayers.NumClones` = `8` for the structural clone rebuild
- Configured clone count = `8`
- `UnisonLayers.SplitSignal` = `Parallel`
- `CloneControls.IsVertical` = `false`
- `PitchSpread.Mode` = `Spread`
- `PitchSpread` target = `SawLayer.Freq Ratio` range `0.5..2`, middle position `1`
- `PanSpread.Mode` = `Spread`
- `PanSpread` target = `LayerPan.Pan` range `-1..1`
- `GainCompensation.Mode` = `Ducker`
- `GainCompensation` target = `SawLayer.Gain` range `0..1`
- `SawLayer.Mode` = `Saw`
- `SawLayer.Frequency` = `220`
- `SawLayer.Gate` = `On`
- `LayerPan.Rule` = `Sine3dB`

## Interface Script Setup Applied

- None

## Optimized Public Shell Commands

These shell `hise-cli` commands are intended for Phase 4 conversion to public `.hsc`. They must not include `save` or `screenshot`.

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id DynamicSawUnison --agent
hise-cli builder set --module DynamicSawUnison --network dynamic_saw_unison --agent

hise-cli dsp add --module DynamicSawUnison --type container.offline --id CloneControls --agent
hise-cli dsp set --module DynamicSawUnison --node CloneControls --param IsVertical --value false --agent
hise-cli dsp add --module DynamicSawUnison --type control.clone_cable --id PitchSpread --parent CloneControls --agent
hise-cli dsp add --module DynamicSawUnison --type control.clone_cable --id PanSpread --parent CloneControls --agent
hise-cli dsp add --module DynamicSawUnison --type control.clone_cable --id GainCompensation --parent CloneControls --agent
hise-cli dsp add --module DynamicSawUnison --type container.clone --id UnisonLayers --agent
hise-cli dsp rename --module DynamicSawUnison --node clone_child --id UnisonVoice --agent
hise-cli dsp add --module DynamicSawUnison --type core.oscillator --id SawLayer --parent UnisonVoice --agent
hise-cli dsp add --module DynamicSawUnison --type jdsp.jpanner --id LayerPan --parent UnisonVoice --agent

hise-cli dsp set --module DynamicSawUnison --node UnisonLayers --param SplitSignal --value 1 --agent
hise-cli dsp set --module DynamicSawUnison --node PitchSpread --param NumClones --range "1,8" --stepSize 1 --agent
hise-cli dsp set --module DynamicSawUnison --node PanSpread --param NumClones --range "1,8" --stepSize 1 --agent
hise-cli dsp set --module DynamicSawUnison --node GainCompensation --param NumClones --range "1,8" --stepSize 1 --agent
hise-cli dsp set --module DynamicSawUnison --node GainCompensation --param Mode --value '"Ducker"' --agent
hise-cli dsp set --module DynamicSawUnison --node SawLayer --param Mode --value 1 --agent
hise-cli dsp set --module DynamicSawUnison --node SawLayer --param 'Freq Ratio' --range "0.5,2" --stepSize 0 --middlePosition 1 --agent
hise-cli dsp set --module DynamicSawUnison --node LayerPan --param Rule --value 2 --agent

hise-cli dsp set --module DynamicSawUnison --node SawLayer --param NodeColour --value 0xFF5F7894 --agent
hise-cli dsp set --module DynamicSawUnison --node LayerPan --param NodeColour --value 0xFF5F7894 --agent

# Setting NumClones through the CLI silently rebuilds the first completed child into eight physical clone chains.
hise-cli dsp set --module DynamicSawUnison --node UnisonLayers --param NumClones --range "1,8" --stepSize 1 --agent
hise-cli dsp set --module DynamicSawUnison --node UnisonLayers --param NumClones --value 8 --agent

hise-cli dsp create_parameter --module DynamicSawUnison --container dynamic_saw_unison --id NumClones --range "1,8" --default 4 --stepSize 1 --agent
hise-cli dsp create_parameter --module DynamicSawUnison --container dynamic_saw_unison --id Spread --range "0,1" --default 0.5 --agent
hise-cli dsp connect --module DynamicSawUnison --source dynamic_saw_unison --source-param NumClones --target UnisonLayers --param NumClones --matched --agent
hise-cli dsp connect --module DynamicSawUnison --source dynamic_saw_unison --source-param NumClones --target PitchSpread --param NumClones --matched --agent
hise-cli dsp connect --module DynamicSawUnison --source dynamic_saw_unison --source-param NumClones --target PanSpread --param NumClones --matched --agent
hise-cli dsp connect --module DynamicSawUnison --source dynamic_saw_unison --source-param NumClones --target GainCompensation --param NumClones --matched --agent
hise-cli dsp connect --module DynamicSawUnison --source dynamic_saw_unison --source-param Spread --target PitchSpread --param Value --matched --agent
hise-cli dsp connect --module DynamicSawUnison --source dynamic_saw_unison --source-param Spread --target PanSpread --param Value --matched --agent
hise-cli dsp connect --module DynamicSawUnison --source PitchSpread --target SawLayer --param 'Freq Ratio' --agent
hise-cli dsp connect --module DynamicSawUnison --source PanSpread --target LayerPan --param Pan --agent
hise-cli dsp connect --module DynamicSawUnison --source GainCompensation --target SawLayer --param Gain --agent
# Expose NumClones so its root cable is visible on the clone container.
hise-cli dsp set --module DynamicSawUnison --node UnisonLayers --param ShowParameters --value true --agent

hise-cli dsp set --module DynamicSawUnison --node UnisonLayers --param NodeColour --value 0xFF8E44AD --agent
hise-cli dsp set --module DynamicSawUnison --node UnisonLayers --param Comment --value '"**Dynamic saw unison** - Parallel clones generate from silence and spread oscillator ratios from half-speed to double-speed."' --agent
hise-cli dsp set --module DynamicSawUnison --node CloneControls --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module DynamicSawUnison --node CloneControls --param Comment --value '"Offline horizontal control strip: clone cables update targets without processing the audio buffer."' --agent
hise-cli dsp set --module DynamicSawUnison --node PitchSpread --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module DynamicSawUnison --node PitchSpread --param Comment --value '"Spread distributes octave ratios from 0.5 to 2 across active clones."' --agent
hise-cli dsp set --module DynamicSawUnison --node PanSpread --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module DynamicSawUnison --node PanSpread --param Comment --value '"Spread distributes stereo positions across active clones."' --agent
hise-cli dsp set --module DynamicSawUnison --node GainCompensation --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module DynamicSawUnison --node GainCompensation --param Comment --value '"Ducker mode scales each oscillator by the reciprocal clone count."' --agent
```

## Pipeline-Only Commands

These commands are not included in public `.hsc`.

```bash
hise-cli dsp save --module DynamicSawUnison --agent
hise-cli dsp screenshot --module DynamicSawUnison --scale 200% --output "scriptnode_enrichment/hsc/output/container/clone.png" --agent
```

## Comments To Preserve In HSC

- Before setting `UnisonLayers.NumClones` to `8`: Setting NumClones through the CLI silently rebuilds the first completed child into eight physical clone chains.
- Before public parameters: NumClones must be the first macro and use the same range on the clone container and all clone cables.
- Before `UnisonLayers`: Parallel mode supplies silence to each clone generator and sums their outputs without multiplying input audio.
- Before `CloneControls`: The offline horizontal container groups control-only nodes without processing audio.
- Before clone cables: Clone-aware cables provide per-layer frequency ratio, pan, and gain values; ordinary clone parameters remain synchronized.

## Documentation Feedback

- Docs updated:
  - `scriptnode_enrichment/hsc/phase1/container/clone.md`: Corrected the structural clone rebuild workflow and frequency-ratio target.
  - `scriptnode_enrichment/hsc/phase2/container/clone.md`: Added the offline control strip, exact panner rule, frequency-ratio range, and special NumClones mutation comment.
- General rules promoted:
  - None
- Local-only findings:
  - The CLI NumClones value setter has special structural behavior for `container.clone`; this is preserved beside the command rather than generalized to ordinary parameters.

## Cosmetics Applied

- Main node: `UnisonLayers` colour `0xFF8E44AD`
- Support nodes: [`CloneControls`, `PitchSpread`, `PanSpread`, `GainCompensation`] colour `0xFF7F6A91`
- Clone-child nodes: [`SawLayer`, `LayerPan`] colour `0xFF5F7894`
- Folded nodes: []
- ShowParameters containers: [`UnisonLayers`]
- Visible target nodes: [`CloneControls`, `PitchSpread`, `PanSpread`, `GainCompensation`, `UnisonLayers`, `UnisonVoice`, `SawLayer`, `LayerPan`]

## Defaults Omitted

- `PitchSpread.Mode` default `Spread`
- `PanSpread.Mode` default `Spread`
- `SawLayer.Frequency` default `220`
- `SawLayer.Gate` default `On`

## Open Issues

- None
