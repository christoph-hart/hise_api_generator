---
title: Third-Party Modules
description: Optional third-party libraries and SDK integrations — Loris, rLottie, RTNeural, pitch detection, FFTW3, IPP, xsimd, MuseHub, Beatport, NKS.
---

Preprocessors in this category compile optional third-party libraries and SDK integrations into the build. They enable Loris for additive resynthesis, rLottie for vector animations, RTNeural for real-time neural network inference, the pitch detection helper, the FFTW3 and Intel IPP FFT backends, the xsimd header, and the MuseHub, Beatport, BX Licenser and NKS storefront or DRM hooks. Most third-party flags require headers and libraries that HISE does not bundle, so turning one on without the SDK in place will fail to link. Several of these are written automatically by the export dialog from project settings, and enabling an unused one only grows the compiled binary without changing behaviour.

### `AUDIOFFT_FFTW3`

Switches the FFT convolution backend over to the FFTW3 library instead of the built-in Ooura implementation.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `0` | no | no |

Selects FFTW3 as the FFT engine used by the convolution reverb and the FFT convolver inside scriptnode's filters.convolution node. The built-in Ooura backend is lightweight and always available, whereas FFTW3 is noticeably faster for long impulse responses but has to be linked into the build separately and ships under a copyleft licence that may not suit a commercial product. The HISE exporter will only wire up an FFTW build when IPP is not active on the same platform, so enabling both at once has no effect.
> FFTW3 has to be present as an external dependency at both compile and link time. Check the licensing terms of FFTW3 before shipping the resulting binary.

**See also:** $MODULES.Convolution$ -- FFT backend used by the convolution reverb switches over to FFTW3, $SN.filters.convolution$ -- scriptnode FFT convolver switches over to FFTW3 as well, $PP.USE_IPP$ -- exporter picks IPP over FFTW3 when both are enabled on the same platform

### `HISE_INCLUDE_BEATPORT`

Compiles the Beatport authentication integration into the build.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `0` | no | no |

Enables the real implementation of the BeatportManager scripting object, which talks to the Beatport SDK to validate a product against a user's Beatport account. With the flag off, the scripting object still loads so that existing scripts compile, but setProductId is a no-op, validate returns an empty object and isBeatportAccess always reports false. The Beatport SDK has to be supplied separately and linked into the project; HISE does not bundle it.
> Only meaningful for products distributed through Beatport's plugin catalogue. Leave this off for everything else.

**See also:** $API.BeatportManager$ -- scripting object that is only functional when this flag is on

### `HISE_INCLUDE_BX_LICENSER`

Compiles the Brainworx / Plugin Alliance BX Licenser integration into the build.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `0` | no | no |

Enables the Engine.createBXLicenser scripting factory and pulls in the BX Licenser wrapper sources, which let a plugin authenticate against the Plugin Alliance licence system and redeem installer codes. With the flag off, createBXLicenser returns undefined, the wrapper sources are excluded from the unity build and no Plugin Alliance dependency is linked. The BX licensing library has to be provided separately and is only available to Plugin Alliance partner developers.
> Only set this for a product that ships through the Plugin Alliance distribution channel, because the licensing library is not publicly available.

**See also:** $API.Engine$ -- Engine.createBXLicenser is only registered when this flag is on

### `HISE_INCLUDE_LORIS`

Includes the Loris analysis and resynthesis library so scripts can access the LorisManager API.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `1` | no | yes |

Loris is an additive analysis and resynthesis toolkit that HISE uses for partial tracking, time stretching and spectral morphing of audio files. Enabling this flag compiles the entire hi_loris module (around fifty translation units), exposes Engine.getLorisManager and the LorisManager scripting class, and lets the wavetable converter use Loris-based resynthesis for cycle extraction. The flag is on by default in the HISE IDE because the Loris workflows are part of the authoring tooling, and off in the exported plugin template to keep the runtime binary small.
> Disable this in the HISE build only if compile times are a problem and you never need Loris-based tools. The plugin template already disables it automatically for exports.

**See also:** $API.LorisManager$ -- entire LorisManager scripting class is only available when this flag is on, $API.Engine$ -- Engine.getLorisManager returns a real object only when this flag is on, $API.WavetableController$ -- wavetable converter can use Loris-based resynthesis when this flag is on, $PP.USE_MOD2_WAVETABLESIZE$ -- Loris cycle extraction produces power-of-two wavetables that pair with the fast wavetable path

### `HISE_INCLUDE_MUSEHUB`

Compiles the MuseHub SDK integration into an exported plugin.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `0` | no | no |

Enables the real MuseHub licence check inside ScriptUnlocker so that Unlocker.checkMuseHub validates the plugin against a user's MuseHub account through the MuseHub SDK. With the flag off, the backend build falls back to a simulated 50/50 result after a two second delay and the frontend does nothing at all. The MuseHub SDK headers and static library have to be supplied separately by MuseHub and are only available to partners distributing through their catalogue.
> Only takes effect in exported plugin builds. The HISE IDE always runs the simulated path regardless of this setting so that the scripting API can be tested without the SDK.

**See also:** $API.Unlocker$ -- Unlocker.checkMuseHub only performs a real licence check when this flag is on

### `HISE_INCLUDE_NKS_SDK`

Compiles the Native Instruments NKS integration into the build.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `0` | no | yes |

