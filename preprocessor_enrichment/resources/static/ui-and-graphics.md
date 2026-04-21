---
description: Plugin UI code-path toggles — OpenGL rendering, bundled Lato font, alert look-and-feel, floating tiles, registration overlay, splash screen.
---

Preprocessors in this category shape the plugin's user interface and rendering path. They turn OpenGL rendering on or off by default, include the bundled Lato font as the global default, enable the custom alert window look-and-feel, register external custom floating tiles, swap the default registration overlay for custom script-driven UI, toggle the startup splash screen, and gate the big scriptnode-template compilation path that produces heavier UI widgets. None of these affect the audio engine; all they change is which UI code is compiled in and which default appearance users see on first launch. Disabling optional parts of this group is the easiest way to trim compile time and binary size for headless or utility builds.
