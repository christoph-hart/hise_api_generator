# Ideas for HSC examples

This file contains loose ideas that can be used as starting points for example HSC nodes.

> [!IMPORTANT]
> Each idea must be researched and authored individually according to `AGENTS.md`. Never turn this list into Phase 1 or Phase 2 files with a generator, loop, template, or bulk scaffolding script. An idea is not a topology specification, and unresolved choices must be brought to the user before authoring proceeds.

## fx


[X] `fx.haas`: A polyphonic FX that positions every voice in the stereo field using a random node that creates a static position on voice start (using voice_bang)
[X] `fx.phase_delay`: A 1:1 recreation of the HISE PhaseFX module (with an extra_mod modulating the frequency)
[X] `fx.reverb`: A simple wrapper around the reverb node that propagates all parameters including a dry/wet template.
[X] `fx.bitcrush`: A delay with a bitcrusher in the feedback chain. Use the feedback template.
[X] `fx.sampleandhold`: A random step sequencer using a noise oscillator and the sample & hold node to create temposynced randomized steps
[X] `fx.pitch_shift`: A simple chorus effect using a dry/wet template

## analyse


[X] `analyse.fft`: A split container with different oscillators going into different fft nodes (saw / sine, noise)
[X] `analyse.oscilloscope`: Inside a midi processing node to demonstrate the dynamic buffer size functionality
[ ] `analyse.goniometer`: two nodes, before and after a reverb node to show how the reverb creates the stereo field
[ ] `analyse.specs`: Multiple different containers that contain a few nodes to show how the processing specs are modified (midi, modchain, fix block, oversample), etc.

## container


