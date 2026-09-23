# container.frame2_block - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/container/frame2_block.md`
- Reference: `scriptnode_enrichment/output/container/frame2_block.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: Approved as a self-contained MIDI-tuned pseudo-stereo Karplus-Strong resonator. The final cosmetic revision groups the noise source and short envelope in a compact `Exciter` chain.

## Naming

- Module ID: `MidiTunedStereoResonator`
- Network ID: `midi_tuned_stereo_resonator`

## Builder Setup Applied

- Host context: `Script FX`

## Final Topology

```text
midi_tuned_stereo_resonator
  MidiContext
    Exciter
      ExciterNoise
      ExciterEnvelope
    StereoFrames
      NoteFrequency
      FrequencyHz
      PeriodMs
      LeftPeriod
      RightPeriod
      ResonantLoop
        ResonantLoop_fb_out
        StereoDelays
          LeftDelay
          RightDelay
        LoopDamping
        ResonantLoop_fb_in
```

## Verified Parameters

- `ExciterNoise.Mode` = `4` (`Noise`)
- `ExciterNoise.Gain` = `0.25`
- `ExciterEnvelope.Attack` = `0` ms
- `ExciterEnvelope.Hold` = `1` ms
- `ExciterEnvelope.Decay` = `8` ms
- `ExciterEnvelope.Sustain` = `0`
- `ExciterEnvelope.Release` = `5` ms
- `ExciterEnvelope.NumParameters` = `3`
- `NoteFrequency.Mode` = `Frequency`
- `FrequencyHz.Multiply` = `20000`
- `PeriodMs.Mode` = `Freq2Ms`
- `LeftPeriod.Multiply` = `0.998`
- `RightPeriod.Multiply` = `1.002`
- Both delay Limits = `30` ms
- `ResonantLoop_fb_out.Feedback` = `0.985`, range `0..0.995`
- `LoopDamping.Frequency` = `6000`, range `500..12000`
- `LoopDamping.Smoothing` = `0`
- `Exciter.IsVertical` stored value = `false`, producing the compact horizontal child layout seen in the approved patch

## Verified Connections

- `NoteFrequency.0` -> `FrequencyHz.Value`
- `FrequencyHz.0` -> `PeriodMs.Value`
- `PeriodMs.0` -> `LeftPeriod.Value`
- `PeriodMs.0` -> `RightPeriod.Value`
- `LeftPeriod.0` -> `LeftDelay.DelayTime`
- `RightPeriod.0` -> `RightDelay.DelayTime`
- `ResonantLoop_fb_in.routing` -> `ResonantLoop_fb_out`
- Root Feedback -> receive Feedback matched
- Root Damping -> low-pass Frequency matched

## Trace Validation

- Commands:
  - `hise-cli dsp trace --module MidiTunedStereoResonator --container midi_tuned_stereo_resonator --trigger-note 60 --trigger-velocity 1 --trigger-channel 1 --trigger-predelay-ms 1 --inject dirac --gain 0.25 --probe-recursive --probe-changed-parameters --trace-compact --agent`
  - `hise-cli dsp trace --module MidiTunedStereoResonator --container midi_tuned_stereo_resonator --trigger-note 72 --trigger-velocity 1 --trigger-channel 1 --trigger-predelay-ms 1 --inject dirac --gain 0.25 --probe-recursive --probe-changed-parameters --trace-compact --agent`
  - Final self-excited validation repeated note triggers with `--inject silence`.
- Evidence:
  - `StereoFrames` reported stereo, one-sample processing with MIDI enabled.
  - The nested fixed-block feedback template also reported `blockSize=1`, confirming frame mode is preserved.
  - MIDI note 60 produced frequency `261.6256 Hz`, base period `3.8223 ms`, left delay `3.8146 ms`, and right delay `3.8299 ms`.
  - MIDI note 72 produced frequency `523.2511 Hz`, base period `1.9111 ms`, left delay `1.9073 ms`, and right delay `1.9150 ms`.
  - The octave increase halved all delay periods as expected.
  - With silent external input, `ExciterNoise` reached approximately `0.25`, `ExciterEnvelope` shaped it to approximately `0.234`, and the resonator produced nonzero stereo output.
- Caveats:
  - This is a simple educational model. Exact tuning also depends on the one-sample feedback latency, interpolation, and damping-filter phase.
  - Interpreted stereo frame feedback is expensive and should be compiled to C++ for practical use.

## Optimized Public Shell Commands

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id MidiTunedStereoResonator --agent
hise-cli builder set --module MidiTunedStereoResonator --network midi_tuned_stereo_resonator --agent

hise-cli dsp add --module MidiTunedStereoResonator --type container.midichain --id MidiContext --agent
# Compact self-contained noise-burst exciter.
hise-cli dsp add --module MidiTunedStereoResonator --type container.chain --id Exciter --parent MidiContext --agent
hise-cli dsp set --module MidiTunedStereoResonator --node Exciter --param IsVertical --value false --agent
hise-cli dsp add --module MidiTunedStereoResonator --type core.oscillator --id ExciterNoise --parent Exciter --agent
hise-cli dsp add --module MidiTunedStereoResonator --type envelope.ahdsr --id ExciterEnvelope --parent Exciter --agent
hise-cli dsp add --module MidiTunedStereoResonator --type container.frame2_block --id StereoFrames --parent MidiContext --agent

hise-cli dsp add --module MidiTunedStereoResonator --type control.midi --id NoteFrequency --parent StereoFrames --agent
hise-cli dsp add --module MidiTunedStereoResonator --type control.pma_unscaled --id FrequencyHz --parent StereoFrames --agent
hise-cli dsp add --module MidiTunedStereoResonator --type control.converter --id PeriodMs --parent StereoFrames --agent
hise-cli dsp add --module MidiTunedStereoResonator --type control.pma_unscaled --id LeftPeriod --parent StereoFrames --agent
hise-cli dsp add --module MidiTunedStereoResonator --type control.pma_unscaled --id RightPeriod --parent StereoFrames --agent
hise-cli dsp add --module MidiTunedStereoResonator --type template.feedback_delay --id ResonantLoop --parent StereoFrames --agent

# Replace the template delay with independent fractional stereo delays.
hise-cli dsp remove --module MidiTunedStereoResonator --node ResonantLoop_delay --agent
hise-cli dsp add --module MidiTunedStereoResonator --type container.multi --id StereoDelays --parent ResonantLoop --agent
hise-cli dsp add --module MidiTunedStereoResonator --type jdsp.jdelay_cubic --id LeftDelay --parent StereoDelays --agent
hise-cli dsp add --module MidiTunedStereoResonator --type jdsp.jdelay_cubic --id RightDelay --parent StereoDelays --agent
hise-cli dsp add --module MidiTunedStereoResonator --type filters.one_pole --id LoopDamping --parent ResonantLoop --agent
hise-cli dsp set --module MidiTunedStereoResonator --node ResonantLoop_fb_out --index 0 --agent
hise-cli dsp set --module MidiTunedStereoResonator --node StereoDelays --index 1 --agent
hise-cli dsp set --module MidiTunedStereoResonator --node LoopDamping --index 2 --agent
# The feedback send must remain last so it captures the delayed and damped signal.
hise-cli dsp set --module MidiTunedStereoResonator --node ResonantLoop_fb_in --index 3 --agent

hise-cli dsp set --module MidiTunedStereoResonator --node ExciterNoise --param Mode --value 4 --agent
hise-cli dsp set --module MidiTunedStereoResonator --node ExciterNoise --param Gain --value 0.25 --agent
hise-cli dsp set --module MidiTunedStereoResonator --node ExciterEnvelope --param Attack --value 0 --agent
hise-cli dsp set --module MidiTunedStereoResonator --node ExciterEnvelope --param Hold --value 1 --agent
hise-cli dsp set --module MidiTunedStereoResonator --node ExciterEnvelope --param Decay --value 8 --agent
hise-cli dsp set --module MidiTunedStereoResonator --node ExciterEnvelope --param Sustain --value 0 --agent
hise-cli dsp set --module MidiTunedStereoResonator --node ExciterEnvelope --param Release --value 5 --agent
hise-cli dsp set --module MidiTunedStereoResonator --node ExciterEnvelope --param NumParameters --value 3 --agent

# Frequency mode emits note Hz divided by 20000, so restore raw Hertz before Freq2Ms conversion.
hise-cli dsp set --module MidiTunedStereoResonator --node NoteFrequency --param Mode --value '"Frequency"' --agent
hise-cli dsp set --module MidiTunedStereoResonator --node FrequencyHz --param Multiply --range "0,20000" --agent
hise-cli dsp set --module MidiTunedStereoResonator --node FrequencyHz --param Multiply --value 20000 --agent
hise-cli dsp set --module MidiTunedStereoResonator --node PeriodMs --param Mode --value '"Freq2Ms"' --agent
hise-cli dsp set --module MidiTunedStereoResonator --node LeftPeriod --param Multiply --range "0,2" --agent
hise-cli dsp set --module MidiTunedStereoResonator --node LeftPeriod --param Multiply --value 0.998 --agent
hise-cli dsp set --module MidiTunedStereoResonator --node RightPeriod --param Multiply --range "0,2" --agent
hise-cli dsp set --module MidiTunedStereoResonator --node RightPeriod --param Multiply --value 1.002 --agent
hise-cli dsp set --module MidiTunedStereoResonator --node LeftDelay --param Limit --value 30 --agent
hise-cli dsp set --module MidiTunedStereoResonator --node LeftDelay --param DelayTime --range "0,30" --agent
hise-cli dsp set --module MidiTunedStereoResonator --node RightDelay --param Limit --value 30 --agent
hise-cli dsp set --module MidiTunedStereoResonator --node RightDelay --param DelayTime --range "0,30" --agent

hise-cli dsp connect --module MidiTunedStereoResonator --source NoteFrequency --target FrequencyHz --param Value --agent
hise-cli dsp connect --module MidiTunedStereoResonator --source FrequencyHz --target PeriodMs --param Value --agent
hise-cli dsp connect --module MidiTunedStereoResonator --source PeriodMs --target LeftPeriod --param Value --agent
hise-cli dsp connect --module MidiTunedStereoResonator --source PeriodMs --target RightPeriod --param Value --agent
hise-cli dsp connect --module MidiTunedStereoResonator --source LeftPeriod --target LeftDelay --param DelayTime --agent
hise-cli dsp connect --module MidiTunedStereoResonator --source RightPeriod --target RightDelay --param DelayTime --agent

hise-cli dsp set --module MidiTunedStereoResonator --node LoopDamping --param Frequency --range "500,12000" --middlePosition 3000 --agent
hise-cli dsp set --module MidiTunedStereoResonator --node LoopDamping --param Frequency --value 6000 --agent
hise-cli dsp set --module MidiTunedStereoResonator --node LoopDamping --param Smoothing --value 0 --agent
hise-cli dsp set --module MidiTunedStereoResonator --node ResonantLoop_fb_out --param Feedback --range "0,0.995" --agent
hise-cli dsp set --module MidiTunedStereoResonator --node ResonantLoop_fb_out --param Feedback --value 0.985 --agent
hise-cli dsp create_parameter --module MidiTunedStereoResonator --container midi_tuned_stereo_resonator --id Feedback --range "0,0.995" --default 0.985 --agent
hise-cli dsp create_parameter --module MidiTunedStereoResonator --container midi_tuned_stereo_resonator --id Damping --range "500,12000" --default 6000 --middlePosition 3000 --agent
hise-cli dsp connect --module MidiTunedStereoResonator --source midi_tuned_stereo_resonator --source-param Feedback --target ResonantLoop_fb_out --param Feedback --matched --agent
hise-cli dsp connect --module MidiTunedStereoResonator --source midi_tuned_stereo_resonator --source-param Damping --target LoopDamping --param Frequency --matched --agent

# Interpreted stereo frame feedback is expensive; compile this network to C++ for practical use.
hise-cli dsp set --module MidiTunedStereoResonator --node midi_tuned_stereo_resonator --param Comment --value '"**CPU warning** - Interpreted stereo frame feedback is expensive. Compile this network to a C++ node before practical use."' --agent
hise-cli dsp set --module MidiTunedStereoResonator --node StereoFrames --param NodeColour --value 0xFF8E44AD --agent
hise-cli dsp set --module MidiTunedStereoResonator --node StereoFrames --param Comment --value '"**MIDI-tuned stereo resonator** - One-sample frame feedback creates a simple Karplus-Strong-style decay."' --agent
hise-cli dsp set --module MidiTunedStereoResonator --node MidiContext --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module MidiTunedStereoResonator --node Exciter --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module MidiTunedStereoResonator --node ExciterNoise --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module MidiTunedStereoResonator --node ExciterEnvelope --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module MidiTunedStereoResonator --node NoteFrequency --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module MidiTunedStereoResonator --node FrequencyHz --param Folded --value true --agent
hise-cli dsp set --module MidiTunedStereoResonator --node PeriodMs --param Folded --value true --agent
hise-cli dsp set --module MidiTunedStereoResonator --node LeftPeriod --param Folded --value true --agent
hise-cli dsp set --module MidiTunedStereoResonator --node RightPeriod --param Folded --value true --agent
hise-cli dsp set --module MidiTunedStereoResonator --node ResonantLoop_fb_out --param Folded --value true --agent
hise-cli dsp set --module MidiTunedStereoResonator --node ResonantLoop_fb_in --param Folded --value true --agent
```

## Pipeline-Only Commands

```bash
hise-cli dsp save --module MidiTunedStereoResonator --agent
hise-cli dsp screenshot --module MidiTunedStereoResonator --scale 200% --output "scriptnode_enrichment/hsc/output/container/frame2_block.png" --agent
```

## Comments To Preserve In HSC

- A MIDI note both tunes and excites the resonator.
- Restore raw Hertz before Freq2Ms conversion.
- The slight period multipliers create pseudo-stereo decay.
- Remove only the template delay; preserve receive/send routing and keep send last.
- Warn about approximate tuning and interpreted frame CPU cost.

## Open Issues

- None blocking this artifact.
