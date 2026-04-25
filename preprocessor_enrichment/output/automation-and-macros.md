---
title: Automation & Macros
description: Macro control count and MIDI automation storage — how many macros exist, whether they are host parameters, and how CC mappings persist.
---

Preprocessors in this category size and shape the MIDI automation and macro control system. They set how many macro controls exist per project, whether those macros are also exposed as plugin parameters to the host, how the MIDI learn mapping stores CC assignments, whether the FX plugin accepts MIDI input, and whether legacy preset automation slots are migrated on load. Changing any of these after a release can invalidate stored automation data in user presets, so pick sensible values during early development and leave them alone. The macro-count flags also affect the size of every stored preset.

### `HISE_ENABLE_MIDI_INPUT_FOR_FX`

Routes incoming MIDI data into the MIDI processor chain of an exported effect plugin.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `0` | no | yes |

Only relevant when the project is exported as an effect plugin. By default an FX plugin ignores MIDI entirely, because most DAWs do not route MIDI to audio track inserts and the keyboard-state processing step is pure overhead in that case. Enabling this flag makes the plugin advertise a MIDI input, consume note and controller messages from the host and run them through the master chain's MIDI processors and the MIDI automation handler. Use this for effects that need keytracking, note-triggered modulation or host-side MIDI automation of a plugin parameter.
> The HISE export dialog writes this flag automatically from the 'Enable Midi Input For Effect Plugins' project setting, so you normally do not need to set it manually in the ExtraDefinitions field.

**See also:** $PP.PROCESS_SOUND_GENERATORS_IN_FX_PLUGIN$ -- sibling FX export flag that keeps sound generators running so MIDI-triggered modulators still produce values, $PP.HISE_USE_MIDI_CHANNELS_FOR_AUTOMATION$ -- MIDI channel filtering only takes effect once MIDI actually reaches the FX plugin

### `HISE_ENABLE_MIDI_LEARN`

Lets the end user assign MIDI CC numbers to knobs and buttons through the right-click menu.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `1` | no | no |

Controls whether the MIDI Learn entry appears on the context menu of macro-controlled UI components and whether incoming CC messages can be bound to a control at runtime. The default is on for instrument plugins and the standalone app and off for exported effect plugins, because an effect plugin normally does not receive MIDI anyway. Disable this on an instrument build only if you ship your own CC-to-parameter workflow through scripting and want to hide the stock assignment UI.
> If you turn this on for an exported effect plugin, pair it with the MIDI input flag so that CC messages actually reach the automation handler in the first place.

**See also:** $API.MidiAutomationHandler$ -- MIDI learn assignments are stored and queried through this scripting object, $PP.HISE_ENABLE_MIDI_INPUT_FOR_FX$ -- effect plugins need MIDI input enabled before the learn menu can receive CC messages

### `HISE_MACROS_ARE_PLUGIN_PARAMETERS`

Publishes every macro control as a dedicated plugin parameter in front of the scripted automation slots.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `0` | yes | no |

When enabled, the exported plugin advertises one plugin parameter per active macro slot before any custom automation slot or scripted plugin parameter, which lets the host automate macros directly instead of routing through a UI component. The plugin parameter index reported to the host changes because the macro slots occupy the first positions, and macro state no longer restores from user presets when the preset system is running in exclusive mode (which matches how plugin parameters are normally managed by the DAW rather than by the preset). Combine this with a reduced macro count to keep the parameter list compact.
> Read at runtime from the Extra Definitions, so no HISE rebuild is required. Pair it with HISE_NUM_MACROS so the number of exposed plugin parameters matches the macros you actually use.

**See also:** $API.MacroHandler$ -- macro slots exposed as plugin parameters are the ones managed through this scripting object, $MODULES.MacroModulationSource$ -- every macro slot is mirrored as a front-of-list plugin parameter when this is on, $PP.HISE_NUM_MACROS$ -- determines how many macro plugin parameters the host sees

### `HISE_NUM_MACROS`

Number of active macro control slots that the project exposes on the master chain.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `8` | yes | no |