[X] `container.branch`: Multiple math.expr waveshaping nodes (tanh, HISE saturation, sine folding) branched with this container.
[X] `container.chain`: Show how nested parameters work: connect a modulation output of a nodeto a macro parameter of an inner chain which then connects to some nodes.
[X] `container.clone`: unisono saw oscillator with dynamic unisono amount & spread
[ ] `container.fix_xxx`: show modulation of a ramp to an add node to demonstrate how the modulation creates the staircase artifacts with higher blocksizes. With and without the node
[ ] `container.frame_xxx`: show modulation of a interpolating delay line for chorus effects
[X] `container.midichain`: show a monophonic synthesiser in a Script FX (oscillator & simple_ar within a midichain)
[X] `container.modchain`: create a simple LFO signal that modulates the freq ratio of a oscillator for subtle vibrato.
[X] `container.multi`: simple panning effect: xfader -> 2x math.mul.
[X] `container.no_midi`: A polyphonic synthesiser network that adds a oscillator in this node for a hardwired LFO. the no_midi prevents the frequency from being set by the incoming note on
[X] `container.offline`: A chain of multiple control nodes put in a offline container for lighter CPU work.
[X] `container.oversample`: An aggressive waveshaper that introduces harmonics
[X] `container.repitch`: A wrapped reverb node that can have its size / length "modulated" by the pitch parameter
[X] `container.soft_bypass`: A "vocal channel-strip" using different elements (HPF, compressor, waveshaper, etc). Each stage can be soft bypassed.
[X] `container.split`: A "silencer" that copies the signal, multiplies it with -1 and adds it back. Demonstrates how the signal is copied without latency.
[X] `container.dynamic_blocksize`: A generated ramp controls the value of an additive signal stage inside a block-size container. Switching the public Block Size control from per-sample processing to progressively larger chunks turns the smooth ramp into increasingly coarse audible and visible steps.
[X] `container.fix128_block`: A slow ramp becomes an additive staircase updated every 128 samples. With a 512- or 1024-sample host buffer, the enabled container visibly introduces several intermediate levels while requiring only a few child iterations per buffer.
[X] `container.fix16_block`: A rapid ramp is sampled into an additive staircase signal at 16-sample intervals. The example contrasts the clearly bounded step length with host-buffer processing and presents this size as a lower-overhead alternative when 8-sample updates are unnecessary.
[X] `container.fix256_block`: In a 512- or 1024-sample host configuration, a slow ramp drives an additive output through 256-sample chunks. The result shows the smallest useful subdivision of a very large host buffer and also proves that the container has no effect when the incoming block already fits within 256 samples.
[X] `container.fix32_block`: A ramp-controlled additive output reveals a regular 32-sample staircase instead of one hold per host buffer. This provides a visual baseline for the fixed size commonly chosen when filter or pitch modulation needs better resolution without the iteration count of 8- or 16-sample chunks.
[X] `container.fix64_block`: A slow ramp controls an additive test signal that updates every 64 samples. The steps remain fine enough for ordinary LFO-rate movement while making the reduction from host-buffer-sized holds easy to see, illustrating why 64 samples is the default starting point for adjustable block containers.
[X] `container.fix8_block`: A fast 0 to 1 ramp drives an additive signal value inside an 8-sample container. The resulting waveform stays close to the source ramp, while bypassing the container exposes the much coarser host-buffer staircase.
[X] `container.fix_blockx`: A ramp-driven additive signal is processed at a property-selected child block size, making its update staircase visible and audible. The author can try each supported size and bypass the container to compare against host-buffer processing before committing to a fixed size for compilation.
[X] `container.frame1_block`: A mono wet path uses a sine-shaped ramp to modulate a short interpolating delay for chorus movement. Wrapping both source and target in `container.frame1_block` updates delay time for every sample instead of once per host block.
[X] `container.frame2_block`: A stereo wet path modulates a cubic interpolating delay with a sine LFO while preserving the original stereo input in a dry path. `container.frame2_block` runs both channels and the delay-control source one frame at a time, avoiding block-rate delay jumps.
[X] `container.framex_block`: A four-channel effect applies the same sine-modulated cubic delay to every channel in its wet path. `container.framex_block` adapts its frame width to the surrounding channel context, preserving sample-accurate modulation without hardcoding mono or stereo processing.
[X] `container.oversample16x`: A deliberately pathological nested-sine expression processes high-frequency input and produces harmonics close to and beyond Nyquist. The example uses fixed 16x oversampling as a diagnostic upper bound, then requires evidence that its spectral improvement over lower practical factors warrants the extreme CPU cost.
[X] `container.oversample2x`: A stereo insert applies moderate pre-gain, tanh saturation, and output trim inside a fixed 2x oversampling stage. Bypassing only the container's resampling allows the same saturator to be compared at the original rate without changing its drive.
[X] `container.oversample4x`: A monophonic distortion insert boosts incoming audio into a low-threshold hard clipper, then trims the result, with all three stages running at a fixed 4x rate. The example presents 4x as a practical production balance for a processor whose sharp corners create more aliasing than gentle saturation.
[X] `container.oversample8x`: Incoming audio is driven through a programmable sine-folding transfer function that repeatedly reverses waveform direction and generates dense upper harmonics. Fixed 8x processing strongly suppresses audible foldback while making its substantial CPU multiplier visible.
[X] `container.sidechain`: A stereo effect expands its two input channels to four, keeps the original audio on channels 0-1, and generates a fixed low-frequency sine key on the otherwise empty channels 2-3. A sidechain-enabled compressor uses that internal key to create periodic pumping, after which only the processed main stereo pair leaves the container.

## control


