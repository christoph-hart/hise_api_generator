---
description: Parameter modulation slot counts for every scriptnode and hardcoded host module, plus the master cap that limits modulators per chain.
---

Preprocessors in this category size the modulation chain slots exposed by scriptnode effects, scriptnode synthesisers and their hardcoded C++ counterparts. Each flag adds parameter modulation slots to a specific host module (Script FX, Polyphonic Script FX, Scriptnode Synth, Hardcoded Master FX, Hardcoded Polyphonic FX, Hardcoded Synth), plus a master cap that limits how many modulators any single chain can hold. Monophonic slots are cheap at control rate, but polyphonic slots run once per voice so raising them scales the voice cost. Changing the slot count after a project ships forces users to reload the affected modules.
