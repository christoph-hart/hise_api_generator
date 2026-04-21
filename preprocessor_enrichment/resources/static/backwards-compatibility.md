---
description: Flags that re-enable superseded HISE behaviours so shipped products keep sounding identical after a rebuild.
---

Preprocessors in this category restore historical HISE behaviours that were later fixed or improved. Each flag re-enables a specific quirk (old voice render order, squared modulation values, off-by-one block timestamps, the pre-HLAC monolith format and similar) so that a shipped product keeps sounding bit-exact when it is recompiled against a newer HISE build. They are not meant for new projects; the defaults are always the corrected behaviour. Several entries in this category are vestigial stubs kept only so that projects listing them in their Extra Definitions still compile.