[X] `control.bang`: a ramp modulating the value and a desynced timer sending out bang messages for quasi random (or polyrhythmic) modulation.
[X] `control.bipolar`: a triangle LFO oscillator modulating the freq ratio and the scale parameter controlling the vibrato amount around the center frequency value
[X] `control.blend`: a sine LFO and a filtered noise source (tbd) can be blended to create an LFO with "human touch"
[X] `control.branch_cable`: create a peak or RMS peak meter sending into a global cable.
[X] `control.cable_expr`: some control signal manipulation, idk
[X] `control.cable_pack`: a clock_ramp connected to this node is driving a step sequencer that modulates the filter frequency of a LPF.
[X] `control.cable_table`: control two filter frequency with root parameters, root one of them through a cable_table with a skewed graph to demonstrate a nonlinear parameter range.
[X] `control.change`: A ramp going into a staircase creator (cable.expr with Math.fmod(input, 0.25)), then going into the change node to filter out repetitive values.
[X] `control.compare`: a filter controlled by two root parameters: a min frequency and a frequency, then these values are compared with the `MAX` operator.
[X] `control.converter`: convert the output of the tempo_sync node to drive time-based nodes which work on another domain than ms (eg. sampleandhold which works in samples).
[X] `control.delay_cable`: a timer that triggers the gate of two oscillators for short blips, one of them is delayed a bit.
[X] `control.input_toggle`: a key tracking filter in a polyphonic FX - one input sets the frequency by the incoming midi number, the other input allows it being set with a root parameter. another root parameter is toggling between these inputs.
[X] `control.intensity`: simulating the HISE gain modulation with a modchain modulating a mul node.
[X] `control.clone_cable`: A clone container holds identical sine oscillators, but each active clone must play a different integer multiple of the incoming note. `control.clone_cable` uses Harmonics mode to distribute note-derived frequencies automatically as the harmonic count changes.
[X] `control.clone_forward`: A parallel bank of cloned bandpass filters uses distributed cutoff frequencies but one common Resonance control. `control.clone_forward` broadcasts the exact same Q value to every active clone while leaving per-clone frequency differentiation intact.
[X] `control.clone_pack`: Eight cloned sine oscillators form a harmonic additive tone, and an eight-slider pack stores an arbitrary gain for each partial. `control.clone_pack` sends each slider value to the matching clone while one Master Level scales the complete programmed spectrum.
[ ] `control.file_analyser`: Load a pitched sample, detect its fundamental frequency once on file load, and forward the raw Hz value to a sine oscillator that follows the sample's pitch.
[X] `control.locked_mod`: A small container packages a free-running ramp and exposes it as one draggable modulation source after the container is locked. The resulting normalised output controls a lowpass cutoff outside the reusable block using the target's frequency range.
[X] `control.locked_mod_unscaled`: A locked modulation container converts a musical note division into raw milliseconds and exposes that duration through one draggable output. The external destination is a fixed delay whose DelayTime receives the millisecond value directly without normalised range conversion.
[X] `control.logic_op`: An effect should process only when the DAW is playing and a public Enable switch is on. `control.logic_op` combines those two binary conditions with AND and controls one soft-bypass wrapper around the effect stage.
[X] `control.midi`: A MIDI-aware synth maps note-on velocity to the cutoff of a lowpass filter. Soft notes produce a dark tone and hard notes open the filter, while subsequent audio processing continues without polling MIDI state.
[X] `control.midi_cc`: MIDI CC1 controls the pan position of a stereo panner, with a centred fallback before the first controller message arrives. The example converts ordinary 7-bit controller data to a normalised modulation value and maps it across the full stereo field.
[X] `control.minmax`: A repeating normalised ramp sweeps a lowpass filter while public Minimum and Maximum controls redefine the cutoff interval at runtime. Skew changes how long the sweep spends in low frequencies without changing its endpoints.
[X] `control.normaliser`: A tempo-sync source sends raw milliseconds directly to a delay time and also through `control.normaliser` to the effect's Dry/Wet control. Longer rhythmic divisions therefore produce a wetter echo while shorter divisions remain subtler, despite the source and mix using different ranges.
[X] `control.pack2_writer`: Two public cutoff-level controls write a two-entry slider pack that a tempo-synchronised cable-pack reader alternates through. Editing either control updates its corresponding sequence step without directly targeting the filter.
[X] `control.pack3_writer`: Three public level controls write a three-entry pack used by a cloned sine oscillator bank. Each Value parameter adjusts one harmonic's gain, creating a compact fundamental, second, and third partial mixer.
[X] `control.pack4_writer`: Four cloned tone layers share one oscillator setup but have independent pan positions. Four public controls write a pack that `control.clone_pack` distributes to the corresponding panner in each clone.
[X] `control.pack5_writer`: Five independent accent controls write a five-entry slider pack. A transport-synchronised ramp scans the pack through `control.cable_pack` and applies the discrete values to signal gain, creating an intentionally uneven five-step rhythmic cycle.
[X] `control.pack6_writer`: Six cloned peak-EQ stages run serially at distributed centre frequencies. Six public band controls write a shared pack, and each pack entry sets the gain of the corresponding cloned EQ stage.
[X] `control.pack7_writer`: Seven public pitch-ratio controls define one octave's scale degrees in a slider pack. A tempo-locked ramp scans the entries discretely and applies the selected ratio to a MIDI-pitched oscillator, producing a repeating seven-note pattern.
[X] `control.pack8_writer`: Eight individually automatable controls write the largest fixed writer pack, which a clocked lookup reads as a conventional eight-step filter sequence. Each control owns one exact sequence position and can update it while playback continues.
[X] `control.pack_resizer`: A variable-size additive oscillator bank uses one slider per active clone to set partial levels. Changing Partial Count updates the clone container and uses `control.pack_resizer` to keep the external slider pack long enough for every active clone.
[X] `control.pma`: A normalised ramp is inverted and scaled so gain moves from unity down to a configurable floor rather than reaching silence. `control.pma` performs the multiply-add transformation before a linear audio multiplier.
[X] `control.pma_unscaled`: A tempo-sync source produces a raw note duration in milliseconds. `control.pma_unscaled` multiplies that native value and adds a small millisecond offset before sending the result directly to a fixed delay.
[X] `control.ppq`: Starting playback at different positions within a one-bar window assigns a corresponding static pan position to the effect. The pan updates again only when the host jumps or loops, clearly separating a PPQ snapshot from a continuously moving clock ramp.
[X] `control.random`: A public Randomise trigger changes between zero and one on each press. Every change asks `control.random` for a new uniformly distributed value, which places the incoming signal at a new stereo position.
[X] `control.resetter`: A continuously gated tone uses a public Retrigger control to restart its attack without first requiring the user to turn the gate off. `control.resetter` forces a zero-then-one transition into a simple AR envelope on every input change.
[X] `control.sliderbank`: One Character macro simultaneously opens a filter, increases soft saturation, and moves the signal toward the right. Three slider-pack entries define independent amounts so each destination responds with a different strength.
[X] `control.smoothed_parameter`: A public Pan control can jump instantly between left and right, but a normalised smoothing stage turns those steps into controlled movement before they reach a stereo panner. Switching smoothing off provides an immediate comparison.
[X] `control.smoothed_parameter_unscaled`: A public Delay Time control sends native millisecond values to an interpolating delay line that has no internal smoothing. `control.smoothed_parameter_unscaled` ramps those raw values before forwarding them directly, preventing abrupt read-position jumps.
[X] `control.tempo_sync`: A delay effect derives its wet-path delay time from a musical note division and the current host BPM. Disabling sync switches the same output to a manual millisecond value for standalone or free-time operation.
[X] `control.timer`: A timer alternates between zero and one at a fixed interval and applies that value to linear signal gain, creating a simple square-wave tremolo. Active stops the timer entirely and restarting it resets the counter.
[X] `control.transport`: A lowpass effect fades into its processed state when the DAW starts and returns to dry when playback stops. `control.transport` supplies the exact binary host state without polling or a user parameter.
[X] `control.unscaler`: One public Delay Time parameter is expressed in milliseconds and must set two serial delay stages to the identical native value. `control.unscaler` forwards that raw number to both targets without each target reinterpreting it through its own range.
[X] `control.voice_bang`: A polyphonic synth exposes a Next Voice Pan control. Each note-on makes `control.voice_bang` send the current value to that voice's panner, so changing the control affects newly started notes without moving voices that are already sounding.
[X] `control.xfader`: One Morph control moves across dry, filtered, and saturated parallel paths. `control.xfader` generates three overlapping gain coefficients so adjacent paths crossfade instead of switching abruptly.
[X] `control.xy`: One two-dimensional gesture controls lowpass cutoff horizontally and stereo position vertically. The X output uses normalised target mapping, while the bipolar Y output maps directly across left and right.

