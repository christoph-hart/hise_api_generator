# container.framex_block - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/container/framex_block.md`
- Reference: `scriptnode_enrichment/output/container/framex_block.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: Final layout supplied by the user and rebuilt with semantic subgroup IDs. `DynamicFrames` is horizontal and contains four vertical serial stage groups.

## Naming

- Module ID: `ThreeLevelPhaseModulation`
- Network ID: `three_level_phase_modulation`

## Builder Setup Applied

- Host context: `Script Synth`

## Final Topology

```text
three_level_phase_modulation
  ChannelAllocator
    DynamicFrames
      OSC1
        InputClear
        Sine1
      OSC2
        Normalise1
        Peak1
        Clear1
        Sine2
      OSC3
        Normalise2
        Peak2
        Clear2
        Sine3
      ENV
        OutputEnvelope
        VoiceLifecycle
  StereoOutput
```

## Layout Contract

- `DynamicFrames.IsVertical` = `false`
- `OSC1.IsVertical` = `true`
- `OSC2.IsVertical` = `true`
- `OSC3.IsVertical` = `true`
- `ENV.IsVertical` = `true`
- Frame child order remains `OSC1`, `OSC2`, `OSC3`, `ENV`.
- The subgroups alter presentation only. Their contents still form one serial audio and modulation path.

## Verified Parameters

- All oscillators use Sine mode and MIDI note frequency.
- `Sine1.Freq Ratio` = `2.0`, range `0.5..2.0`
- `Sine2.Freq Ratio` = `0.5`, range `0.5..2.0`
- `Sine3.Freq Ratio` = `1.0`, range `0.5..2.0`
- `Sine3.Gain` = `0.15`
- `OutputEnvelope.Attack` = `5` ms
- `OutputEnvelope.Release` = `80` ms

## Verified Connections

- `Peak1.0` -> `Sine2.Phase`
- `Peak2.0` -> `Sine3.Phase`
- `OutputEnvelope.1` -> `VoiceLifecycle.Kill Voice`

## Trace Validation

- Command:
  ```bash
  hise-cli dsp trace --module ThreeLevelPhaseModulation --container three_level_phase_modulation --trigger-note 60 --trigger-velocity 1 --trigger-channel 1 --trigger-predelay-ms 10 --inject silence --probe-recursive --probe-changed-parameters --trace-compact --agent
  ```
- Evidence:
  - Root: stereo, block size 512, polyphonic, MIDI enabled.
  - `ChannelAllocator`: one child receiving two channels.
  - `DynamicFrames`: two channels, block size 1, polyphonic, MIDI enabled.
  - `OSC1`, `OSC2`, `OSC3`, and `ENV` all preserve the inherited two-channel one-sample context.
  - `Normalise1` reached approximately `0.9921` without zero-crossing folding.
  - `Normalise2` reached approximately `0.9779` without zero-crossing folding.
  - Both Phase edges changed during processing.
  - `StereoOutput` returned equal nonzero values on both channels.
  - Runtime status passed with API `0.11.0`.
- Caveat: Polyphonic interpreted framex processing is extremely expensive. Compile this network to C++ for practical use. If the channel width is permanently stereo, prefer the better-optimized `container.frame2_block`.

## Optimized Public Shell Commands

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptSynth --id ThreeLevelPhaseModulation --agent
hise-cli builder set --module ThreeLevelPhaseModulation --network three_level_phase_modulation --agent

# One multi child receives the complete stereo slice. Adding a second child would reduce each slice to one channel.
hise-cli dsp add --module ThreeLevelPhaseModulation --type container.multi --id ChannelAllocator --agent
hise-cli dsp add --module ThreeLevelPhaseModulation --type container.framex_block --id DynamicFrames --parent ChannelAllocator --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node DynamicFrames --param IsVertical --value false --agent

# Horizontal frame layout containing four vertical serial stage groups.
hise-cli dsp add --module ThreeLevelPhaseModulation --type container.chain --id OSC1 --parent DynamicFrames --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node OSC1 --param IsVertical --value true --agent
hise-cli dsp add --module ThreeLevelPhaseModulation --type container.chain --id OSC2 --parent DynamicFrames --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node OSC2 --param IsVertical --value true --agent
hise-cli dsp add --module ThreeLevelPhaseModulation --type container.chain --id OSC3 --parent DynamicFrames --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node OSC3 --param IsVertical --value true --agent
hise-cli dsp add --module ThreeLevelPhaseModulation --type container.chain --id ENV --parent DynamicFrames --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node ENV --param IsVertical --value true --agent

# Oscillator stage 1 clears host input and generates the first phase modulator.
hise-cli dsp add --module ThreeLevelPhaseModulation --type math.clear --id InputClear --parent OSC1 --agent
hise-cli dsp add --module ThreeLevelPhaseModulation --type core.oscillator --id Sine1 --parent OSC1 --agent

# sig2mod maps -1..1 to 0..1 before peak, avoiding absolute-value folding at zero.
hise-cli dsp add --module ThreeLevelPhaseModulation --type math.sig2mod --id Normalise1 --parent OSC2 --agent
hise-cli dsp add --module ThreeLevelPhaseModulation --type core.peak --id Peak1 --parent OSC2 --agent
hise-cli dsp add --module ThreeLevelPhaseModulation --type math.clear --id Clear1 --parent OSC2 --agent
hise-cli dsp add --module ThreeLevelPhaseModulation --type core.oscillator --id Sine2 --parent OSC2 --agent

hise-cli dsp add --module ThreeLevelPhaseModulation --type math.sig2mod --id Normalise2 --parent OSC3 --agent
hise-cli dsp add --module ThreeLevelPhaseModulation --type core.peak --id Peak2 --parent OSC3 --agent
hise-cli dsp add --module ThreeLevelPhaseModulation --type math.clear --id Clear2 --parent OSC3 --agent
hise-cli dsp add --module ThreeLevelPhaseModulation --type core.oscillator --id Sine3 --parent OSC3 --agent

hise-cli dsp add --module ThreeLevelPhaseModulation --type envelope.simple_ar --id OutputEnvelope --parent ENV --agent
hise-cli dsp add --module ThreeLevelPhaseModulation --type envelope.voice_manager --id VoiceLifecycle --parent ENV --agent
# mono2stereo copies channel 0 to channel 1 in the existing stereo synth context.
hise-cli dsp add --module ThreeLevelPhaseModulation --type core.mono2stereo --id StereoOutput --agent

# MIDI supplies each oscillator base frequency; static ratios define the PM structure.
hise-cli dsp set --module ThreeLevelPhaseModulation --node Sine1 --param 'Freq Ratio' --range "0.5,2" --middlePosition 1 --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node Sine1 --param 'Freq Ratio' --value 2 --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node Sine2 --param 'Freq Ratio' --range "0.5,2" --middlePosition 1 --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node Sine2 --param 'Freq Ratio' --value 0.5 --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node Sine3 --param 'Freq Ratio' --range "0.5,2" --middlePosition 1 --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node Sine3 --param 'Freq Ratio' --value 1 --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node Sine3 --param Gain --value 0.15 --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node OutputEnvelope --param Attack --value 5 --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node OutputEnvelope --param Release --value 80 --agent

hise-cli dsp connect --module ThreeLevelPhaseModulation --source Peak1 --target Sine2 --param Phase --agent
hise-cli dsp connect --module ThreeLevelPhaseModulation --source Peak2 --target Sine3 --param Phase --agent
hise-cli dsp connect --module ThreeLevelPhaseModulation --source OutputEnvelope --source-output 1 --target VoiceLifecycle --param 'Kill Voice' --agent

# Comments explain channel adaptation, signal conversion, voice lifetime, and output behavior at the nodes they constrain.
hise-cli dsp set --module ThreeLevelPhaseModulation --node three_level_phase_modulation --param Comment --value '"**CPU warning** - Polyphonic interpreted framex processing is extremely expensive. Compile this network to C++ for practical use."' --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node ChannelAllocator --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node ChannelAllocator --param Comment --value '"With one child, DynamicFrames inherits both stereo channels. Add a second multi child and its frame width becomes one channel."' --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node DynamicFrames --param NodeColour --value 0xFF8E44AD --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node DynamicFrames --param Comment --value '"Horizontal layout presents four vertical serial stages; framex still processes every inherited channel one sample at a time."' --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node OSC1 --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node OSC1 --param Comment --value '"Clear host audio, then generate the 2.0-ratio first phase modulator."' --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node OSC2 --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node OSC2 --param Comment --value '"sig2mod preserves the bipolar sine shape as 0..1 phase control before peak exports it; clear then starts the 0.5-ratio oscillator."' --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node OSC3 --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node OSC3 --param Comment --value '"The second normalized phase signal drives the 1.0-ratio carrier; intermediate audio is cleared first."' --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node ENV --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node ENV --param Comment --value '"The AR envelope shapes output and its Gate output releases the polyphonic voice."' --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node StereoOutput --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node StereoOutput --param Comment --value '"Copies channel 0 to channel 1, preserving dual-mono output whether framex receives one or two channels."' --agent

hise-cli dsp set --module ThreeLevelPhaseModulation --node InputClear --param Folded --value true --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node Normalise1 --param Folded --value true --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node Peak1 --param Folded --value true --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node Clear1 --param Folded --value true --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node Normalise2 --param Folded --value true --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node Peak2 --param Folded --value true --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node Clear2 --param Folded --value true --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node VoiceLifecycle --param Folded --value true --agent
```

## Pipeline-Only Commands

```bash
hise-cli dsp status --module ThreeLevelPhaseModulation --agent
hise-cli dsp trace --module ThreeLevelPhaseModulation --container three_level_phase_modulation --trigger-note 60 --trigger-velocity 1 --trigger-channel 1 --trigger-predelay-ms 10 --inject silence --probe-recursive --probe-changed-parameters --trace-compact --agent
hise-cli dsp save --module ThreeLevelPhaseModulation --agent
hise-cli dsp screenshot --module ThreeLevelPhaseModulation --scale 200% --output "scriptnode_enrichment/hsc/output/container/framex_block.png" --agent
```

## Comments To Preserve In HSC

- Adding a second multi child changes framex from two inherited channels to one.
- `math.sig2mod` must precede each peak to avoid folding the negative sine half-cycle.
- Clear each modulator only after exporting its normalized per-sample value.
- `core.mono2stereo` requires an existing stereo context and copies channel 0 to channel 1.
- Polyphonic interpreted framex processing should be compiled to C++.

## Open Issues

- Issue 12 is fixed and verified for `container.multi.Comment`.
- Issue 16 is fixed and verified for polyphonic recursive framex tracing.
