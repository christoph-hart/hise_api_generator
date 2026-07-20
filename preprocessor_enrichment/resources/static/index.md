HISE preprocessors are compile-time constants that are evaluated when the compiler creates the binaries (either for HISE or your plugin). They change engine behaviour, array sizes, optional library inclusion and bit-exact audio paths at build time.

### How to use the preprocessors

You can use these preprocessors in two ways:

1. Modify the source code & recompile HISE. This is the brute force option and let's you permanently alter the behaviour of HISE. Note that this basically makes you fork HISE so whenever you update HISE you will have to perform this step again so it's only recommended if there is no other solution.
2. Add per-project settings using the ExtraDefinitions field. Every project info file has fields that allow you to set the preprocessors for each project and platform / OS. This is highly recommended for preprocessors that change between projects as recompiling HISE whenever you switch projects would not be very feasible. 

### Hot Reloading

Note that there are a few selected preprocessors that "emulate" the value from the extra definitions field in the HISE IDE so that you don't have to recompile it. The most commonly used example would be the preprocessors that define the amount of modulation slots for each hardcoded / scriptnode module: whenever you change this preprocessor, you just have to unload / load the current patch for the values to be synced to the exact value that will be used for compilation. 

This is obviously not possible with all preprocessors (eg. the inclusion of proprietary SDKs like the NKS SDK from Native Instruments cannot be "emulated" like this) and some preprocessors change internal data structures which would create too much overhead.

Preprocessors that support this functionality are marked with the *Hot Reloading: Yes** property in this reference. Note that you might have to reload the current patch (or even HISE) for it to be consistently applied as most of these values are cached at initialisation.

### Auto Config Flag

This flag means that the export procedure that happens when you compile your plugin will at some point touch this preprocessor and set it to its appropriate value, so you will most likely never have to put them into the ExtraDefinitions field. This is either directly mapped to a project settings (eg. `HISE_ENABLE_MIDI_INPUT_FOR_FX` directly represents the **Enable Midi Input For Effect Plugins** setting) or derived from other settings (eg. the `HISE_NUM_PLUGIN_CHANNELS` macro is derived from the amount of output channels of your master chain).