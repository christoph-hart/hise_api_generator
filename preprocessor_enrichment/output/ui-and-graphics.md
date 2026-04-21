---
title: UI & Graphics
description: Plugin UI code-path toggles — OpenGL rendering, bundled Lato font, alert look-and-feel, floating tiles, registration overlay, splash screen.
---

Preprocessors in this category shape the plugin's user interface and rendering path. They turn OpenGL rendering on or off by default, include the bundled Lato font as the global default, enable the custom alert window look-and-feel, register external custom floating tiles, swap the default registration overlay for custom script-driven UI, toggle the startup splash screen, and gate the big scriptnode-template compilation path that produces heavier UI widgets. None of these affect the audio engine; all they change is which UI code is compiled in and which default appearance users see on first launch. Disabling optional parts of this group is the easiest way to trim compile time and binary size for headless or utility builds.

## Deprecated

These macros are still defined so old projects keep compiling, but no code reads them. Setting them has no effect.

### INCLUDE_BIG_SCRIPTNODE_OBJECT_COMPILATION

Historical switch for excluding large scriptnode template instantiations from the build.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `1` | no | no |

The original purpose was to skip the bigger multi-template scriptnode objects during compilation so that iterative debug builds finished faster. The macro is still defined but no code reads it anywhere, so setting it has no effect on the build output or the runtime. It's kept around to avoid breaking user projects that still list it in their ExtraDefinitions.
