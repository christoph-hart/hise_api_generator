---
description: Optional third-party libraries and SDK integrations — Loris, rLottie, RTNeural, pitch detection, FFTW3, IPP, xsimd, MuseHub, Beatport, NKS.
---

Preprocessors in this category compile optional third-party libraries and SDK integrations into the build. They enable Loris for additive resynthesis, rLottie for vector animations, RTNeural for real-time neural network inference, the pitch detection helper, the FFTW3 and Intel IPP FFT backends, the xsimd header, and the MuseHub, Beatport, BX Licenser and NKS storefront or DRM hooks. Most third-party flags require headers and libraries that HISE does not bundle, so turning one on without the SDK in place will fail to link. Several of these are written automatically by the export dialog from project settings, and enabling an unused one only grows the compiled binary without changing behaviour.
