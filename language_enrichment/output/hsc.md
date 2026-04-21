---
title: CLI Slash commands
description: "Language reference for the hise-cli commands and .hsc files"

guidance:
  summary: >
    Reference for the .hsc script language executed by hise-cli. Part one
    introduces where the language is used (interactive TUI, single-shot
    CLI, multiline editor, .hsc script runner) and walks through a full
    end-to-end example. Part two covers the language itself: mode
    entry/exit, single-shot vs persistent switches, slash commands,
    natural-language mode commands, comments, quoting, lenient truthy
    comparison, dot syntax for parent/child paths, and navigation
    (cd/ls/pwd, sidebar). Part three is a per-mode reference for
    builder, ui, script, dsp, sampler, inspect, undo, hise, sequence,
    analyse, project, and export, each with a data-model overview,
    grammar example, and a full command list. Later sections cover the
    cross-mode tools (/run, /parse, /wait, /expect), callback
    compilation (/callback, /compile), wizards, workflow patterns
    (plan groups, hermetic tests, audio-timed assertions, UI
    simulation), a common-mistakes table, editor key bindings, and a
    differences-from-shell table. The HiseScript expression grammar
    used inside /script is covered separately: see hisescript.md.
  concepts:
    - hsc
    - slash commands
    - modes
    - single-shot
    - /run
    - /parse
    - /expect
    - /wait
    - /callback
    - /compile
    - builder
    - script
    - dsp
    - ui
    - sequence
    - analyse
    - undo
    - hise
    - wizards
    - plan groups
    - sequence eval
    - multiline editor
  prerequisites:
    - hisescript
  complexity: intermediate
---


## Introduction

HSC is a bash-like language for hise-cli. It is the same surface in every context: what you type at the TUI prompt, as arguments to one-shot CLI invocations, or inside a `.hsc` file handed to the script runner.

It acts as a remote controller for HISE and aims to replace all UI interactions with a clearly defined and agent-visible interface. So instead of

1. Opening HISE
2. Click on File -> load project
3. Select the project folder in the file browser
4. Click on File -> load Xml preset -> My Project.xml
5. Click on Export -> Compile
6. Select plugin
7. Click on Next

You can just type / run

```hsc
/hise launch
/project 
switch My Project
load My Project.xml
export VST3
/exit
```

and HISE will launch and perform all the steps completely automatic.

### Where HSC Runs

- **Interactive TUI** - typed line by line at the prompt. Use for exploration and step-by-step builds.
- **Multiline editor** - `/edit` opens a buffer with syntax highlighting and completion; `Ctrl+Enter` runs the buffer as a script.
- **One-shot CLI** - `hise-cli -<mode> "<command>"` runs a single command and prints a JSON result, for shell pipelines and agents.
- **Script runner** - `/run <file.hsc>` in the TUI, or `hise-cli --run <file.hsc>` on the command line. Executes a file of HSC commands end to end, with assertions.

All four surfaces accept the same syntax. A command that works in the REPL works verbatim in a `.hsc` file.

### Design Decisions

- **Natural-language mode commands.** Inside a mode, commands read like short English sentences: `add SineSynth as Lead to Master Chain`, `set Volume -6`, `connect LFO to F1.Frequency`. Verbs and prepositions (`add`, `to`, `as`, `into`) are keywords; everything else is an identifier, number, or quoted string.
- **One command per line.** No line continuation, no heredocs. Commas chain several commands on one line where related verbs share context (for example `add LFO, set LFO.Frequency 2`).
- **Scoped context modes.** Work happens inside a mode (`/builder`, `/ui`, `/script`, and so on). Modes hold state (current parent, current processor, current host). Leave with `/exit`, which pops one level on a stack. The single-shot form (`/builder add LFO`) runs one command without pushing the mode, so the caller's context is preserved.
- **Truthy-lenient comparisons.** `/expect` treats `1`, `"1"`, `"true"`, and `true` as equal; numeric strings match with a default `0.01` tolerance. This keeps test scripts readable across the minor type coercions that happen at the API boundary.

### Full Example

This `.hsc` script exercises most of the language. It launches HISE, builds a small signal chain, wires a UI control to a module parameter declaratively, installs a HiseScript callback, plays a note, and asserts that exactly one voice was alive during playback. Read top to bottom. Every section below builds on pieces of this example.

```hsc
#!/usr/bin/env hise-cli run
# onboarding.hsc - end-to-end tour of hsc

# 1. start HISE (or verify it's already running)
/hise launch

# 2. build a module tree: a sine synth routed through a gain stage
/builder
reset
add SineSynth as Lead to Master Chain
add SimpleGain to Lead
set Lead.Gain 0.5
/exit

# 3. build a minimal UI and bind a knob to Lead.Gain declaratively
/ui
add ScriptSlider as VolKnob at 10 10 128 48
set VolKnob.text "Volume"
set VolKnob.processorId "Lead"
set VolKnob.parameterId "Gain"
/exit

# 4. install an onNoteOn callback; verify the interface compiled
/script
/callback onInit
Content.makeFrontInterface(600, 200);

/callback onNoteOn
Console.print("note: " + Message.getNoteNumber());

/compile
/expect Content.getComponent("VolKnob").getValue() is 0.5 within 0.01 or abort
/exit

# 5. play a note; assert exactly one voice is alive at 250 ms
/sequence
create "hello"
0ms  play C3 100 for 500ms
250ms eval Synth.getNumPressedKeys() as DURING
600ms eval Engine.getNumVoices()       as AFTER
flush
play "hello"
/expect get DURING is 1
/expect get AFTER  is 0
/exit

# 6. clean up
/hise shutdown
```

