---
title: Modulator Slots
description: Parameter modulation slot counts for every scriptnode and hardcoded host module, plus the master cap that limits modulators per chain.
---

Preprocessors in this category size the modulation chain slots exposed by scriptnode effects, scriptnode synthesisers and their hardcoded C++ counterparts. Each flag adds parameter modulation slots to a specific host module (Script FX, Polyphonic Script FX, Scriptnode Synth, Hardcoded Master FX, Hardcoded Polyphonic FX, Hardcoded Synth), plus a master cap that limits how many modulators any single chain can hold. Monophonic slots are cheap at control rate, but polyphonic slots run once per voice so raising them scales the voice cost. Changing the slot count after a project ships forces users to reload the affected modules.

### `HISE_NUM_MODULATORS_PER_CHAIN`

Maximum number of modulators a single modulation chain can hold.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `64` | no | no |

Caps how many modulators (LFOs, envelopes, velocity modulators, script modulators and so on) may be inserted into any gain, pitch or parameter modulation chain in the project. The value also sizes the active-modulator lookup tables inside each chain and the scriptnode modulation source registry, so raising it increases per-chain memory footprint even when the extra slots stay empty. Only increase this if you hit the limit with a genuinely dense modulation setup.
> Sensible range is 16 to 256.

### `HISE_NUM_POLYPHONIC_SCRIPTNODE_FX_MODS`

Number of extra modulation chain slots exposed by polyphonic scriptnode effects.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `0` | yes | no |

Adds per-voice modulation chain slots to every Polyphonic Script FX module so that polyphonic modulators can drive root parameters of the embedded scriptnode network. Because the slots run per voice, each active slot contributes to the polyphonic voice cost and memory footprint, so keep this as low as the project actually needs. Changing the value after a project has been saved will prompt users to reload the affected effects.
> Sensible range is 0 to 4.

**See also:** $MODULES.PolyScriptFX$ -- host module that exposes these modulation slots, $SN.core.extra_mod$ -- node that reads the modulation signal inside the network, $PP.HISE_NUM_SCRIPTNODE_FX_MODS$ -- monophonic counterpart for master script effects, $PP.NUM_HARDCODED_POLY_FX_MODS$ -- equivalent slot count for compiled polyphonic effects, $PP.HISE_NUM_MODULATORS_PER_CHAIN$ -- master cap on modulators that can occupy each slot

### `HISE_NUM_SCRIPTNODE_FX_MODS`

Number of extra modulation chain slots exposed by monophonic scriptnode effects.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `0` | yes | no |

Adds modulation chain slots to every Script FX module so that standard HISE modulators can drive root parameters of the embedded scriptnode network, either via the External Modulation property on a parameter or via a core.extra_mod node placed inside the network. Slots are evaluated at control rate and carry no measurable CPU cost when left empty, so the value can be sized to the worst-case network without penalty. Changing the value after a project has been saved will prompt users to reload the affected effects.
> Sensible range is 0 to 8.

**See also:** $MODULES.ScriptFX$ -- host module that exposes these modulation slots, $SN.core.extra_mod$ -- node that reads the modulation signal inside the network, $PP.HISE_NUM_POLYPHONIC_SCRIPTNODE_FX_MODS$ -- polyphonic counterpart for per-voice script effects, $PP.NUM_HARDCODED_FX_MODS$ -- equivalent slot count for compiled hardcoded effects, $PP.HISE_NUM_MODULATORS_PER_CHAIN$ -- master cap on modulators that can occupy each slot

### `HISE_NUM_SCRIPTNODE_SYNTH_MODS`

Number of extra modulation chain slots exposed by scriptnode synthesisers.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `2` | yes | no |

Adds per-voice modulation chain slots to every Scriptnode Synthesiser so that standard HISE modulators can drive root parameters of the embedded scriptnode network in addition to the built-in gain and pitch chains. The default of two covers common filter-cutoff and amp-modulation patches; raise it only when the synth needs more independent modulation targets. Changing the value after a project has been saved will prompt users to reload the affected synths.
> Sensible range is 0 to 8.

**See also:** $MODULES.ScriptSynth$ -- host module that exposes these modulation slots, $SN.core.extra_mod$ -- node that reads the modulation signal inside the network, $PP.NUM_HARDCODED_SYNTH_MODS$ -- equivalent slot count for compiled hardcoded synthesisers, $PP.HISE_NUM_MODULATORS_PER_CHAIN$ -- master cap on modulators that can occupy each slot

### `NUM_HARDCODED_FX_MODS`

Number of extra modulation chain slots exposed by hardcoded master effects.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `0` | yes | yes |

Adds modulation chain slots to every Hardcoded Master FX module so that standard HISE modulators can drive parameters of the compiled C++ DSP network. The project exporter writes this value into the exported plugin automatically, so configuring it from Extra Definitions while developing is usually enough. Slots are evaluated at control rate and carry no measurable CPU cost when left empty. Changing the value after a project has been saved will prompt users to reload the affected effects.
> Sensible range is 0 to 8.

**See also:** $MODULES.HardcodedMasterFX$ -- host module that exposes these modulation slots, $SN.core.extra_mod$ -- node that reads the modulation signal inside the network, $PP.HISE_NUM_SCRIPTNODE_FX_MODS$ -- equivalent slot count for interpreted script effects, $PP.NUM_HARDCODED_POLY_FX_MODS$ -- polyphonic counterpart for per-voice hardcoded effects, $PP.HISE_NUM_MODULATORS_PER_CHAIN$ -- master cap on modulators that can occupy each slot

### `NUM_HARDCODED_POLY_FX_MODS`

Number of extra modulation chain slots exposed by hardcoded polyphonic effects.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `0` | yes | yes |

Adds per-voice modulation chain slots to every Hardcoded Polyphonic FX module so that polyphonic modulators can drive parameters of the compiled C++ DSP network. The project exporter writes this value into the exported plugin automatically. Each active slot runs once per voice, so keep this as low as the project actually needs to avoid scaling the polyphonic voice cost. Changing the value after a project has been saved will prompt users to reload the affected effects.
> Sensible range is 0 to 4.

**See also:** $MODULES.HardcodedPolyphonicFX$ -- host module that exposes these modulation slots, $SN.core.extra_mod$ -- node that reads the modulation signal inside the network, $PP.HISE_NUM_POLYPHONIC_SCRIPTNODE_FX_MODS$ -- equivalent slot count for interpreted polyphonic script effects, $PP.NUM_HARDCODED_FX_MODS$ -- monophonic counterpart for master hardcoded effects, $PP.HISE_NUM_MODULATORS_PER_CHAIN$ -- master cap on modulators that can occupy each slot

### `NUM_HARDCODED_SYNTH_MODS`

Number of extra modulation chain slots exposed by hardcoded synthesisers.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `2` | yes | no |

Adds per-voice modulation chain slots to every Hardcoded Synthesiser so that standard HISE modulators can drive parameters of the compiled C++ DSP network in addition to the built-in gain and pitch chains. The default of two covers common filter-cutoff and amp-modulation patches; raise it only when the synth needs more independent modulation targets. Changing the value after a project has been saved will prompt users to reload the affected synths.
> Sensible range is 0 to 8.

**See also:** $MODULES.HardcodedSynth$ -- host module that exposes these modulation slots, $SN.core.extra_mod$ -- node that reads the modulation signal inside the network, $PP.HISE_NUM_SCRIPTNODE_SYNTH_MODS$ -- equivalent slot count for interpreted scriptnode synthesisers, $PP.HISE_NUM_MODULATORS_PER_CHAIN$ -- master cap on modulators that can occupy each slot
