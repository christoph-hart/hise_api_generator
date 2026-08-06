# Ideas for HSC examples

This file contains loose ideas that can be used as starting point for the example HSC nodes. 

## fx

`fx.haas`: A polyphonic FX that positions every voice in the stereo field using a random node that creates a static position on voice start (using voice_bang)
`fx.phase_delay`: A 1:1 recreation of the HISE PhaseFX module (with an extra_mod modulating the frequency)
`fx.reverb`: A simple wrapper around the reverb node that propagates all parameters including a dry/wet template.
`fx.bitcrush`: A delay with a bitcrusher in the feedback chain. Use the feedback template.
`fx.sampleandhold`: A random step sequencer using a noise oscillator and the sample & hold node to create temposynced randomized steps
`fx.pitch_shift`: A simple chorus effect using a dry/wet template

## analyse

`analyse.fft`: A split container with different oscillators going into different fft nodes (saw / sine, noise)
`analyse.oscilloscope`: Inside a midi processing node to demonstrate the dynamic buffer size functionality
`analyse.goniometer`: two nodes, before and after a reverb node to show how the reverb creates the stereo field
`analyse.specs`: Multiple different containers that contain a few nodes to show how the processing specs are modified (midi, modchain, fix block, oversample), etc.

## container

`container.branch`: Multiple math.expr waveshaping nodes (tanh, HISE saturation, sine folding) branched with this container. 
`container.chain`: Show how nested parameters work: connect a modulation output of a nodeto a macro parameter of an inner chain which then connects to some nodes.
`container.clone`: unisono saw oscillator with dynamic unisono amount & spread
`container.fix_xxx`: show modulation of a ramp to an add node to demonstrate how the modulation creates the staircase artifacts with higher blocksizes. With and without the node
`container.frame_xxx`: show modulation of a interpolating delay line for chorus effects
`container.midichain`: show a monophonic synthesiser in a Script FX (oscillator & simple_ar within a midichain)
`container.modchain`: create a simple LFO signal that modulates the freq ratio of a oscillator for subtle vibrato.
`container.multi`: simple panning effect: xfader -> 2x math.mul. 
`container.no_midi`: A polyphonic synthesiser network that adds a oscillator in this node for a hardwired LFO. the no_midi prevents the frequency from being set by the incoming note on
`container.offline`: A chain of multiple control nodes put in a offline container for lighter CPU work.
`container.oversample`: An aggressive waveshaper that introduces harmonics
`container.repitch`: A wrapped reverb node that can have its size / length "modulated" by the pitch parameter
`container.soft_bypass`: A "vocal channel-strip" using different elements (HPF, compressor, waveshaper, etc). Each stage can be soft bypassed.
`container.split`: A "silencer" that copies the signal, multiplies it with -1 and adds it back. Demonstrates how the signal is copied without latency.