## core


[ ] `core.clock_ramp`: A host-synchronised ramp drives a repeating tremolo pattern that remains aligned when playback starts, loops, or jumps to another position.
[ ] `core.extra_mod`: A polyphonic filter receives an envelope from an Extra Modulator chain in the parent sound generator, demonstrating how parent modulation enters a scriptnode network.
[ ] `core.faust`: A small Faust-written wavefolder exposes drive and symmetry parameters automatically, allowing the generated node interface and modulation outputs to be inspected.
[ ] `core.file_player`: A MIDI pitch-tracked sample player uses an assigned root note to turn a single pitched audio file into a playable polyphonic instrument.
[ ] `core.fix_delay`: A dry signal is mixed with a short delayed copy to create a comb filter, while FadeTime demonstrates click-free changes between static delay times.
[ ] `core.fm`: A sine oscillator supplies an audio-rate modulation signal to an FM operator, with public Ratio and FM Depth controls producing a playable two-operator FM tone.
[ ] `core.gain`: Rapidly automate a gain stage between silence and unity to demonstrate its decibel mapping and built-in smoothing compared with an unsmoothed linear multiplier.
[ ] `core.global_mod`: Receive one envelope or LFO from a Global Modulator Container and use it to control several parameters inside a polyphonic effect network.
[ ] `core.granulator`: Turn a short recorded sample into an ambient grain cloud with controls for position, grain density, pitch spread, and stereo spread.
[ ] `core.matrix_mod`: Use a global LFO as the main vibrato source and a second global modulator, such as velocity or expression, to control the vibrato depth dynamically.
[ ] `core.mono2stereo`: Generate a signal only on the left channel, duplicate it into dual mono, then process the two channels differently to create a stereo result.
[ ] `core.oscillator`: A minimal polyphonic synthesiser exposes waveform, frequency ratio, gain, and gate-envelope controls while showing that the oscillator adds to the incoming signal.
[ ] `core.peak`: Follow the amplitude of a drum loop and use the normalised peak output to open a filter on a second signal, creating an amplitude-driven rhythmic effect.
[ ] `core.peak_unscaled`: Feed a slow bipolar oscillator into the node and use its signed output to pan another signal left and right without losing the negative half of the waveform.
[ ] `core.phasor`: Convert a raw 0 to 1 phasor into pulse and triangle waveforms with math nodes, demonstrating waveform construction from a shared phase ramp.
[ ] `core.phasor_fm`: Feed an audio-rate sine modulation signal into the phasor and transform its ramp output into a waveform, demonstrating frequency modulation before waveform shaping.
[ ] `core.pitch_mod`: Mirror the parent sound generator's pitch bend, glide, or pitch-envelope factor into an additional oscillator layer inside the scriptnode network.
[ ] `core.ramp`: A free-running ramp controls gain through a triangle-shaped transfer curve, creating a simple LFO while displaying both its audio and modulation outputs.
[ ] `core.recorder`: Capture a short live input into an external audio-file slot and play the completed recording back with `core.file_player` as a basic one-shot looper.
[ ] `core.smoother`: Pass a coarse step sequence through the one-pole smoother and compare the raw and smoothed signals visually and audibly.
[ ] `core.snex_node`: Implement a small custom stereo processor in SNEX, such as a width control, to demonstrate parameter declaration and the full processing callback lifecycle.
[ ] `core.snex_osc`: Implement a custom pulse oscillator in SNEX with pulse-width control while relying on the node for MIDI frequency tracking and polyphonic voice handling.
[ ] `core.snex_shaper`: Implement an asymmetric soft clipper in SNEX and display its transfer curve, demonstrating custom per-sample waveshaping with an intentional DC asymmetry.
[ ] `core.stretch_player`: Synchronise a drum loop to the host tempo while transposing it independently, demonstrating separate time-stretch and pitch controls.
[ ] `core.table`: Use the symmetrical lookup table as a drawable waveshaper, feeding it a bipolar ramp so both polarities demonstrate the shared magnitude-based curve.

