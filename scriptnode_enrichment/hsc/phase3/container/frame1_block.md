# container.frame1_block - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/container/frame1_block.md`
- Reference: `scriptnode_enrichment/output/container/frame1_block.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: Approved as a default-stereo antiphase chorus with two independent mono frame1 processors and a module-tree WaveSynth audition source.

## Naming

- Module ID: `AntiphaseStereoChorus`
- Network ID: `antiphase_stereo_chorus`
- Audition module: `Waveform Generator` (`WaveSynth`)

## Builder Setup Applied

- Host context: `Script FX`
- Additional module: `WaveSynth` for direct MIDI audition
- Routing: default stereo
- `template.dry_wet` dummy removed
- Wet-path order: `StereoWetChannels`, then generated `ChorusMix_wet_gain`
- CPU warning: the dual interpreted frame1 graph is extremely expensive and should be compiled to a C++ node for practical use.

## Verified Parameters

- `antiphase_stereo_chorus.Rate` = `5000` range `200..6000` ms
- `antiphase_stereo_chorus.Mix` = `0.5` range `0..1`
- `antiphase_stereo_chorus.LfoGate` = `1` range `0..1`, stepSize `1`
- Both ramp PeriodTime ranges = `200..6000` ms
- `InvertRight.Value` = `-1` range `-1..1`
- Both delay Limits = `20` ms
- Both DelayTime ranges = `4..10` ms, middle position `7`

## Verified Connections

- `LeftDelayControl.0` -> `LeftDelay.DelayTime`: true
- `RightDelayControl.0` -> `RightDelay.DelayTime`: true
- Root Rate -> both ramp PeriodTime parameters matched: true
- Root Mix -> `ChorusMix.DryWet` matched: true
- Root LfoGate -> both ramp Gate parameters matched: true

## Trace Validation

- Command:
  - `hise-cli dsp trace --module AntiphaseStereoChorus --container antiphase_stereo_chorus --inject noise --gain 0.25 --seed 1234 --probe-recursive --probe-changed-parameters --trace-compact --agent`
- Evidence:
  - Root and dry/wet template reported stereo, 512-sample processing.
  - `StereoWetChannels` split the signal into two one-channel children.
  - Both `LeftFrames` and `RightFrames` reported `numChannels=1`, `blockSize=1`.
  - Both nested modchains reported 48 kHz, one-channel, one-sample processing.
  - After the shared Gate reset at the original 800 ms period, normalized LFO values were exactly complementary at `0.8463` and `0.1537`; delay times were `8.8899` and `5.1101` ms, summing to 14 ms.
  - At the user-selected 5000 ms period, a later snapshot remained approximately complementary at `0.9465` and `0.0516`; delay times were `9.6966` and `4.2920` ms.
  - Both wet channels and the final mixed output were nonzero.
- Caveats:
  - Recursive reports for independently processed branches may be sampled at slightly different moments while the LFOs continue moving.
  - Frame processing is CPU-intensive in the interpreted graph.

## Optimized Public Shell Commands

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id AntiphaseStereoChorus --agent
hise-cli builder set --module AntiphaseStereoChorus --network antiphase_stereo_chorus --agent
# Add a direct MIDI audition source for the chorus.
hise-cli builder add --type WaveSynth --id "Waveform Generator" --agent

hise-cli dsp add --module AntiphaseStereoChorus --type template.dry_wet --id ChorusMix --agent
hise-cli dsp add --module AntiphaseStereoChorus --type container.multi --id StereoWetChannels --parent ChorusMix_wet_path --agent
hise-cli dsp remove --module AntiphaseStereoChorus --node ChorusMix_dummy --agent
# Preserve the template wet gain and keep it after the stereo frame processor.
hise-cli dsp set --module AntiphaseStereoChorus --node StereoWetChannels --index 0 --agent
hise-cli dsp set --module AntiphaseStereoChorus --node ChorusMix_wet_gain --index 1 --agent

# Each multi child receives one mono channel, making frame1 safe in a default stereo host.
hise-cli dsp add --module AntiphaseStereoChorus --type container.frame1_block --id LeftFrames --parent StereoWetChannels --agent
hise-cli dsp add --module AntiphaseStereoChorus --type container.modchain --id LeftDelayLfo --parent LeftFrames --agent
hise-cli dsp add --module AntiphaseStereoChorus --type core.ramp --id LeftRamp --parent LeftDelayLfo --agent
hise-cli dsp add --module AntiphaseStereoChorus --type math.pi --id LeftCycle --parent LeftDelayLfo --agent
hise-cli dsp add --module AntiphaseStereoChorus --type math.sin --id LeftSine --parent LeftDelayLfo --agent
hise-cli dsp add --module AntiphaseStereoChorus --type math.sig2mod --id LeftNormalise --parent LeftDelayLfo --agent
hise-cli dsp add --module AntiphaseStereoChorus --type core.peak --id LeftDelayControl --parent LeftDelayLfo --agent
hise-cli dsp add --module AntiphaseStereoChorus --type jdsp.jdelay_cubic --id LeftDelay --parent LeftFrames --agent

hise-cli dsp add --module AntiphaseStereoChorus --type container.frame1_block --id RightFrames --parent StereoWetChannels --agent
hise-cli dsp add --module AntiphaseStereoChorus --type container.modchain --id RightDelayLfo --parent RightFrames --agent
hise-cli dsp add --module AntiphaseStereoChorus --type core.ramp --id RightRamp --parent RightDelayLfo --agent
hise-cli dsp add --module AntiphaseStereoChorus --type math.pi --id RightCycle --parent RightDelayLfo --agent
hise-cli dsp add --module AntiphaseStereoChorus --type math.sin --id RightSine --parent RightDelayLfo --agent
# Invert the bipolar sine before normalization so the right delay moves opposite to the left.
hise-cli dsp add --module AntiphaseStereoChorus --type math.mul --id InvertRight --parent RightDelayLfo --agent
hise-cli dsp add --module AntiphaseStereoChorus --type math.sig2mod --id RightNormalise --parent RightDelayLfo --agent
hise-cli dsp add --module AntiphaseStereoChorus --type core.peak --id RightDelayControl --parent RightDelayLfo --agent
hise-cli dsp add --module AntiphaseStereoChorus --type jdsp.jdelay_cubic --id RightDelay --parent RightFrames --agent

hise-cli dsp set --module AntiphaseStereoChorus --node LeftRamp --param PeriodTime --range "200,6000" --agent
hise-cli dsp set --module AntiphaseStereoChorus --node LeftRamp --param PeriodTime --value 5000 --agent
hise-cli dsp set --module AntiphaseStereoChorus --node RightRamp --param PeriodTime --range "200,6000" --agent
hise-cli dsp set --module AntiphaseStereoChorus --node RightRamp --param PeriodTime --value 5000 --agent
hise-cli dsp set --module AntiphaseStereoChorus --node InvertRight --param Value --range "-1,1" --agent
hise-cli dsp set --module AntiphaseStereoChorus --node InvertRight --param Value --value -1 --agent
hise-cli dsp set --module AntiphaseStereoChorus --node LeftDelay --param Limit --value 20 --agent
# Set a linear midpoint explicitly; retaining the original delay skew would make complementary values asymmetric.
hise-cli dsp set --module AntiphaseStereoChorus --node LeftDelay --param DelayTime --range "4,10" --middlePosition 7 --agent
hise-cli dsp set --module AntiphaseStereoChorus --node RightDelay --param Limit --value 20 --agent
hise-cli dsp set --module AntiphaseStereoChorus --node RightDelay --param DelayTime --range "4,10" --middlePosition 7 --agent
hise-cli dsp connect --module AntiphaseStereoChorus --source LeftDelayControl --target LeftDelay --param DelayTime --agent
hise-cli dsp connect --module AntiphaseStereoChorus --source RightDelayControl --target RightDelay --param DelayTime --agent

hise-cli dsp create_parameter --module AntiphaseStereoChorus --container antiphase_stereo_chorus --id Rate --range "200,6000" --default 5000 --stepSize 0.1 --agent
hise-cli dsp create_parameter --module AntiphaseStereoChorus --container antiphase_stereo_chorus --id Mix --range "0,1" --default 0.5 --agent
hise-cli dsp create_parameter --module AntiphaseStereoChorus --container antiphase_stereo_chorus --id LfoGate --range "0,1" --default 1 --stepSize 1 --agent
hise-cli dsp connect --module AntiphaseStereoChorus --source antiphase_stereo_chorus --source-param Rate --target LeftRamp --param PeriodTime --matched --agent
hise-cli dsp connect --module AntiphaseStereoChorus --source antiphase_stereo_chorus --source-param Rate --target RightRamp --param PeriodTime --matched --agent
hise-cli dsp connect --module AntiphaseStereoChorus --source antiphase_stereo_chorus --source-param Mix --target ChorusMix --param DryWet --matched --agent
hise-cli dsp connect --module AntiphaseStereoChorus --source antiphase_stereo_chorus --source-param LfoGate --target LeftRamp --param Gate --matched --agent
hise-cli dsp connect --module AntiphaseStereoChorus --source antiphase_stereo_chorus --source-param LfoGate --target RightRamp --param Gate --matched --agent
# Expose DryWet so the root Mix cable is visible on the inner template container.
hise-cli dsp set --module AntiphaseStereoChorus --node ChorusMix --param ShowParameters --value true --agent
# Restart both independently created ramps on one shared parameter callback.
hise-cli dsp set --module AntiphaseStereoChorus --node antiphase_stereo_chorus --param LfoGate --value 0 --agent
hise-cli dsp set --module AntiphaseStereoChorus --node antiphase_stereo_chorus --param LfoGate --value 1 --agent

# This warning is load-bearing documentation for interpreted use.
hise-cli dsp set --module AntiphaseStereoChorus --node antiphase_stereo_chorus --param Comment --value '"**CPU warning** - Two interpreted frame1 branches are extremely expensive. Compile this network to a C++ node before practical use."' --agent
hise-cli dsp set --module AntiphaseStereoChorus --node ChorusMix --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module AntiphaseStereoChorus --node ChorusMix --param Comment --value '"**Antiphase stereo chorus** - The module-tree WaveSynth provides an immediate audition source for two independent mono frame-processed delay paths."' --agent
hise-cli dsp set --module AntiphaseStereoChorus --node StereoWetChannels --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module AntiphaseStereoChorus --node StereoWetChannels --param Comment --value '"Splits default stereo into one mono frame1 processor for each channel."' --agent
hise-cli dsp set --module AntiphaseStereoChorus --node LeftFrames --param NodeColour --value 0xFF8E44AD --agent
hise-cli dsp set --module AntiphaseStereoChorus --node LeftFrames --param Comment --value '"Processes the left channel with one DelayTime update per sample."' --agent
hise-cli dsp set --module AntiphaseStereoChorus --node RightFrames --param NodeColour --value 0xFF8E44AD --agent
hise-cli dsp set --module AntiphaseStereoChorus --node RightFrames --param Comment --value '"Processes the right channel with polarity-inverted sample-accurate modulation."' --agent
hise-cli dsp set --module AntiphaseStereoChorus --node LeftDelayLfo --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module AntiphaseStereoChorus --node RightDelayLfo --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module AntiphaseStereoChorus --node LeftDelay --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module AntiphaseStereoChorus --node RightDelay --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module AntiphaseStereoChorus --node LeftCycle --param Folded --value true --agent
hise-cli dsp set --module AntiphaseStereoChorus --node LeftSine --param Folded --value true --agent
hise-cli dsp set --module AntiphaseStereoChorus --node LeftNormalise --param Folded --value true --agent
hise-cli dsp set --module AntiphaseStereoChorus --node LeftDelayControl --param Folded --value true --agent
hise-cli dsp set --module AntiphaseStereoChorus --node RightCycle --param Folded --value true --agent
hise-cli dsp set --module AntiphaseStereoChorus --node RightSine --param Folded --value true --agent
hise-cli dsp set --module AntiphaseStereoChorus --node InvertRight --param Folded --value true --agent
hise-cli dsp set --module AntiphaseStereoChorus --node RightNormalise --param Folded --value true --agent
hise-cli dsp set --module AntiphaseStereoChorus --node RightDelayControl --param Folded --value true --agent
hise-cli dsp set --module AntiphaseStereoChorus --node ChorusMix_wet_gain --param Folded --value true --agent
```

## Pipeline-Only Commands

```bash
hise-cli dsp save --module AntiphaseStereoChorus --agent
hise-cli dsp screenshot --module AntiphaseStereoChorus --scale 200% --output "scriptnode_enrichment/hsc/output/container/frame1_block.png" --agent
```

## Comments To Preserve In HSC

- Each `container.multi` child receives one mono channel.
- Invert the right bipolar sine before normalization.
- Set DelayTime middle position to 7 before connecting.
- Preserve the template wet gain as the final wet child.
- Toggle shared LfoGate off and on to synchronize independently created ramps.
- Warn that interpreted dual-frame processing is extremely CPU-intensive and should be compiled to C++.

## Cosmetics Applied

- Main nodes: [`LeftFrames`, `RightFrames`] colour `0xFF8E44AD`
- Supporting nodes: [`ChorusMix`, `StereoWetChannels`, `LeftDelayLfo`, `LeftDelay`, `RightDelayLfo`, `RightDelay`] colour `0xFF7F6A91`
- Utility nodes and generated wet gain folded as planned.
- ShowParameters containers: [`ChorusMix`]

## Open Issues

- None blocking this artifact.
