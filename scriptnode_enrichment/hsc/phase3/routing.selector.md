# routing.selector - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/routing.selector.md`
- Reference: `scriptnode_enrichment/output/routing/selector.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: The live prototype confirmed four-channel ScriptFX routing, `container.multi` channel isolation, root macro connection, cosmetics, folding, and screenshot composition.

## Naming

- Module ID: `CabMicSelector`
- Network ID: `cab_mic_selector`

## Verified Parameters

- `MicPairSelector.ChannelIndex` = `2` range `0..2` stepSize `2`
- `MicPairSelector.NumChannels` = `2` range `1..16` stepSize `1`
- `CabToneEQ.Mode` = `4`
- `CabToneEQ.Frequency` = `3500`
- `CabToneEQ.Q` = `1.2`
- `CabToneEQ.Gain` = `-3`
- `CabGlueComp.Treshold` = `-18`
- `CabGlueComp.Ratio` = `3`
- `CabGlueComp.Attack` = `12`
- `CabGlueComp.Release` = `120`
- `CabMakeupGain.Gain` = `3` range `-24..6` stepSize `0.1`
- `cab_mic_selector.MicPosition` = `2` range `0..2` stepSize `2`

## Verified Connections

- `cab_mic_selector.MicPosition` -> `MicPairSelector.ChannelIndex` matched: true

## Optimized Public Shell Commands

These shell `hise-cli` commands are intended for Phase 4 conversion to public `.hsc`. They do not include `save` or `screenshot`.

```bash
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id CabMicSelector --agent
hise-cli builder set --module CabMicSelector --network cab_mic_selector --agent
hise-cli builder set --module "Master Chain" --routing "[0,1,0,1]" --agent
hise-cli builder set --module CabMicSelector --routing "[0,1,2,3]" --agent

hise-cli dsp add --module CabMicSelector --type routing.selector --id MicPairSelector --agent
hise-cli dsp set --module CabMicSelector --node MicPairSelector --param NumChannels --value 2 --agent
hise-cli dsp set --module CabMicSelector --node MicPairSelector --param ChannelIndex --range "0,2" --stepSize 2 --agent

hise-cli dsp add --module CabMicSelector --type container.multi --id PairSplit --agent
hise-cli dsp add --module CabMicSelector --type container.chain --id SelectedPair --parent PairSplit --agent
hise-cli dsp add --module CabMicSelector --type container.chain --id UnusedPair --parent PairSplit --agent

hise-cli dsp add --module CabMicSelector --type filters.svf_eq --id CabToneEQ --parent SelectedPair --agent
hise-cli dsp set --module CabMicSelector --node CabToneEQ --param Mode --value 4 --agent
hise-cli dsp set --module CabMicSelector --node CabToneEQ --param Frequency --value 3500 --agent
hise-cli dsp set --module CabMicSelector --node CabToneEQ --param Q --value 1.2 --agent
hise-cli dsp set --module CabMicSelector --node CabToneEQ --param Gain --value -3 --agent

hise-cli dsp add --module CabMicSelector --type jdsp.jcompressor --id CabGlueComp --parent SelectedPair --agent
hise-cli dsp set --module CabMicSelector --node CabGlueComp --param Treshold --value -18 --agent
hise-cli dsp set --module CabMicSelector --node CabGlueComp --param Ratio --value 3 --agent
hise-cli dsp set --module CabMicSelector --node CabGlueComp --param Attack --value 12 --agent
hise-cli dsp set --module CabMicSelector --node CabGlueComp --param Release --value 120 --agent

hise-cli dsp add --module CabMicSelector --type core.gain --id CabMakeupGain --parent SelectedPair --agent
hise-cli dsp set --module CabMicSelector --node CabMakeupGain --param Gain --range "-24,6" --stepSize 0.1 --agent
hise-cli dsp set --module CabMicSelector --node CabMakeupGain --param Gain --value 3 --agent

hise-cli dsp create_parameter --module CabMicSelector --container cab_mic_selector --id MicPosition --range "0,2" --default 2 --stepSize 2 --agent
hise-cli dsp connect --module CabMicSelector --source cab_mic_selector --source-param MicPosition --target MicPairSelector --param ChannelIndex --matched --agent

hise-cli dsp set --module CabMicSelector --node MicPairSelector --param NodeColour --value 0xFF2F80ED --agent
hise-cli dsp set --module CabMicSelector --node MicPairSelector --param Comment --value "**Mic pair selector** - Dynamically routes one of two input stereo pairs into a subsequent FX chain." --agent
hise-cli dsp set --module CabMicSelector --node PairSplit --param Comment --value "**Channel isolation** - Splits the 4-channel buffer into stereo slices so the FX chain only processes the selected pair on channels 0-1." --agent
hise-cli dsp set --module CabMicSelector --node CabToneEQ --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module CabMicSelector --node CabGlueComp --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module CabMicSelector --node UnusedPair --param Folded --value true --agent
hise-cli dsp set --module CabMicSelector --node CabToneEQ --param Folded --value true --agent
hise-cli dsp set --module CabMicSelector --node CabGlueComp --param Folded --value true --agent
hise-cli dsp set --module CabMicSelector --node CabMakeupGain --param Folded --value true --agent
```

## Pipeline-Only Commands

```bash
hise-cli dsp save --module CabMicSelector --agent
hise-cli dsp screenshot --module CabMicSelector --scale 200% --output "scriptnode_enrichment/hsc/phase5/routing/selector.png" --agent
```

## Comments To Preserve In HSC

- Header: The ScriptFX is explicitly routed as four internal channels, but the Master Chain folds those channels back to stereo output.
- Header: `MicPosition` uses raw channel offsets: `0 = first stereo pair`, `2 = second stereo pair`.
- Header: `ChannelIndex` is narrowed before connecting `MicPosition`, then connected with `matched`.
- Header: `container.multi` is required after `routing.selector` so the FX chain does not process the full 4-channel buffer.
- Header: `SelectOutput` and `ClearOtherChannels` are left at defaults.
- Header: Colours use `0xAARRGGBB` literals.
- Before routing setup: four internal source channels are folded back to HISE stereo output.
- Before `PairSplit`: split the post-selector buffer so only channels 0-1 hit the FX chain.
- Before `create_parameter`: root macro values use raw channel offsets.
- Before cosmetic properties: these settings are screenshot-oriented annotations and layout.

## Cosmetics Applied

- Main node: `MicPairSelector` colour `0xFF2F80ED`
- Support nodes: [`CabToneEQ`, `CabGlueComp`] colour `0xFF6F8FAF`
- Folded nodes: [`UnusedPair`, `CabToneEQ`, `CabGlueComp`, `CabMakeupGain`]
- Visible target nodes: [`MicPairSelector`, `PairSplit`, `SelectedPair`]

## Defaults Omitted

- `MicPairSelector.SelectOutput` default `0`
- `MicPairSelector.ClearOtherChannels` default `1`

## Open Issues

- None