Enables the Engine.createNKSManager scripting factory, pulls in the NKS wrapper sources and links the NKS VST3 interface hooks so that an exported plugin can show preset information, tag metadata and a factory browser inside Komplete Kontrol and Maschine. With the flag off, createNKSManager returns undefined, the NKS wrapper sources are excluded from the unity build and the frontend uses a dummy NKSVST3Interface stub. The NKS SDK has to be requested from Native Instruments separately; HISE does not ship it.
> The exporter inspects the project's Extra Definitions for this flag and skips the NKS wiring automatically when it is not present, so in most cases you only need to set it in ExtraDefinitionsWindows or ExtraDefinitionsOSX rather than on the HISE build itself.

**See also:** $API.Engine$ -- Engine.createNKSManager is only registered when this flag is on

### `HISE_INCLUDE_PITCH_DETECTION`

Compiles the dywapitchtrack pitch detection library into the build.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `1` | no | no |

Enables the PitchDetection helper class and exposes it to scripting through Buffer.detectPitch, which runs an autocorrelation-based pitch estimator over an audio buffer and returns the fundamental in Hz. With the flag off, the detection code is excluded and the scripting method is not registered, which trims a small amount from the compiled binary. Leave this on unless you are stripping HISE down to a minimal build and know that no script in the project calls detectPitch.

**See also:** $API.Buffer$ -- Buffer.detectPitch is only registered when this flag is on

### `HISE_INCLUDE_RLOTTIE`

Compiles the rLottie vector animation library so scripts can play Lottie animations in a panel.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `1` | no | yes |

Pulls in the entire hi_rlottie module and wires up the Panel animation API (setAnimation, setAnimationFrame, getAnimationData) that plays JSON-based Lottie vector animations inside a ScriptPanel. The library is statically linked by default so no extra dynamic dependency ships with the plugin. Disabling this flag removes the animation methods, skips the rLottie translation units and noticeably cuts compile time for projects that do not use vector animations at all.
> Enabled by default in both the HISE build and the exported plugin template so that animations work out of the box in new projects.

**See also:** $UI.Components.ScriptPanel$ -- Panel animation API (setAnimation, setAnimationFrame) is only compiled in when this flag is on

### `HISE_INCLUDE_RT_NEURAL`

Compiles the RTNeural inference library so scriptnode can run neural network models in real time.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `1` | no | no |

Enables the NeuralNetwork scripting class, the math.neural scriptnode node and the loaders for TensorFlow, PyTorch and ONNX models, which are the entire realtime-inference stack in HISE. With the flag off, the math.neural node still appears in the factory but renders nothing and shows 'This node is disabled. Recompile HISE with HISE_INCLUDE_RT_NEURAL' in its panel, and the NeuralNetwork holder on the MainController is compiled out so load calls fail silently.
> Must be set identically in the HISE build and the exported plugin, because the NeuralNetwork storage and the node binary layout both change when the flag is toggled.

**See also:** $API.NeuralNetwork$ -- entire NeuralNetwork scripting class is only available when this flag is on, $SN.math.neural$ -- node renders silence and shows a disabled message when this flag is off, $PP.HISE_INCLUDE_XSIMD$ -- RTNeural inference relies on the bundled xsimd header, $PP.HISE_NEURAL_NETWORK_WARMUP_TIME$ -- warmup length that only takes effect together with this integration

### `HISE_INCLUDE_XSIMD`

Signals that the surrounding project already provides the xsimd SIMD header, so HISE skips its own copy.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `0` | no | no |

When off, HISE pulls in the xsimd header that is bundled with RTNeural from hi_tools and from MiscToolClasses so that the SIMD wrappers compile against a known version. When on, the include is skipped and the project is expected to have made a different xsimd installation visible on the include path before hi_tools is parsed. Use this only if your own code also includes xsimd and the two copies clash at compile time; leaving it off is correct for almost every project.

**See also:** $PP.HISE_INCLUDE_RT_NEURAL$ -- RTNeural inference consumes the xsimd header that this flag controls

### `USE_IPP`

Enables the Intel Integrated Performance Primitives fast paths for FFT, vector math and sample playback.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `0` | no | yes |

IPP is Intel's hand-optimised SIMD library, and enabling this flag routes the FFT convolver, the sampler pitch accumulation and several vector operations through ippsAdd, ippsSum and the IPP FFT instead of the portable fallbacks. The gain on Windows is large for long convolutions and busy multi-voice samplers, but IPP has to be installed through Intel oneAPI and its libraries linked into the build separately. The flag is auto-defined to 1 on Windows when the Projucer detects any of the _IPP_SEQUENTIAL_STATIC / _IPP_PARALLEL_* macros, and is forced to 0 on macOS and Linux because IPP is Windows-only in HISE.
> The exporter writes USE_IPP=1 into the Windows Extra Definitions automatically when the 'Use IPP' project setting is on, so it should normally not be set by hand. Setting it manually on macOS or Linux fails a static_assert in hi_lac.

**See also:** $MODULES.Convolution$ -- IPP FFT routines replace the portable convolution backend, $API.Settings$ -- Settings.getUseIpp reports the compile-time value of this flag, $PP.AUDIOFFT_FFTW3$ -- IPP takes precedence over FFTW3 when both are enabled on the same platform