## dynamics


[X] `dynamics.comp`: A stereo synth pad should dip in level from a synthetic detector signal, creating the classic pumping effect used in dance production. The example wraps `dynamics.comp` in `container.sidechain`, replaces the duplicated detector channels with a ramp, and uses external sidechain mode so the compressor responds to that detector rather than the pad itself.
[X] `dynamics.envelope_follower`: A bright lead or vocal-like synth should become less harsh when played harder, without using a full compressor on the whole signal. `dynamics.envelope_follower` tracks the source amplitude and drives a mid-focused peak band so louder passages automatically apply more attenuation in the harsh frequency range.
[X] `dynamics.gate`: A transient-rich source should open a filtered noise layer only while the source is active, adding a short burst of texture around note attacks. The main signal feeds `dynamics.gate`, and the gate's modulation output controls the gain of a second split branch that contains an oscillator set to noise. In a real project, a looped noise sample in a file player would often be the better source, but the oscillator keeps the example minimal.
[X] `dynamics.limiter`: A stereo Script FX chain ends with a `core.expr` waveshaper that adds strong non-linear colour without being a literal hard clipper, but can still create overs that need containment. The final processor is `dynamics.limiter`, configured as a safety stage to catch transient peaks before the signal leaves the effect.
[X] `dynamics.updown_comp`: A stereo signal needs the aggressive upward and downward multiband compression associated with Ableton's famous OTT effect. The network splits the signal into low, mid, and high bands, applies independently calibrated `dynamics.updown_comp` stages, and uses a shared mix control to blend the processed bands back with their phase-matched dry counterparts.

## envelope


