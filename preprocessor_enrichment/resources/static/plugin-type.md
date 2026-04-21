---
description: Plugin type and host bus configuration — instrument vs effect, audio input routing, mono layout, and FX-build sound generator handling.
---

Preprocessors in this category tell the compiled plugin what kind of thing it is and how it connects to the host. They control whether the plugin is an instrument or an effect, whether an instrument build accepts audio input on its master chain, whether an effect build advertises a mono bus layout alongside stereo, and whether child sound generators keep running inside an effect plugin so that their modulation signals are still rendered. The HISE export dialog writes most of these flags automatically from project settings, so they rarely need to be set by hand in the Extra Definitions field. Manual overrides are only useful for edge cases such as multi-bus builds or specialised hybrid plugins.
