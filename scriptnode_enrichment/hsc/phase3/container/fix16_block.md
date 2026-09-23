# container.fix16_block - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/container/fix16_block.md`
- Reference: `scriptnode_enrichment/output/container/fix16_block.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: Reworked into a practical MIDI-triggered filter-envelope example. The final patch omits a redundant midichain because the Scriptnode Synthesiser root already supplies voice and MIDI context.

## Naming

- Module ID: `SnappyFilterEnvelope`
- Network ID: `snappy_filter_envelope`

## Builder Setup Applied

- Host context: `Script Synth`
- Additional builder steps applied:
  - Triggered MIDI note 60 through the trace API to allocate an active voice.
  - Used a harmonically rich saw source for audible low-pass movement.
  - Set filter smoothing to exactly zero before connecting and validating modulation.
  - Connected the AHDSR Gate output to voice management for cleanup.
- Channel/routing setup verified:
  - Required channels: `default stereo in a polyphonic synth voice context`
  - Module routing: `default stereo`
  - Master routing: `default stereo`

## Verified Parameters

- `SawVoice.Mode` = `1` (`Saw`)
- `SawVoice.Gain` = `0.125`
- `FilterEnvelope.Attack` = `1` ms
- `FilterEnvelope.Hold` = `0` ms
- `FilterEnvelope.Decay` = `300` ms
- `FilterEnvelope.Sustain` = `0.5`
- `FilterEnvelope.Release` = `50` ms
- `FilterEnvelope.NumParameters` property = `2`
- `SnappyLowPass.Frequency` = `120` range `120..12000`, middle position `1000`
- `SnappyLowPass.Q` = `0.8`
- `SnappyLowPass.Smoothing` = `0`
- `SnappyLowPass.Mode` = `0` (`LowPass`)

## Verified Connections

- `FilterEnvelope.0` (CV) -> `SnappyLowPass.Frequency` scaled: true
- `FilterEnvelope.1` (Gate) -> `VoiceLifecycle.Kill Voice` scaled: true

## Trace Validation

- Parameter trace commands:
  - `hise-cli dsp trace --module SnappyFilterEnvelope --container snappy_filter_envelope --trigger-note 60 --trigger-velocity 1 --trigger-channel 1 --trigger-predelay-ms 1 --inject silence --probe-recursive --probe-changed-parameters --trace-compact --agent`
  - `hise-cli dsp trace --module SnappyFilterEnvelope --container snappy_filter_envelope --trigger-note 60 --trigger-velocity 1 --trigger-channel 1 --trigger-predelay-ms 10 --inject silence --probe-recursive --probe-changed-parameters --trace-compact --agent`
  - `hise-cli dsp trace --module SnappyFilterEnvelope --container snappy_filter_envelope --trigger-note 60 --trigger-velocity 1 --trigger-channel 1 --trigger-predelay-ms 150 --inject silence --probe-recursive --probe-changed-parameters --trace-compact --agent`
- Parameter trace evidence:
  - At 10 ms predelay, `SnappyLowPass.Frequency` was observed at `5198.4674` Hz during the envelope transient.
  - At 150 ms predelay, cutoff settled to `1000` Hz, matching the configured middle position at sustain `0.5`.
  - `VoiceLifecycle.Kill Voice` was observed at `1` while the triggered voice remained active.
- Signal trace commands:
  - Same recursive note-triggered commands as above.
- Signal trace evidence:
  - Root specs reported `sampleRate=48000`, `numChannels=2`, `blockSize=512`, `polyphonic=true`, `processMidi=true`.
  - `SixteenSampleVoice` reported `blockSize=16`, `polyphonic=true`, `processMidi=true`.
  - At 10 ms predelay, the saw, enveloped, and filtered stages all produced nonzero equal stereo output.
  - The 10 ms trace reported a module signal peak of `0.0495`, below the locked oscillator gain.
- Trace caveats:
  - A Scriptnode Synthesiser requires an allocated voice; signal injection or manual envelope Gate changes alone do not create one.
  - Use `--trigger-note` for synth trace validation.
  - Sixteen samples is the maximum chunk size; a final host-buffer remainder can be shorter.

## Locked Build Values Applied

- Maximum child chunk size = `16` samples
- Envelope timing = `1 / 0 / 300 / 50` ms for attack, hold, decay, and release
- Envelope sustain = `0.5`
- Filter cutoff range = `120..12000` Hz with middle position `1000` Hz
- Filter smoothing = exactly `0`

## Interface Script Setup Applied

- None

## Optimized Public Shell Commands

These commands are intended for Phase 4 conversion to public `.hsc`. They exclude pipeline-only save and screenshot operations.

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptSynth --id SnappyFilterEnvelope --agent
hise-cli builder set --module SnappyFilterEnvelope --network snappy_filter_envelope --agent

# The Scriptnode Synthesiser root already supplies MIDI and voice context, so no extra midichain is required.
# Sixteen samples is the maximum child chunk size; a final remainder may be shorter.
hise-cli dsp add --module SnappyFilterEnvelope --type container.fix16_block --id SixteenSampleVoice --agent
hise-cli dsp add --module SnappyFilterEnvelope --type core.oscillator --id SawVoice --parent SixteenSampleVoice --agent
hise-cli dsp add --module SnappyFilterEnvelope --type envelope.ahdsr --id FilterEnvelope --parent SixteenSampleVoice --agent
hise-cli dsp add --module SnappyFilterEnvelope --type filters.svf --id SnappyLowPass --parent SixteenSampleVoice --agent
hise-cli dsp add --module SnappyFilterEnvelope --type envelope.voice_manager --id VoiceLifecycle --parent SixteenSampleVoice --agent

hise-cli dsp set --module SnappyFilterEnvelope --node SawVoice --param Mode --value 1 --agent
hise-cli dsp set --module SnappyFilterEnvelope --node SawVoice --param Gain --value 0.125 --agent
hise-cli dsp set --module SnappyFilterEnvelope --node FilterEnvelope --param Attack --value 1 --agent
hise-cli dsp set --module SnappyFilterEnvelope --node FilterEnvelope --param Hold --value 0 --agent
hise-cli dsp set --module SnappyFilterEnvelope --node FilterEnvelope --param Decay --value 300 --agent
hise-cli dsp set --module SnappyFilterEnvelope --node FilterEnvelope --param Sustain --value 0.5 --agent
hise-cli dsp set --module SnappyFilterEnvelope --node FilterEnvelope --param Release --value 50 --agent
hise-cli dsp set --module SnappyFilterEnvelope --node FilterEnvelope --param NumParameters --value 2 --agent

# Smoothing must be zero or filter interpolation will hide the sixteen-sample envelope updates.
hise-cli dsp set --module SnappyFilterEnvelope --node SnappyLowPass --param Frequency --range "120,12000" --middlePosition 1000 --agent
hise-cli dsp set --module SnappyFilterEnvelope --node SnappyLowPass --param Frequency --value 120 --agent
hise-cli dsp set --module SnappyFilterEnvelope --node SnappyLowPass --param Q --value 0.8 --agent
hise-cli dsp set --module SnappyFilterEnvelope --node SnappyLowPass --param Smoothing --value 0 --agent
hise-cli dsp connect --module SnappyFilterEnvelope --source FilterEnvelope --source-output 0 --target SnappyLowPass --param Frequency --agent
# Use the envelope Gate output, not CV, for voice cleanup.
hise-cli dsp connect --module SnappyFilterEnvelope --source FilterEnvelope --source-output 1 --target VoiceLifecycle --param 'Kill Voice' --agent

hise-cli dsp set --module SnappyFilterEnvelope --node SixteenSampleVoice --param NodeColour --value 0xFF2F80ED --agent
hise-cli dsp set --module SnappyFilterEnvelope --node SixteenSampleVoice --param Comment --value '"**Snappy filter envelope** - Sixteen-sample chunks provide fast cutoff updates without the iteration cost of eight-sample pitch modulation."' --agent
hise-cli dsp set --module SnappyFilterEnvelope --node SawVoice --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module SnappyFilterEnvelope --node FilterEnvelope --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module SnappyFilterEnvelope --node FilterEnvelope --param Comment --value '"The Scriptnode Synthesiser root already supplies MIDI and voice context; a redundant midichain is unnecessary."' --agent
hise-cli dsp set --module SnappyFilterEnvelope --node SnappyLowPass --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module SnappyFilterEnvelope --node SnappyLowPass --param Comment --value '"Smoothing must remain at zero so interpolation does not hide the sixteen-sample envelope updates."' --agent
hise-cli dsp set --module SnappyFilterEnvelope --node VoiceLifecycle --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module SnappyFilterEnvelope --node VoiceLifecycle --param Comment --value '"The envelope Gate output kills each voice after release; do not connect the CV output here."' --agent
hise-cli dsp set --module SnappyFilterEnvelope --node VoiceLifecycle --param Folded --value true --agent
```