[X] `envelope.ahdsr`: A HISE Sine Wave Generator needs a custom envelope module instead of a built-in AHDSR. Inside a Script Envelope module, `math.fill1` creates a constant 1.0 signal that `envelope.ahdsr` shapes into the modulation output used by the audio module.
[X] `envelope.extra_mod_gate`: A polyphonic Script FX uses an extra modulation slot to drive a modulatable container parameter inside the DSP network. `envelope.extra_mod_gate` monitors the same extra modulation chain and kills the voice only after that extra envelope has finished its release.
[X] `envelope.flex_ahdsr`: A HISE Sine Wave Generator needs a custom envelope that can behave like a standard note envelope, a one-shot trigger envelope, or a looping contour. Inside a Script Envelope module, `math.fill1` creates a constant 1.0 signal that `envelope.flex_ahdsr` reshapes according to its Mode and curve parameters.
[X] `envelope.global_mod_gate`: A custom control-signal network uses a GlobalModulatorContainer envelope as the shared contour for several synchronized sound generators. The scriptnode graph reads the continuous global modulator value elsewhere, but needs a matching gate signal to stop each voice when that global envelope has released.
[X] `envelope.silent_killer`: A custom Script Envelope module generates its modulation signal by shaping a constant 1.0 value from `math.fill1`. Instead of using an explicit Gate output, `envelope.silent_killer` watches the generated modulation signal and resets the voice once note-off has occurred and the signal has fallen to silence.
[X] `envelope.simple_ar`: A monophonic Script FX needs a small internal modulation pulse for a DSP parameter, independent of incoming MIDI notes. A `control.timer` periodically drives the `Gate` parameter of `envelope.simple_ar` inside a `container.modchain`, while `math.fill1` supplies the constant 1.0 signal that the envelope shapes.
[X] `envelope.voice_manager`: A HISE Sine Wave Generator is controlled by a custom Script Envelope module. Inside the Script Envelope, `math.fill1` is shaped by `envelope.ahdsr`, and the AHDSR Gate output is wired into `voice_manager` so the voice stops after the generated envelope has released.

## filters


[ ] `filters.allpass`: Mix a six-stage allpass chain with the dry signal and sweep its frequency with an LFO to create a resonant phaser.
[ ] `filters.biquad`: Build a compact channel strip in which one biquad switches between low shelf, peak, and high shelf modes while exposing frequency, gain, and Q.
[ ] `filters.convolution`: Load a short room impulse response and wrap the convolution node in a dry/wet template to create a basic convolution reverb.
[ ] `filters.ladder`: Process a sawtooth bass oscillator with a resonant 24 dB lowpass sweep to demonstrate the ladder filter's aggressive cutoff character.
[ ] `filters.linkwitzriley`: Split a signal into complementary lowpass and highpass branches, process one band, and recombine them to demonstrate phase-coherent crossover routing.
[ ] `filters.moog`: Create an acid-style bass patch with an envelope-modulated cutoff and high resonance, focusing on the Moog ladder response.
[ ] `filters.one_pole`: Use serial highpass and lowpass instances to make a lightweight band-limited noise layer with gentle 6 dB slopes.
[ ] `filters.ring_mod`: Sweep the internal carrier from sub-audio rates into the audio range, demonstrating the transition from tremolo to metallic ring-modulation sidebands.
[ ] `filters.svf`: Apply one LFO sweep to a filter whose mode can switch between lowpass, highpass, bandpass, notch, and allpass.
[ ] `filters.svf_eq`: Create a swept presence control using Peak mode, with public frequency, gain, and Q parameters showing its parametric EQ behaviour.

## jdsp


[ ] `jdsp.jchorus`: A stereo chorus exposes rate, depth, feedback, and mix, using moderate settings to turn a static pad into a wider moving texture.
[ ] `jdsp.jcompressor`: Apply parallel compression to a drum loop and use the gain-reduction modulation output to drive a visible meter.
[ ] `jdsp.jdelay`: Create a low-CPU static slapback delay where delay time changes only occasionally and linear interpolation is sufficient.
[ ] `jdsp.jdelay_cubic`: Build a rapidly modulated flanger or chorus that uses cubic interpolation to preserve smooth movement and a flat frequency response.
[ ] `jdsp.jdelay_thiran`: Create a slowly tuned fractional-delay comb filter, demonstrating the flat response of Thiran interpolation without using fast delay modulation.
[ ] `jdsp.jlinkwitzriley`: Build a two-band processor from complementary lowpass and highpass branches, then use the allpass mode to verify phase alignment when only one branch is processed.
[ ] `jdsp.jpanner`: Pan a mono tone while switching between the seven panning laws, using output meters to show how each law changes centre loudness.