Run it with `/run onboarding.hsc` (inside the TUI) or `hise-cli --run onboarding.hsc` (shell).


## Language

### Modes

A mode is a scoped command context. Entering a mode pushes it on a stack; `/exit` pops one level. `/quit` leaves the application regardless of depth.

**Persistent switch** - enter a mode, issue several commands, exit:

```hsc
/builder
reset
add SineSynth as Lead
/exit
```

**Single-shot** - run one command without pushing the mode. The caller's context is preserved:

```hsc
/ui
add ScriptButton as B1
set B1.text "My Button"

# temporarily evaluate a HiseScript expression - does NOT push script mode
/script Content.getComponent("B1").get("text") == "My Button"   // => true

# we're still in UI mode
add ScriptSlider as K1
/exit
```

**Dot context** - attach a context path to the mode name:

```hsc
/builder.Master          # enter builder with parent = Master
/script.Interface        # enter script targeting the Interface processor
/dsp."Script FX1"        # quote names that contain spaces
/builder.Master add LFO  # one-shot with context
```

Available modes are listed in the [Mode Reference](#mode-reference).

### Syntax

**Slash commands** open/close modes and invoke tools that work across modes (`/run`, `/expect`, `/wait`, `/wizard`). A slash command is any line whose first non-space character is `/`.

**Natural-language** commands live inside a mode. Keywords are case-insensitive; identifiers preserve case:

```hsc
/builder
add SineSynth as Sine to Master Chain
set Sine.Gain 0.5
/exit
```

**Comments** - `#` and `//` both start a comment. A comment runs to end of line and can stand alone or trail a command. Inside quoted strings, `#` and `//` are literal.

```hsc
# full-line comment
/builder
add SimpleGain        # trailing comment
// also a comment
set Label.text "tag: #1"   # the # inside quotes is literal
/exit
```

**Quoted strings** - double and single quotes are equivalent. Quotes are required whenever a name, path, or value contains spaces or punctuation. Inside a quoted string, `\"` and `\\` are the only recognised escape sequences; `\n`, `\t`, and the like are literal.

```hsc
add "Sine Wave Generator" as "My Sine"
rename 'My Module' to "Renamed"
```

**Lenient truthy values** - `/expect` and value parsers treat the following as equivalent:

| Written | Equal to |
| --- | --- |
| `1`, `"1"`, `"true"`, `true` | truthy (boolean true, non-zero number) |
| `0`, `"0"`, `"false"`, `false` | falsy |
| numeric strings like `"0.5"` | the number `0.5`, with default tolerance `0.01` |
| `"25%"` | `0.25` |

> [!Tip:Lenient truthy matches in /expect] Boolean coercions and numeric-string comparisons are handled automatically, so `/expect 0.5 + 0.5 is true` and `/expect Knob.getValue() is "25%"` both work without explicit conversion.

```hsc
/script
/expect 0.5 + 0.5 is true      # 1 == true
/expect isDefined(Knob1) is 1
/exit
```

**Dot syntax** expresses parent-child relationships. `<parent>.<child>` works for module-parameter, component-property, node-parameter, and processor-callback paths. Either side can be quoted:

```hsc
/builder
set Sine.Gain 0.5
set "My Sine".Gain 0.5          # quoted parent works identically
/exit

/ui
set "Volume Knob".text "Vol"
/exit
```

**Comma chaining** runs several commands on one line. Verbs (and, in some modes, targets) inherit across segments:

```hsc
# builder: verb + target inheritance
set Master.Volume -6, Balance 15, Bypass 0

# ui: verb inheritance on add
add ScriptButton "Play", ScriptSlider "Volume", ScriptPanel "Header"

# ui: set-target inheritance
set Knob.x 100, y 200, width 128

# dsp: verb inheritance on set
set A.Freq 440, B.Freq 880
```

Break into separate lines when you need to inspect an intermediate result.

**Clone multiplier** - `x<N>` (no space) is a repeat suffix accepted by `clone`:

```hsc
clone LFO x3     # three copies
```

### Navigation

Modes with a hierarchy expose `cd`, `ls`, and `pwd` - directly analogous to the same verbs in bash and Windows batch. `cd <path>` sets the current parent (subsequent `add` commands target it). `cd ..` goes up one level; `cd /` returns to the root. `ls` lists children at the current path; `pwd` prints the current path.

```hsc
/ui
add ScriptPanel as BG
cd BG                        # BG becomes the current parent

add ScriptPanel as TopBar
cd TopBar

add ScriptButton as MainButton
add ScriptButton as FxButton
add ScriptButton as PresetButton

cd ..                        # back up to BG
add ScriptPanel as MainContent

cd /                         # back to root
ls                           # lists top-level components
/exit
```

The same pattern applies in `/builder` (module tree) and `/dsp` (scriptnode graph). `/analyse` uses `cd` to browse folders on disk.

**Sidebar shortcut.** Every navigable mode has a tree sidebar. `Ctrl+B` toggles it; `Tab` moves focus between input and sidebar; once focused, arrow keys walk the tree and `Return` sets the selected node as the current parent - a visual replacement for `cd`. `Esc` returns focus to the input.


## Mode Reference

Each mode is listed with a short description, its data model, a grammar example, and the complete command list. Command tables use `<required>` / `[optional]` notation in the Arguments column; the Description column covers purpose, types, and edge cases.

### Builder

Module tree editor. Adds, removes, configures, and navigates the HISE module tree.

**Data model.** HISE organises processing as a tree rooted at `Master Chain`. Every module lives in a **chain**: a typed slot on its parent:

| Chain | Holds |
| --- | --- |
| `children` | Sound generators and containers (main signal path) |
| `fx` | Effect processors (filters, reverbs, delays) |
| `midi` | MIDI processors (arpeggiators, scripts, transposers) |
| `gain` | Gain modulators (LFOs, envelopes on volume) |
| `pitch` | Pitch modulators (vibrato, glide) |

Chain is auto-resolved from module category (SoundGenerators into `children`, Effects into `fx`, MidiProcessors into `midi`). Modulators require an explicit `.gain` or `.pitch`.

**Entry**

```hsc
/builder
/builder.Master          # enter with default parent = Master
/builder add SimpleGain  # one-shot
```

**Example**

```hsc
/builder
reset
add SineSynth as "Lead" to Master Chain
add SimpleGain to Lead
add AHDSR to Lead.gain
set Lead.Volume -6
show tree
/exit
```

Common module types used in the examples above: [SineSynth]($MODULES.SineSynth$), [SimpleGain]($MODULES.SimpleGain$), [AHDSR]($MODULES.AHDSR$), [LFO]($MODULES.LFO$), [Script FX]($MODULES.ScriptFX$), [Script Synthesiser]($MODULES.ScriptSynth$). Run `show types` for the full list.

**Commands**

| Command | Arguments | Description |
| --- | --- | --- |
| `add` | `<type> [as "<name>"] [to <parent>[.<chain>]]` | Add a module. `<type>` is a module type ID (see `show types`). `<name>` is optional; the default is the type ID with auto-suffixed numbers. `<parent>` defaults to the current `cd` context or root. `<chain>` auto-resolves unless ambiguous. |
| `remove` | `<target>` | Remove a module and all its children. Target is the instance name. |
| `clone` | `<target> [x<count>]` | Duplicate with children and parameters. `x<count>` repeats; default is 1. |
| `rename` | `<target> to "<newname>"` | Rename an instance. Quoted name required. |
| `move` | `<target> to <parent>[.<chain>]` | Reparent. Chain optional. |
| `set` | `<target>.<param> [to] <value>` | Set a parameter. `to` is optional. `<value>` is a number, quoted string, or bare identifier. |
| `get` | `<target>.<param>` | Local read from the cached tree: no HISE round-trip. Used by `/expect`. |
| `bypass` | `<target>` | Disable processing for a module. |
| `enable` | `<target>` | Re-enable a bypassed module. |
| `load` | `"<source>" into <target>` | Load a preset, sample map, or data file. Source is a quoted path or resource id. |
| `show` | `tree` | Print the full module tree with types, IDs, and chains. |
| `show` | `types [<filter>]` | List available module types; optional prefix filter (for example `show types Envelope`). |
| `show` | `<target>` | Show all parameters of a module with current values and ranges. |
| `reset` | - | Wipe the tree and clear undo history. Irreversible. |
| `cd` | `<path>` | Set current parent; `cd ..` goes up; `cd /` jumps to root. |
| `ls` | - | List modules at the current context. |
| `pwd` | - | Print the current context path. |

**See also:** $MODULES.Audio Modules$ -- full audio module reference, [Undo plans](#undo) -- batch several builder mutations into one undo step

### UI

Component editor. Creates and configures interface components.

**Data model.** Components form a tree of containers and leaves. Container types ([ScriptPanel]($API.ScriptPanel$), [ScriptDynamicContainer]($API.ScriptDynamicContainer$), [ScriptedViewport]($API.ScriptedViewport$), [ScriptFloatingTile]($API.ScriptFloatingTile$)) hold children; all other types are leaves. Components bound to module parameters via `processorId` + `parameterId` need no script glue: the binding is declarative.

**Entry**

```hsc
/ui
/ui.MainPanel           # enter with default parent = MainPanel
/ui add ScriptButton    # one-shot
```

**Example**

```hsc
/ui
add ScriptPanel as Header at 0 0 600 60
cd Header
add ScriptButton as PlayBtn at 10 10 80 32
set PlayBtn.text "Play"
cd /

add ScriptSlider as VolKnob at 10 80 128 48
set VolKnob.processorId "Lead"
set VolKnob.parameterId "Gain"
/exit
```

**Component types**

| Type | Purpose |
| --- | --- |
| [ScriptButton]($API.ScriptButton$) | Toggle or momentary button |
| [ScriptSlider]($API.ScriptSlider$) | Numeric slider/knob |
| [ScriptPanel]($API.ScriptPanel$) | Scriptable panel with custom paint |
| [ScriptComboBox]($API.ScriptComboBox$) | Drop-down list |
| [ScriptLabel]($API.ScriptLabel$) | Text display or input |
| [ScriptImage]($API.ScriptImage$) | Static image |
| [ScriptTable]($API.ScriptTable$) | Curve editor |
| [ScriptSliderPack]($API.ScriptSliderPack$) | Multi-slider array |
| [ScriptAudioWaveform]($API.ScriptAudioWaveform$) | Audio waveform display |
| [ScriptFloatingTile]($API.ScriptFloatingTile$) | Host for pre-built HISE tiles |
| [ScriptDynamicContainer]($API.ScriptDynamicContainer$) | Data-driven child container |
| [ScriptedViewport]($API.ScriptedViewport$) | Scrollable viewport or data table |
| [ScriptMultipageDialog]($API.ScriptMultipageDialog$) | Multi-page wizard/dialog |
| [ScriptWebView]($API.ScriptWebView$) | Embedded web browser |

**Commands**

| Command | Arguments | Description |
| --- | --- | --- |
| `add` | `<type> [as <id>] ["<name>"] [at <x> <y> <w> <h>]` | Add a component. `<type>` is a component type name. `<id>` is the programmatic id; `"<name>"` is the display name. `at` sets position and size in pixels; omitted values use the component's defaults. |
| `remove` | `<target>` | Remove a component (and children if it is a container). |
| `rename` | `<target> to "<newname>"` | Rename. |
| `move` | `<target> to <parent> [at <N>]` | Reparent. `<N>` is the z-order index within the new parent; optional. |
| `set` | `<target>.<prop> [to] <value>` | Set a property. `to` optional. Supports set-target inheritance in comma chains (`set K.x 100, y 200`). |
| `show` | `<target>` | Show all properties with current values. |
| `show` | `tree` | Print the component hierarchy. Invisible components are dimmed; saveInPreset marked with `*`. |
| `cd` | `<path>` / `..` / `/` | Navigate the component tree. |
| `ls` | - | List components at the current context. |
| `pwd` | - | Print the current context path. |

**See also:** $UI.UI Components$ -- full UI component reference including LAF and CSS styling

### Script

HiseScript REPL and callback collector. Any line that is not a slash command is evaluated as a HiseScript expression against the active processor; `/callback` and `/compile` install script callbacks.

**Data model.** The REPL targets one **processor** at a time; the default is `Interface`. Expressions run in the processor's global scope: `const var` references from the installed `onInit` persist and are reachable from later lines. Switching processors (`/script.<id>` or leaving and re-entering) clears pending callback buffers.

**Entry**

```hsc
/script
/script.Interface               # explicit processor
/script Engine.getSampleRate()  # one-shot expression
```

**Example**

```hsc
/script.Interface
Engine.getSampleRate()

/callback onInit
Content.makeFrontInterface(600, 200);
const var knob = Content.getComponent("VolKnob");

/callback onNoteOn
Console.print("note: " + Message.getNoteNumber());

/compile
/expect knob.getValue() is 0.5 within 0.01 or abort
/exit
```

Expressions and callbacks have access to the full HISE scripting API: [Engine]($API.Engine$), [Synth]($API.Synth$), [Content]($API.Content$), [Message]($API.Message$), [Console]($API.Console$), and the rest. Method tokens work too, for example [Engine.getSampleRate]($API.Engine.getSampleRate$) or [Content.makeFrontInterface]($API.Content.makeFrontInterface$).

For expression syntax, data types, realtime-safety rules, and callback conventions, see [hisescript]($LANG.hisescript$).

**Commands**

| Command | Arguments | Description |
| --- | --- | --- |
| `<expression>` | - | Any HiseScript expression. Result, type, and console output are returned. Not a keyword: type the expression as-is. |
| `/callback` | `<name>` | Start collecting the body of a named callback on the current processor. Common names: `onInit`, `onNoteOn`, `onNoteOff`, `onController`, `onTimer`, `onControl`. |
| `/callback` | `<processor>.<callback>` | Fully qualified form. Must match the current processor: switch first with `/script.<id>` if targeting a different one. |
| `/compile` | - | Compile all buffered callbacks. Each non-`onInit` callback is wrapped in `function <name>() { ... }`; `onInit` is sent as-is. If no callbacks are collected, runs a plain recompile of the existing script. |

**See also:** $API.Scripting API$ -- complete scripting API reference, $LANG.hisescript$ -- expression language and realtime-safety rules

### DSP

Scriptnode graph editor. Creates, connects, and configures nodes inside a `DspNetwork`.

**Data model.** Each **host** (a script processor of type [ScriptFX]($MODULES.ScriptFX$) or [ScriptSynth]($MODULES.ScriptSynth$)) can carry one `DspNetwork`. A network is a tree of containers ([container.chain]($SN.container.chain$), `container.frame`, [container.split]($SN.container.split$), and so on) with leaf nodes ([core.oscillator]($SN.core.oscillator$), [filters.svf]($SN.filters.svf$), [control.pma]($SN.control.pma$), and others). Modulation connections wire a source output to a target parameter. Dynamic parameters on a container expose a named knob to its host processor.

**Entry**

```hsc
/dsp
/dsp.<moduleId>          # pre-select host (e.g. /dsp."Script FX1")
/dsp use "Script FX1"    # one-shot host switch
```

**Example**

```hsc
/dsp."Script FX1"
init MyDSP
add core.oscillator as Osc1
set Osc1.Frequency 440
add filters.svf as F1
add control.pma as LFO1
connect LFO1 to F1.Frequency
save
/exit
```

**Commands**

| Command | Arguments | Description |
| --- | --- | --- |
| `show` | `networks` | List `.xml` files in the project's `DspNetworks/` folder. |
| `show` | `modules` | List script processors capable of hosting a `DspNetwork`. |
| `use` | `<moduleId>` | Switch the host processor. Module id may be quoted if it contains spaces. |
| `init` | `<name> [embedded]` | Load an existing network, or create a new one on the current host. `embedded` stores it inline rather than as a separate file. |
| `save` | - | Persist the loaded network to its `.xml`. |
| `reset` | - | Empty the network (no nodes, no connections). |
| `add` | `<factory.node> [as <id>] [to <parent>]` | Add a node. Factory path is `factory.type` (for example `core.oscillator`, `filters.svf`). `<parent>` defaults to the current `cd` container. |
| `remove` | `<nodeId>` | Remove a node. |
| `move` | `<nodeId> to <parent> [at <index>]` | Reparent. Optional index places the node at a specific position in the container. |
| `connect` | `<src>[.<output>] to <target>.<param>` | Create a modulation connection. `<output>` defaults to the source's first modulation output. |
| `disconnect` | `<src> from <target>.<param>` | Remove a connection. |
| `set` | `<node>.<param> [to] <value>` | Set a parameter value. Range is validated locally before sending. |
| `bypass` | `<nodeId>` | Disable a node. |
| `enable` | `<nodeId>` | Re-enable a bypassed node. |
| `create_parameter` | `<container>.<name> [<min> <max>] [default <d>] [step <s>]` | Create a dynamic parameter on a container node. Ranges default to `0..1`. |
| `get` | `<nodeId>` | Local read: returns the factory path. No round-trip. |
| `get` | `<node>.<param>` | Local read: current parameter value. |
| `get` | `source of <node>.<param>` | Local read: connected source id, or `(not connected)`. |
| `get` | `parent of <nodeId>` | Local read: parent container id. |
| `cd` | `<container>` / `..` / `/` | Navigate the graph. |
| `ls` | - | List children at the current path. |
| `pwd` | - | Print the current path. |

**See also:** $SN.Scriptnode Reference$ -- full scriptnode node reference

### Sampler

Sample map editor. *(Placeholder: not implemented.)*

### Inspect

Read-only runtime monitor. No tree: canned queries against the live HISE status payload.

**Entry**

```hsc
/inspect
/inspect version         # one-shot
```

**Example**

```hsc
/inspect
version
project
/exit
```

**Commands**

| Command | Arguments | Description |
| --- | --- | --- |
| `version` | - | HISE server version and compile timeout. |
| `project` | - | Project name, paths, and list of script processors. |
| `help` | - | Show available commands. |

### Undo

Undo history and plan groups.

**Data model.** HISE tracks every mutation (add, remove, set, clone, rename, bypass) as an undo entry. A **plan group** batches several entries into a single undoable unit: start with `plan "<name>"`, issue mutations, commit with `apply` or revert with `discard`. Plan groups are mutually exclusive: close the current one before starting another.

**Entry**

```hsc
/undo
/undo back               # one-shot
```

**Example**

```hsc
/undo plan "Add synth layer"

/builder
add SineSynth as Lead
add SimpleGain to Lead
/exit

/undo diff               # preview
/undo apply              # commit everything as one undo step
```

**Commands**

| Command | Arguments | Description |
| --- | --- | --- |
| `back` | - | Undo the last operation. |
| `forward` | - | Redo the last undone operation. |
| `clear` | - | Clear the entire undo history. |
| `plan` | `"<name>"` | Start a named plan group. Quoted name required. Fails if a plan group is already open. |
| `apply` | - | Commit the current plan group as one undo step. |
| `discard` | - | Revert all changes in the current plan group. |
| `diff` | - | Show what the current plan group changed. |
| `history` | - | Print the full undo history. |
| `help` | - | Show available commands. |

### HISE

Runtime control: launching, shutting down, screenshotting, and profiling HISE.

**Data model.** Controls the HISE process itself. `status` probes the REST API on `localhost:1900`; `launch` spawns HISE (or HISE Debug) and waits up to 10 s for the server; `shutdown` sends a graceful quit. Screenshots and profiles hit the running instance and return results inline.

**Entry**

```hsc
/hise
/hise launch             # one-shot
```

**Example**

```hsc
/hise launch
/hise screenshot of MainPanel at 50% to images/ui.png
/hise profile thread audio for 2000ms
/hise shutdown
```

**Commands**

| Command | Arguments | Description |
| --- | --- | --- |
| `status` | - | Connection status, project info. Returns error if HISE is not responding. |
| `launch` | `[debug]` | Find HISE (or HISE Debug) on `PATH`, spawn it, poll until the REST API responds. 10 s timeout. |
| `shutdown` | - | Send a graceful quit signal. |
| `screenshot` | `[of <id>] [at <scale>] [to <path>]` | Capture the UI. `of <id>` targets a component; omit for the full interface. `<scale>` accepts `50%` or `0.5`. `<path>` defaults to `screenshot.png` in the project folder. |
| `profile` | `[thread <name>] [for <N>ms]` | Record a performance profile. `<name>` is `audio`, `ui`, or `scripting`; default is all threads. Duration defaults to `1000ms`; range `100-5000ms`. |
| `help` | - | Show available commands. |

### Sequence

Timed MIDI sequencer. Two phases: **define** (events scheduled on a timeline) and **run** (play, record, measure).

**Data model.** A sequence is a named list of events, each with a timestamp. Events play MIDI notes, test signals, CC messages, pitchbend, attribute changes, and arbitrary HiseScript evaluations. `eval` events stash their result under a label for later retrieval with `get <id>`. Use this for sample-accurate assertions during playback.

**Entry**

```hsc
/sequence
/sequence create "demo"   # one-shot creates + opens define phase
```

**Example**

```hsc
/sequence
create "hello"
0ms   play C3 100 for 500ms
250ms eval Synth.getNumPressedKeys() as DURING
600ms eval Engine.getNumVoices() as AFTER
flush
play "hello"
/expect get DURING is 1
/expect get AFTER  is 0
/exit
```

**Units**

| Type | Values |
| --- | --- |
| Duration | `500ms`, `1.2s`, `2s` |
| Frequency | `440Hz`, `1kHz`, `20kHz` |
| Note | `C3` (= 60), `C#4`, `Db3`, or raw MIDI `0-127` |
| Velocity | `0-127` (auto-normalised) or `0.0-1.0` |
| Signal | `sine`, `saw`, `sweep`, `dirac`, `noise`, `silence` |

**Commands - define phase**

| Command | Arguments | Description |
| --- | --- | --- |
| `create` | `"<name>"` | Start defining a named sequence. Opens the define phase. |
| `<time> play` | `<note> [<vel>] [for <dur>]` | Schedule a MIDI note. Velocity defaults to `1.0`; duration defaults to `500ms`. |
| `<time> play` | `<signal> [at <freq>] [for <dur>]` | Schedule a test signal (`sine`, `saw`, `dirac`, `noise`, `silence`). |
| `<time> play` | `sweep from <start> to <end> for <dur>` | Schedule a frequency sweep. |
| `<time> send` | `CC <ctrl> <val>` | Schedule a MIDI CC (`<ctrl>` 0-127, `<val>` 0-127). |
| `<time> send` | `pitchbend <val>` | Schedule pitchbend. `<val>` is `-1.0...1.0` or raw `0-16383`. |
| `<time> set` | `<Proc.Param> <val>` | Schedule a parameter change. Use `set Interface.<Component> <v>` to trigger a UI control callback. |
| `<time> eval` | `<expr> as <id>` | Schedule a HiseScript evaluation. Result is stored under `<id>` for `get <id>` after playback. |
| `flush` | - | Close the define phase and return to command phase. |

**Commands - run phase**

| Command | Arguments | Description |
| --- | --- | --- |
| `show` | `"<name>"` | Print sequence details (events, total duration). |
| `play` | `"<name>"` | Execute a sequence (blocks for its duration). |
| `record` | `"<name>" as <path>` | Execute and record audio output to a WAV file. |
| `stop` | - | Send all-notes-off (MIDI reset). |
| `get` | `<id>` | Retrieve the value of an `eval` event from the last playback. |
| `help` | - | Show available commands. |

### Analyse

Audio analysis mode: renders waveforms and spectrograms of `.wav` files inline in the terminal.

**Data model.** Operates on `.wav` files relative to the current directory. `cd` navigates folders; `use` sets session defaults for rendering; `wave` and `spec` render a single file.

**Entry**

```hsc
/analyse
/analyse wave kick.wav   # one-shot
```

**Example**

```hsc
/analyse
use resolution 80x6, mode llm, gamma 2.0
wave kick.wav
spec pad.wav with range 40db
cd samples/
ls
/exit
```

**Settings** (comma-separated `key value` pairs, after `with` or `use`)

| Key | Values | Default |
| --- | --- | --- |
| `resolution` | `<W>x<H>` | `60x6` |
| `mode` | `human` \| `llm` | `human` |
| `gamma` | positive float | `1.8` |
| `range` | `<N>` or `<N>db` | `60` |

**Commands**

| Command | Arguments | Description |
| --- | --- | --- |
| `wave` | `<file> [to <output>] [with <settings>]` | Render a waveform. `<output>` writes to a text file; omit for terminal display. |
| `spec` | `<file> [to <output>] [with <settings>]` | Render a spectrogram. Settings override session defaults. |
| `use` | `[<setting> <value> ...]` | Set session defaults for subsequent renders. Same settings as `with`. |
| `cd` | `[<path>]` | Change folder. No argument prints the current folder. |
| `ls` | - | List files in the current folder. |
| `help` | - | Show available commands. |

### Project

Project settings and configuration. *(Placeholder: not implemented.)*

### Export

Build targets and export settings. *(Placeholder: not implemented.)* Also accessible as `/compile` alias.


## Script Runner

The runner consumes `.hsc` files through the same dispatcher the TUI uses. Every slash command and mode command that works interactively works in a script.

### `/run` and `/parse`

`/run <file>` executes. `/parse <file>` validates only: no side effects, no HISE connection required. Run `/parse` first in CI to catch syntax errors before mutating state.

`/run` accepts a glob (`*` or `?`) and executes every matching file in turn:

```hsc
/run tests/*.hsc
```

A script may call other scripts via `/run`. A recursion guard aborts re-entry (`Recursive script call detected: A -> B -> A`).

### Shebang (Unix)

Make `.hsc` files directly executable:

```hsc
#!/usr/bin/env hise-cli run
/hise status
/builder
add SineSynth
/exit
```

Then `chmod +x test.hsc && ./test.hsc`.

### `/expect`

```
/expect <command> is <value> [within <tolerance>] [or abort]
/expect <command> matches <file> [or abort]
```

The runner executes `<command>` in the current mode, harvests its result, and compares it to the expected value.

| Part | Description |
| --- | --- |
| `<command>` | Any command valid in the current mode. |
| `is <value>` | Literal expected value (number, string, boolean). |
| `within <tol>` | Numeric tolerance; default `0.01`. |
| `matches <file>` | Compare output against a reference text file (trailing newline trimmed). |
| `or abort` | Abort the script on failure. Default is to continue and collect. |

Comparison tiers (first match wins):

1. Truthy/falsy coercion: `true` / `1` / `"true"` / `"1"` equal; `false` / `0` equal.
2. Numeric with tolerance: `0.25` matches `"25%"`; honours `within`.
3. Case-insensitive string equality: no substring matching.

> [!Warning:Use get, not show, for scalar assertions] `/expect` compares against the command's text output. Multi-line dumps (`show <target>`, `show tree`) will never match a single value. Use `get <target>.<param>` for scalar assertions.

| Command | Returns | Good for `/expect`? |
| --- | --- | --- |
| `get <target>.<param>` | Single parameter value | Yes |
| `show <target>` | All parameters, multi-line | No |
| `show tree` | Full tree dump | No |

> [!Warning:Always set a tolerance on float /expect] Floating-point values never compare exactly across serialisation round-trips. Add `within <tol>` for every numeric assertion:

```hsc
/expect Engine.getSampleRate() is 44100 within 1
/expect Content.getComponent("Knob").getValue() is 0.5 within 0.01
```

> [!Tip:Use "or abort" when later commands depend on the check] `or abort` stops the script on failure instead of collecting and continuing. Use it whenever subsequent commands assume the assertion held.

```hsc
/expect Engine.getSampleRate() is 44100 within 1 or abort
# following commands assume 44.1 kHz
```

### `/wait`

`/wait <N>ms` or `/wait <N>s`. Fractional seconds allowed (`0.5s`). Pauses the runner, **not the audio engine**.

> [!Warning:Do not time audio state with /wait] Script-side `/wait` is wall-clock and varies with system load and buffer size. For voice counts, meter levels, CPU usage, or anything tied to audio-timeline position, embed `eval` events inside a `/sequence` and retrieve the result with `get`. See [Sequence Patterns](#timing-sensitive-assertions-sequence-eval).


## Callback Compilation

To install HiseScript callbacks, use the `/callback` collector.

> [!Warning:Use /callback, not /script eval, for callback setup] `/script` evaluates one expression at a time and cannot register `onInit`, `onNoteOn`, and the other callback hooks. Use `/callback <name>` to buffer a callback body and `/compile` to install them.

```hsc
/script
/callback onInit
Content.makeFrontInterface(600, 500);

const var knob = Content.addKnob("Volume", 10, 10);

inline function onKnobControl(component, value)
{
    Synth.getEffect("SimpleGain").setAttribute(0, value);
}

knob.setControlCallback(onKnobControl);

/callback onNoteOn
Console.print("Note: " + Message.getNoteNumber());

/compile
/exit
```

`/callback <name>` starts collecting raw body lines for the named callback of the active processor. `/compile` wraps each non-`onInit` callback in a `function <name>() { ... }` shell, sends all buffered callbacks in one `set_script` call, and triggers recompilation.

| Rule | Detail |
| --- | --- |
| Prefer per-component control callbacks | `setControlCallback()` in `onInit` over the legacy global `onControl` |
| Do not call `changed()` during `onInit` | Silently skipped. Use `setValue()` and `showControl()` directly |
| `set Interface.X v` triggers callbacks | Use it in sequences to simulate UI interactions, including radio-group logic |
| Switching modes resets buffers | Entering or leaving `/script` clears pending callback bodies |
| No callbacks collected | `/compile` falls through to a plain recompile of the existing script |


## Wizards

Wizards are guided multi-step workflows (YAML-defined).

| Form | Behaviour |
| --- | --- |
| `/wizard` \| `/wizard list` | List wizards |
| `/wizard <id>` | Open the form (TUI) or return a wizard handle |
| `/wizard <id> --schema` | Emit field schema as JSON |
| `/wizard <id> --run` | Execute non-interactively using defaults |
| `/wizard <id> --run key:value key:value` | Override fields inline |
| `/resume` | Continue the most recently paused wizard from the failed task |

**Shipped wizards**

| ID | Purpose |
| --- | --- |
| `setup` | Install and build HISE from source (also aliased as `/setup`) |
| `new_project` | Create a new HISE project folder |
| `plugin_export` | Compile the project to VST / AU / AAX / standalone |
| `audio_export` | Render audio output to a WAV file |
| `compile_networks` | Compile scriptnode networks into a DLL |
| `recompile` | Recompile scripts and clear caches |
| `install_package_maker` | Create an installer payload |

Use `--schema` first to discover field IDs, then pass them as `key:value` tokens to `--run`.


## Workflow Patterns

### Check the HISE connection first

`/run` and most mode commands require a live HISE instance on `localhost:1900`. Start scripts with a probe, launching if needed:

```hsc
/hise status
```

For headless or CI runs, bracket with `launch` and `shutdown`:

```hsc
/hise launch
# ... work ...
/hise shutdown
```

### Plan groups for atomic undo

Every mutation is a separate undo entry. Wrap two or more related mutations in a plan group so a single `back` reverts the whole batch, and so you can `discard` if the result looks wrong:

```hsc
/undo plan "Add synth layer"

/builder
add SineSynth as Lead
add SimpleGain to Lead
add AHDSR to Lead.gain
set Lead.Gain 0.5
show tree                       # inspect before committing
/exit

/undo apply                     # or: /undo discard
```

Skip plan groups for trivial single-op mutations and read-only commands.

### Hermetic test scripts

> [!Tip:Start test scripts with reset] Scripts that run repeatedly should clear state at the top. Without `reset`, repeated runs accumulate duplicates (`Lead`, `Lead2`, `Lead3`).

```hsc
/builder reset
# ... build fresh tree ...
```

### UI layout, then script logic

Set layout and static properties in `/ui` so they stay editable in the HISE interface designer. Keep `/script` for runtime behaviour:

```hsc
/ui
add ScriptSlider "VolumeKnob" at 10 10 128 48
add ScriptButton "BypassBtn" at 150 10 80 32
set BypassBtn.radioGroup 1
/exit

/script
/callback onInit
Content.makeFrontInterface(600, 500);

const var knob = Content.getComponent("VolumeKnob");
const var fx = Synth.getEffect("SimpleGain");

inline function onVolumeChange(component, value)
{
    fx.setAttribute(0, value);
}

knob.setControlCallback(onVolumeChange);
/compile
/expect Content.getComponent("VolumeKnob").getValue() is 0.5 within 0.01 or abort
/exit
```

### Declarative UI-to-module binding

> [!Tip:Skip the control callback for direct bindings] When a knob should directly drive a module parameter with no custom logic, set `processorId` + `parameterId` in `/ui` and no script glue is needed.

```hsc
/ui
add ScriptSlider as VolKnob at 10 10 128 48
set VolKnob.processorId "Lead"
set VolKnob.parameterId "Gain"
/exit
```

### Timing-sensitive assertions: sequence eval

For state that depends on audio timing (voice count, meter levels, CPU usage), embed `eval` events at the exact timestamp you need, then retrieve the stashed result after playback:

```hsc
/sequence
create "voice_test"
0ms   play C3 127 for 500ms
250ms eval Synth.getNumPressedKeys() as DURING
600ms eval Engine.getNumVoices() as AFTER
flush
play "voice_test"

/expect get DURING is 1
/expect get AFTER  is 0
/exit
```

This is sample-accurate: the eval runs at the specified timeline position, not when the runner gets around to it.

### Simulating UI interactions

`set Interface.<ComponentName> <value>` inside a sequence triggers the component's control callback, exactly as a click or drag would:

```hsc
/sequence
create "ui_test"
0ms  set Interface.Page2Btn 1
50ms eval page2.get("visible") as PAGE2_VIS
flush
play "ui_test"
/expect get PAGE2_VIS is true
/exit
```

### Recording output

```hsc
/sequence
create "bounce"
0ms play C3 100 for 2s
flush
record "bounce" as output.wav
/exit
```

### Screenshot before and after

```hsc
/hise screenshot to before.png
# ... mutations ...
/hise screenshot to after.png
/hise screenshot of VolumeKnob at 200% to knob_detail.png
```


## Common Mistakes

| Mistake | Correct approach |
| --- | --- |
| Calling `Synth.addNoteOn()` from `/script` | Use `/sequence`. It handles note-off automatically. |
| Many mutations with no plan group | Wrap in `/undo plan` + `apply` for clean undo |
| Guessing parameter names | `show <module>` first. Parameter IDs often surprise (`SineSynth.Gain`, not `Volume`) |
| Setting values without checking ranges | `50` on a `0-1` parameter is +34 dB: clip risk |
| Using `show` in `/expect` | `show` returns multi-line text; use `get <target>.<param>` |
| `/expect get <id>` at the root prompt | `get <id>` is a sequence verb: call it from inside `/sequence` |
| Exact float comparison in `/expect` | Always add `within <tol>` |
| Sending full scripts through `/script` eval | Use `/callback` + `/compile` for callback setup |
| Legacy global `onControl` callback | Call `setControlCallback()` per component in `onInit` |
| `/wait` + `/expect` for audio-timed state | Embed `eval` events in a sequence, retrieve with `get` |
| Setting component properties from `/script` | Use `/ui set`: properties stay editable in the interface designer |
| Calling `changed()` during `onInit` | Silently skipped. Use `setValue()` / `showControl()` directly |
| `setValue()` + `changed()` in sequence eval | Use `set Interface.<Component> <value>`: triggers callbacks and radio groups |
| Running commands without checking HISE | `/hise status` first; `/hise launch` if not reachable |
| No verification after mutations | Add `/expect` or inspect with `show tree` / `show <target>` |
| Adding a ScriptProcessor before scripting | Not needed: the default `Interface` processor is always present |


## Editor Reference

### Key Bindings

| Key | Action |
| --- | --- |
| `Tab` | Complete command or argument at cursor; in sidebar, switch focus |
| `Ctrl+Enter` | Execute the buffer |
| `Return` (sidebar focused) | Set the selected tree node as the current parent |
| `Escape` | Close completion popup; cancel the editor; return focus to input |
| `Ctrl+B` | Toggle the tree sidebar |
| `Up` / `Down` | Command history |
| `PgUp` / `PgDn` | Scroll the output pane |
| `Shift+Up` / `Shift+Down` | Scroll one line |

### Token Highlighting

The editor colourises input by token category. Each mode uses its own accent colour for its keywords.

| Token | Example |
| --- | --- |
| Slash command | `/builder`, `/run` |
| Mode keyword | `add`, `set`, `connect`, `create`, `play` |
| Identifier | Module and node IDs |
| String | `"My Module"` |
| Number | `440`, `0.5`, `500ms` |
| Comment | `# ...`, `// ...` |
| Operator / punctuation | `.`, `,`, `(`, `)` |


## Differences From Shell Languages

| Feature | Shell (bash) | HSC |
| --- | --- | --- |
| Pipes | `cmd1 \| cmd2` | not supported |
| Redirection | `> file`, `< file` | only `to <path>` on specific commands |
| Variables | `$VAR`, `${VAR}` | not supported |
| Command substitution | `` `cmd` ``, `$(cmd)` | not supported |
| Conditionals / loops | `if`, `for`, `while` | not supported; use `/expect ... or abort` |
| Line continuation | trailing `\` | not supported |
| Heredocs | `<<EOF ... EOF` | not supported |
| Comments | `#` only | `#` and `//` |
| String quoting | `'literal'` vs `"expand"` | single and double quotes are equivalent |
| Command discovery | `$PATH` | fixed registry (`/help`, `/modes`) |
| Mode scoping | one global namespace | verbs are scoped to the active mode |