## Pipeline-Only Commands

```bash
hise-cli dsp save --module SnappyFilterEnvelope --agent
hise-cli dsp screenshot --module SnappyFilterEnvelope --scale 200% --output "scriptnode_enrichment/hsc/output/container/fix16_block.png" --agent
```

## Comments To Preserve In HSC

- Before `SixteenSampleVoice`: The synth root already supplies MIDI and voice context; no extra midichain is needed.
- Before the filter setup: Smoothing must be zero so the fixed-block cadence remains visible and audible.
- Before the frequency connection: Configure the broad skewed cutoff range first.
- Before `VoiceLifecycle`: Connect AHDSR Gate output 1, not CV output 0.
- Before validation: Use `--trigger-note` to allocate a synth voice before probing.

## Documentation Feedback

- Docs updated:
  - `scriptnode_enrichment/hsc/phase1/container/fix16_block.md`: Replaced the additive staircase with a snappy filter-envelope voice.
  - `scriptnode_enrichment/hsc/phase2/container/fix16_block.md`: Normalized the user-approved direct synth-root topology and final values.
- General rules promoted:
  - None
- Local-only findings:
  - Scriptnode Synthesiser trace validation requires note triggering.
  - The synth root makes a nested midichain redundant for this voice topology.

## Cosmetics Applied

- Main node: `SixteenSampleVoice` colour `0xFF2F80ED`
- Support nodes: [`SawVoice`, `FilterEnvelope`, `SnappyLowPass`, `VoiceLifecycle`] colour `0xFF6F8FAF`
- Folded nodes: [`VoiceLifecycle`]
- Visible target nodes: [`SixteenSampleVoice`, `SawVoice`, `FilterEnvelope`, `SnappyLowPass`]

## Defaults Omitted

- `SawVoice.Frequency` default `220`
- `SawVoice.Freq Ratio` default `1`
- `SawVoice.Gate` default `On`
- `FilterEnvelope.AttackLevel` default `1`
- `FilterEnvelope.AttackCurve` default `0.5`
- `FilterEnvelope.Retrigger` default `Off`
- `FilterEnvelope.Gate` default `Off`
- `SnappyLowPass.Mode` default `LowPass`
- `SnappyLowPass.Gain` default `0`
- `SnappyLowPass.Enabled` default `On`
- `VoiceLifecycle.Kill Voice` default `1`

## Open Issues

- None blocking this artifact.