## math


[X] `math.abs`: A slow `core.ramp` is first shifted into a bipolar shape and then folded with `math.abs` so the peak display shows how absolute value can be used as a waveform-building step rather than just a numeric operation.
[X] `math.add`: A tiny scoped test chain seeds a known value, inspects it with `analyse.specs`, adds a fixed offset with `math.add`, inspects the shifted value again, and then clears the artificial signal.
[X] `math.clear`: A `container.split` creates one dry branch and one branch that should contribute only a separately generated layer. `math.clear` is placed at the start of the secondary branch so the original input does not leak into it before that branch adds its own signal.
[X] `math.clip`: A slow `core.ramp` is driven into `math.clip` with a low threshold so the output curve develops an obvious flat top in the peak display. This turns the node into a visible transfer-function example rather than a generic distortion story.
[X] `math.div`: A slow `core.ramp` is wrapped repeatedly with `math.fmod` and then rescaled by `math.div` so the output returns to a clean 0..1 range while showing more repeated segments per cycle. The same public parameter drives both math nodes.
[X] `math.expr`: A scoped test chain seeds a simple value, inspects it before and after `math.expr`, and relies on the node's own graph UI to show the shaping function. The example focuses on the fact that this node is a programmable replacement for small bespoke math transforms.
[X] `math.fill1`: A HISE Script Envelope needs a constant control signal of `1.0` that can later be shaped by an envelope node. `math.fill1` provides that seed signal so the example demonstrates why this node exists beyond simple testing.
[X] `math.fmod`: A slow `core.ramp` is wrapped repeatedly with `math.fmod` and then rescaled by `math.div` so one cycle turns into several visible sub-cycles inside the peak display. The same public parameter drives both math nodes.
[X] `math.intensity`: A slow modulation curve should be reduced in depth without lowering its ceiling from `1.0`. The example uses a simple visible modulation source and shows how `math.intensity` keeps the top of the range fixed while shrinking the excursion.
[X] `math.inv`: A scoped test chain seeds a known value, inspects it before and after `math.inv`, and then clears the artificial signal. The example focuses only on the polarity flip.
[X] `math.map`: A scoped test chain feeds a known unipolar value into `math.map`, then inspects how it is remapped into a different output range. The point is to show the clamped conversion rather than a larger patch.
[X] `math.mod2sig`: A scoped test chain starts from a known unipolar control value, converts it with `math.mod2sig`, and inspects the bipolar result before clearing the signal. The example exists to show the range conversion directly.
[X] `math.mod_inv`: A scoped test chain seeds a known 0..1 value, inverts it with `math.mod_inv`, and inspects the result. The example focuses on the unipolar inversion rather than on audio processing.
[X] `math.mul`: A scoped test chain seeds a known value, inspects it, scales it with `math.mul`, and inspects the result again before clearing the signal. This keeps the example focused on raw gain scaling.
[ ] `math.neural`: Load an RTNeural amplifier or saturation model and compare it with a level-matched `math.tanh` shaper, with the optional DC blocker enabled for asymmetric model output.
[X] `math.pack`: A slow `core.ramp` scans through a SliderPack-driven lookup so the peak display shows how a stepped or interpolated response can be drawn by editing a small number of visible points.
[X] `math.pi`: A scoped-plus-visual chain scales a known signal with `math.pi`, converts the result back into a 0..1 display range with `math.sig2mod`, and shows it on a peak display. The example is deliberately small because this node mostly exists as a support scaler for trigonometric shaping.
[X] `math.pow`: A scoped test chain seeds a unipolar value, inspects it, applies `math.pow`, and inspects the reshaped output before clearing the artificial signal. The example focuses on curve bending rather than sound design.
[X] `math.rect`: A scoped test chain seeds a normalized signal, passes it through `math.rect`, and inspects how the output becomes a hard 0 or 1 depending on the fixed threshold at `0.5`.
[X] `math.sig2mod`: A very slow oscillator drives one peak display directly and a second peak display after `math.sig2mod`. The first view shows the folded absolute-value style behavior that peak-style modulation consumers see from a bipolar signal, while the second shows the proper 0..1 modulation curve.
[X] `math.sin`: A slow `core.ramp` is scaled into radians with `math.pi`, reshaped by `math.sin`, and then converted to a 0..1 display signal for the final peak view. The result is a visual demonstration of how a phasor-like ramp becomes a sine-shaped curve.
[X] `math.sqrt`: A scoped test chain seeds a non-negative value, inspects it, applies `math.sqrt`, and inspects the concave result before clearing the artificial signal.
[X] `math.square`: A scoped test chain seeds a known value, inspects it, squares it with `math.square`, and inspects the new value before clearing the artificial signal.
[X] `math.sub`: A scoped test chain seeds a known value, inspects it, subtracts a fixed amount with `math.sub`, and inspects the shifted result before clearing the artificial signal.
[X] `math.table`: A slow `core.ramp` scans through an editable lookup table so the peak display shows the exact drawn transfer curve as an output shape. This makes the node's visual data model the main teaching point.
[X] `math.tanh`: A slow `core.ramp` is driven into `math.tanh` so the peak display shows the rounded saturation curve. The example uses a visual transfer-function setup instead of a full distortion patch.

