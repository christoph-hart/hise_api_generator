# container.framex_block - HSC Scenario

## Node

- Factory path: `container.framex_block`
- Source page: `scriptnode_enrichment/output/container/framex_block.md`

## Scenario

- Title: Dynamic-Width Three-Level PM Cascade
- Project context: A polyphonic Scriptnode Synthesiser uses three MIDI-pitched sine oscillators in a serial phase-modulation cascade. Static frequency ratios 2.0, 0.5, and 1.0 create a playable harmonic structure; normalized per-frame modulation drives oscillator 2 and 3 Phase, and a final mono-to-stereo node guarantees dual-mono output whether framex inherits one or two channels.
- Teaching goal: Demonstrate that `container.framex_block` performs per-sample processing with a channel width inherited from its parent. With one child in a stereo `container.multi`, it processes both channels; adding another multi child would leave it one channel.

## Support Nodes

- Required: [`container.multi`, `math.clear`, `core.oscillator`, `math.sig2mod`, `core.peak`, `envelope.simple_ar`, `envelope.voice_manager`, `core.mono2stereo`]
- Optional: []
- Rationale: `container.multi` determines the channel slice assigned to the dynamic frame child; an initial `math.clear` removes host input; three MIDI-pitched sine oscillators create the PM cascade; each `math.sig2mod` converts a bipolar sine to normalized control before `core.peak` exports its current frame value; intermediate clear nodes isolate the final carrier; a simple AR and voice manager provide playable voice lifetime; and `core.mono2stereo` copies channel 0 to channel 1 after the multi container.

## Assumptions

- Channels: default stereo polyphonic synth; one multi child initially receives both channels and mono2stereo guarantees dual-mono output
- Public control needed: no
- Raw node values acceptable: yes

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Use a `Scriptnode Synthesiser`. Put `container.framex_block` inside a `container.multi` with exactly one child, so it initially inherits the default stereo width and all three oscillators track played MIDI notes.
- Add a comment to `container.multi`: adding a second child would split the stereo pair and reduce the framex child's inherited width to one channel.
- Set framex to horizontal layout and subgroup its serial stages into four vertical chains: `OSC1` contains `InputClear -> Sine1`; `OSC2` contains `Normalise1 -> Peak1 -> Clear1 -> Sine2`; `OSC3` contains `Normalise2 -> Peak2 -> Clear2 -> Sine3`; and `ENV` contains `OutputEnvelope -> VoiceLifecycle`. The nested containers change only presentation, not serial processing order.
- Connect Peak1 to Sine2 Phase and Peak2 to Sine3 Phase. Both parameter updates then occur for every sample because source and targets share the frame context.
- Put `math.sig2mod` before each peak. This maps -1..1 to 0..1 and preserves the full sine shape instead of letting peak detection fold negative values around zero.
- Override each Freq Ratio to a continuous range that includes 0.5, then lock Sine1 to 2.0, Sine2 to 0.5, and Sine3 to 1.0. MIDI establishes the common note frequency before these static ratios are applied.
- Keep oscillator gains at unity for both modulators, then reduce only the final carrier gain. Connect the simple AR Gate output to voice management.
- Place `core.mono2stereo` after `container.multi`. It does not add channels; in the default stereo synth context it copies channel 0 to channel 1, so output remains stereo even if adding another multi child later reduces framex to one channel.
- Warn that interpreted framex processing is expensive and should be compiled to a C++ node for practical use. For a known stereo width, frame2 is better optimized; framex is justified here only to demonstrate parent-derived channel count.
