---
description: Macro control count and MIDI automation storage — how many macros exist, whether they are host parameters, and how CC mappings persist.
---

Preprocessors in this category size and shape the MIDI automation and macro control system. They set how many macro controls exist per project, whether those macros are also exposed as plugin parameters to the host, how the MIDI learn mapping stores CC assignments, whether the FX plugin accepts MIDI input, and whether legacy preset automation slots are migrated on load. Changing any of these after a release can invalidate stored automation data in user presets, so pick sensible values during early development and leave them alone. The macro-count flags also affect the size of every stored preset.