## routing


[ ] `routing.event_data_reader`: add a panner that picks up the pan value assigned in a onNoteOn callback of a script processor.
[ ] `routing.event_data_writer`: write a random value that is picked up by a event data modulator in a stereo Fx modulation (basically the same DSP as the reader example but the other way around)
[ ] `routing.global_cable`: pick up the value of a peak node and send it to the UI. It should drive a knob value with an async callback attached to the script cable reference.
[ ] `routing.global_receive`: Start with a cleared signal, receive audio from another network, and process it through a reverb to create a cross-network auxiliary return with independent receive gain.
[ ] `routing.global_send`: Copy a dry instrument signal into a named global bus while leaving its local signal path unchanged, allowing another scriptnode network to act as an effect return.
[ ] `routing.local_cable`: fan out multiple cables from one xfader to 5ish targets in the first slot and to a local cable that connects to 5 other targets to demonstrate the visual improvement of the latter approach.
[ ] `routing.local_cable_unscaled`: same example as the local_cable one but with unscaled targets.
[ ] `routing.matrix`: a simple channel swapper
[ ] `routing.ms_decode`: a simple M/S compressor that squashes the side signal.
[ ] `routing.ms_encode`: see above
[ ] `routing.public_mod`: a network that creates a mod signal that is connected to this public_mod node so that it can be used as a black box modulator when compiled.
[ ] `routing.receive`: a very simple ping pong delay - multi container splitting the stereo signal, then swap the send / receive connection
[X] `routing.selector`: a dynamic channel router.
[ ] `routing.send`: see routing.receive

## template


[ ] `template.bipolar_mod`: use this to connect to a freq ratio set to 0.5...2.0 with 1.0 in the middle for +-1 octave pitch modulation
[ ] `template.dry_wet`: use with a reverb node to demonstrate how it works and connect the Mix parameter to a outer root parameter.
[ ] `template.feedback_delay`: Insert a lowpass filter and soft saturation into the feedback path to create progressively darker and more coloured echoes while keeping feedback below unity.
[ ] `template.freq_split2`: Use this for a multiband compressor
[ ] `template.freq_split3`: Split a stereo mix into low, mid, and high bands, keep the low band centred, and apply progressively more stereo width to the upper bands.
[ ] `template.freq_split4`: Create a four-band exciter with increasingly strong saturation toward the high bands and independent drive controls for each band.
[ ] `template.freq_split5`: Display the energy of five phase-coherent frequency bands with separate peak meters and solo gains, providing a visual crossover analyser.
[ ] `template.mid_side`: Highpass and gently saturate only the side signal while leaving the mid signal intact, creating stereo brightness without changing the centred low end.
[ ] `template.softbypass_switch2`: A click-free A/B switch selects between clean audio and a distorted processing path.
[ ] `template.softbypass_switch3`: A three-way guitar channel selector switches between clean, crunch, and lead processing chains.
[ ] `template.softbypass_switch4`: A four-way waveshaper selector switches between tanh saturation, hard clipping, sine folding, and a custom expression.
[ ] `template.softbypass_switch5`: A five-way filter selector switches between lowpass, highpass, bandpass, notch, and allpass processing paths.
[ ] `template.softbypass_switch6`: A six-way cabinet selector switches between convolution paths that use different speaker impulse responses.
[ ] `template.softbypass_switch7`: A seven-way resonator selector switches between processing paths tuned to the seven degrees of a musical scale.
[ ] `template.softbypass_switch8`: An eight-way effect audition rack switches between dry, filter, saturation, chorus, flanger, delay, reverb, and ring-modulation paths.