Sets how many macro slots are visible to scripts, to the macro handler, to the Macro Modulation Source synthesiser and to the macro plugin-parameter publishing path. The default of 8 matches the original HISE layout and the UI panels that show a fixed eight-knob strip; values between 1 and the project-wide ceiling let you trim a compact product or scale up to a modular rig with many assignment targets. The value is read at runtime, so changing it in the Extra Definitions and reopening the project is enough to see the new slot count without a HISE rebuild.
> Must not exceed the project-wide macro ceiling of 64, otherwise compilation fails with a hard error.

**See also:** $API.MacroHandler$ -- slot count seen by every scripting call that enumerates macros, $API.Engine.setFrontendMacros$ -- setFrontendMacros expects a name list sized to this value, $MODULES.MacroModulationSource$ -- chain count of the macro modulation source synthesiser matches this value, $MODULES.MacroModulator$ -- macro modulator slot index is validated against this value, $PP.HISE_NUM_MAX_MACROS$ -- hard upper ceiling that this value must not exceed, $PP.HISE_MACROS_ARE_PLUGIN_PARAMETERS$ -- determines how many plugin parameters are published when macros become plugin parameters

### `HISE_NUM_MAX_MACROS`

Compile-time ceiling on the number of macro slots that internal fixed-size arrays reserve space for.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `64` | no | no |

Sets the fixed array size used for macro bookkeeping inside the main controller and the macro modulation source, so that the macro slot count can be changed at runtime without reallocating per-slot state. The default of 64 covers every realistic macro layout and only needs to be raised if a project genuinely needs more than 64 simultaneous macro assignments. Raising it grows every per-macro array proportionally, so do not inflate this value beyond what the project actually uses.
> Must be at least as large as the active macro count, otherwise compilation fails with a hard error. This value is baked into the binary at compile time and must match between the HISE build and any project DLL or exported plugin.

**See also:** $PP.HISE_NUM_MACROS$ -- active macro slot count that must stay at or below this ceiling

### `HISE_USE_MIDI_CHANNELS_FOR_AUTOMATION`

Enables per-channel MIDI CC assignment so the same CC number on different channels can control different parameters.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `0` | yes | no |

By default the MIDI automation handler ignores the channel field of an incoming CC message, so CC 1 on channel 1 and CC 1 on channel 2 both drive the same assigned control. Enabling this flag switches the automation iterator to a channel-aware mode, stores a channel field alongside every assignment and makes the JSON automation objects include that field. This lets you build a plugin that responds to the same CC number differently depending on which MIDI channel carries it, for example separate knobs locked to channels 1 and 2 of a multi-timbral controller.
> Read at runtime from the Extra Definitions, so no HISE rebuild is required. Enabling MIDI learn while this is on retains assignments on other channels and only replaces connections that share the new assignment's channel or that were stored as Omni.

**See also:** $API.MidiAutomationHandler$ -- channel field on the JSON automation object only appears when this flag is on, $PP.HISE_ENABLE_MIDI_LEARN$ -- channel filtering is applied on top of the MIDI learn assignment workflow

### `USE_MIDI_AUTOMATION_MIGRATION`

Opt-in flag for supplying a custom old-to-new automation index conversion when loading legacy user presets.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `0` | no | no |

When a user preset from an older plugin version is loaded, the MIDI automation restore path calls a conversion helper that maps the stored integer automation index onto the current identifier-based scheme. The default implementation does nothing and returns an empty identifier, so legacy CC assignments are silently dropped on load. Enabling this flag and providing your own implementation of the conversion function lets you keep CC assignments working across a parameter reshuffle, for example when you have renamed or reordered controls between plugin versions.
> Only useful if you also supply the custom conversion function in your project code. Without that, enabling the flag has no effect beyond skipping the default empty-identifier fallback.

**See also:** $API.MidiAutomationHandler$ -- legacy user preset migration path for CC assignments is governed by this flag

## Deprecated

These macros are still defined so old projects keep compiling, but no code reads them. Setting them has no effect.

### `HI_NUM_MIDI_AUTOMATION_SLOTS`

Historical switch that was intended to size the MIDI automation slot table.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `8` | no | no |

The original purpose was to set the number of MIDI controller automation slots allocated by the MIDI automation handler. The macro is still defined with a hard-coded value of 8 but no code reads it anywhere, so toggling or redefining it has no effect on the number of available CC assignments or on how the automation handler stores its data. It is kept around only so that older user projects which list it in their ExtraDefinitions still compile.
