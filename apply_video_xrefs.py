#!/usr/bin/env python3
"""One-shot script that applies bidirectional video cross-references.

Plan is embedded as PLAN dict. Each entry maps a video slug to its central
target tokens (1-3 each) plus outbound and inbound descriptions.

Outbound: appends `**See also:**` line to each video page.
Inbound: per-domain handler. API uses class_survey_data.json; MODULES/UI/LANG
edit prose `**See also:**` lines directly.

Idempotent: re-running detects already-applied entries by token presence.
"""
import json
import re
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parent
SURVEY_PATH = ROOT / "enrichment" / "resources" / "survey" / "class_survey_data.json"
VIDEOS_DIR = ROOT / "video_enrichment" / "pages"
MODULES_DIR = ROOT / "module_enrichment" / "pages"
UI_DIR = ROOT / "ui_enrichment" / "pages"
LANG_DIR = ROOT / "language_enrichment" / "output"


# ---------------------------------------------------------------------------
# PLAN
# ---------------------------------------------------------------------------
# Each entry: slug -> {category, targets: [{token, outbound_desc, inbound_desc}]}
# Empty targets list = skipped (no clear central subject).

PLAN = {
    # ---------------- guide ----------------
    "exporting-extracting-monoliths-hr-archive": {
        "category": "guide", "targets": [
            {"token": "$MODULES.StreamingSampler$",
             "outbound_desc": "the sampler module whose monolith export this tutorial covers",
             "inbound_desc": "A video tutorial that shows how to recreate sample monoliths and export a standalone with .hr archive samples"},
        ],
    },
    "getting-started-rhapsody": {"category": "guide", "targets": []},
    "how-to-make-a-synth": {
        "category": "guide", "targets": [
            {"token": "$MODULES.WaveSynth$",
             "outbound_desc": "waveform generator used as the synth's sound source",
             "inbound_desc": "A video tutorial that shows how to build a complete synthesizer in HISE without any scripting using waveform generators, AHDSR, LFO and send effects"},
        ],
    },
    "jingle-bell-sample-library": {
        "category": "guide", "targets": [
            {"token": "$API.Sampler$",
             "outbound_desc": "scripting API for the sampler used to build this VST",
             "inbound_desc": "A video tutorial that walks through building a complete sample library VST in HISE from scratch, covering sample mapping, AHDSR/reverb interface and preset browser setup"},
        ],
    },
    "playing-with-knobs": {
        "category": "guide", "targets": [
            {"token": "$UI.Components.ScriptSlider$",
             "outbound_desc": "knob/slider component fundamentals covered by this tutorial",
             "inbound_desc": "A beginner video tutorial that covers Processor ID linking, control callbacks, gain factor conversion and master knob patterns for sliders"},
        ],
    },
    "script-efficiently": {
        "category": "guide", "targets": [
            {"token": "$LANG.hisescript$",
             "outbound_desc": "HiseScript language reference covering the patterns used here",
             "inbound_desc": "A video tutorial that demonstrates efficient HiseScript patterns including shared callbacks, dynamic name concatenation, Array.push() and the continue keyword"},
        ],
    },
    "scripting-101": {
        "category": "guide", "targets": [
            {"token": "$LANG.hisescript$",
             "outbound_desc": "HiseScript language reference covering all fundamentals shown here",
             "inbound_desc": "A comprehensive beginner video tutorial that covers all HiseScript fundamentals: callbacks, variable types, data types, arrays, objects, operators, loops and functions"},
        ],
    },

    # ---------------- audio ----------------
    "articulations-key-switches-buttons": {"category": "audio", "targets": []},
    "auto-trimming-samples": {
        "category": "audio", "targets": [
            {"token": "$MODULES.StreamingSampler$",
             "outbound_desc": "sampler module whose Trim Sample Start tool this tutorial demonstrates",
             "inbound_desc": "A video tutorial that shows the auto-trimming workflow for sample start and end positions, covering raw sample preparation and multi-mic/multi-dynamic mapping"},
        ],
    },
    "change-sample-maps-presets": {
        "category": "audio", "targets": [
            {"token": "$API.Sampler$",
             "outbound_desc": "scripting API used to populate the sample map ComboBox",
             "inbound_desc": "A video tutorial that shows how to tie sample map selection to presets using a ComboBox populated from Sampler.getSampleMapList() with automatic preset save/restore"},
        ],
    },
    "changing-articulations": {
        "category": "audio", "targets": [
            {"token": "$MODULES.StreamingSampler$",
             "outbound_desc": "sampler module whose articulation switching this tutorial covers",
             "inbound_desc": "A video tutorial that explains all approaches for organising and switching between sample articulations: group-based, velocity-based, key range and multi-sampler layouts"},
        ],
    },
    "convolution-reverb-load-irs": {
        "category": "audio", "targets": [
            {"token": "$MODULES.Convolution$",
             "outbound_desc": "the Convolution Reverb module this tutorial loads IRs into",
             "inbound_desc": "A video tutorial that shows how to load impulse response files into a Convolution Reverb effect, populate a ComboBox with IR names and handle selection with preset save/restore"},
        ],
    },
    "global-modulators": {
        "category": "audio", "targets": [
            {"token": "$MODULES.GlobalModulatorContainer$",
             "outbound_desc": "the container module this tutorial demonstrates",
             "inbound_desc": "A video tutorial that shows how to connect a Global Modulator Container to multiple sound generators via Global Modulator slots"},
        ],
    },
    "mic-mixer": {"category": "audio", "targets": []},
    "non-repeating-round-robin": {
        "category": "audio", "targets": [
            {"token": "$API.Sampler$",
             "outbound_desc": "Sampler API used to implement non-repeating round robin",
             "inbound_desc": "A video tutorial that implements non-repeating round robin using modulo arithmetic to exclude the last-played index, guaranteeing no consecutive repeats"},
        ],
    },
    "random-round-robin": {
        "category": "audio", "targets": [
            {"token": "$API.Sampler$",
             "outbound_desc": "Sampler API used for random round-robin selection",
             "inbound_desc": "A video tutorial that implements random round-robin sample group selection using Sampler.enableRoundRobin(false) and Sampler.setActiveGroup() with Math.randInt"},
        ],
    },
    "round-robin-techniques": {
        "category": "audio", "targets": [
            {"token": "$API.Sampler$",
             "outbound_desc": "Sampler API behind all round-robin variants shown",
             "inbound_desc": "A comprehensive video tutorial that covers built-in sequential cycling, scripted sequential with group filtering, random selection and velocity-based round robin"},
        ],
    },
    "sampler-comprehensive-guide": {
        "category": "audio", "targets": [
            {"token": "$API.Sampler$",
             "outbound_desc": "Sampler scripting API used throughout this comprehensive guide",
             "inbound_desc": "A comprehensive video tutorial that covers the HISE Sampler end-to-end: sample map creation, file naming, monolith compression, multi-mic workflows, velocity crossfading, round-robin groups and the scripted sample editor"},
            {"token": "$MODULES.StreamingSampler$",
             "outbound_desc": "the streaming sampler module this guide covers",
             "inbound_desc": "A comprehensive video tutorial that covers the HISE Sampler end-to-end: sample map creation, file naming, monolith compression, multi-mic workflows, velocity crossfading, round-robin groups and the scripted sample editor"},
        ],
    },
    "simple-key-switcher": {"category": "audio", "targets": []},
    "synth-timer-sequencer": {
        "category": "audio", "targets": [
            {"token": "$API.Synth$",
             "outbound_desc": "Synth API used for the realtime audio-thread timer",
             "inbound_desc": "A video tutorial that builds a step sequencer using Synth.startTimer with the onTimer callback, SliderPack-driven velocity and tempo-synced timing"},
        ],
    },
    "velocity-modulation": {
        "category": "audio", "targets": [
            {"token": "$MODULES.Velocity$",
             "outbound_desc": "the Velocity Modulator module this tutorial wires up",
             "inbound_desc": "A video tutorial that shows how to add velocity-to-gain modulation using a Velocity Modulator, shared across multiple sound generators with a Global Modulator Container"},
        ],
    },
    "velocity-spread-mapping": {
        "category": "audio", "targets": [
            {"token": "$MODULES.StreamingSampler$",
             "outbound_desc": "sampler module whose Velocity Spread token parser option this covers",
             "inbound_desc": "A video tutorial that shows how to use the Velocity Spread option in the File Name Token Parser to quickly map multi-dynamic samples across the velocity range"},
        ],
    },

    # ---------------- scripting ----------------
    "arrays-and-loops": {
        "category": "scripting", "targets": [
            {"token": "$LANG.hisescript$",
             "outbound_desc": "HiseScript language reference covering arrays and loops",
             "inbound_desc": "A beginner video tutorial that covers arrays vs variables, for loops with .length, for-in loops, populating arrays with push() and iterating component/module reference arrays"},
        ],
    },
    "batch-generate-sample-maps": {
        "category": "scripting", "targets": [
            {"token": "$API.File$",
             "outbound_desc": "File API used to write generated sample-map XML files",
             "inbound_desc": "A video tutorial that demonstrates batch-generating sample map XML files from a template using HiseScript's File API for string replacement and file writing"},
        ],
    },
    "broadcasters-introduction": {
        "category": "scripting", "targets": [
            {"token": "$API.Broadcaster$",
             "outbound_desc": "the Broadcaster API this video introduces",
             "inbound_desc": "A video tutorial that introduces the broadcaster system as an alternative to direct control callbacks, covering creation, attachment to component values and the broadcaster wizard"},
        ],
    },
    "button-trigger-samples-drum-pad": {"category": "scripting", "targets": []},
    "bypass-button-mono-mode": {"category": "scripting", "targets": []},
    "char-to-int-ascii": {
        "category": "scripting", "targets": [
            {"token": "$API.String$",
             "outbound_desc": "String API used to read character codes",
             "inbound_desc": "A video tutorial that shows how to convert characters to their Unicode/ASCII values using charToInt() and String.charCodeAt()"},
        ],
    },
    "check-variable-defined": {"category": "scripting", "targets": []},
    "clear-array": {
        "category": "scripting", "targets": [
            {"token": "$API.Array$",
             "outbound_desc": "Array API method covered by this tutorial",
             "inbound_desc": "A video tutorial that shows how to use Array.clear() to empty an array declared with const var, since const var arrays cannot be reassigned"},
        ],
    },
    "components-in-bulk": {
        "category": "scripting", "targets": [
            {"token": "$API.Content$",
             "outbound_desc": "Content API used for bulk component lookup",
             "inbound_desc": "A video tutorial that shows how to use Content.getAllComponents() with regex pattern matching to retrieve and modify multiple UI components at once"},
        ],
    },
    "continue-keyword": {
        "category": "scripting", "targets": [
            {"token": "$LANG.hisescript$",
             "outbound_desc": "HiseScript language reference covering loop control keywords",
             "inbound_desc": "A video tutorial that shows how to use the continue keyword to skip loop iterations, with examples for filtering specific values and odd/even checks"},
        ],
    },
    "control-callback-multiple-controls": {
        "category": "scripting", "targets": [
            {"token": "$API.Content$",
             "outbound_desc": "Content API for shared control callbacks across components",
             "inbound_desc": "A video tutorial that shows how to assign a single shared control callback to multiple buttons, identify which control triggered it using indexOf and implement radio button behaviour"},
        ],
    },
    "custom-preset-save-button": {
        "category": "scripting", "targets": [
            {"token": "$API.UserPresetHandler$",
             "outbound_desc": "UserPresetHandler API used by this custom save button",
             "inbound_desc": "A video tutorial that shows how to add a dedicated save button using UserPresetHandler, FileSystem.browse and Engine.saveUserPreset"},
        ],
    },
    "date-api": {
        "category": "scripting", "targets": [
            {"token": "$API.Date$",
             "outbound_desc": "the Date namespace this tutorial covers end-to-end",
             "inbound_desc": "A video tutorial that shows how to use the Date namespace to get system time, convert between ISO-8601 strings and milliseconds and build a days-elapsed check"},
        ],
    },
    "display-preset-name": {"category": "scripting", "targets": []},
    "download-file": {
        "category": "scripting", "targets": [
            {"token": "$API.Server$",
             "outbound_desc": "Server API used for file downloads",
             "inbound_desc": "A complete video tutorial guide on Server.downloadFile covering the download callback, progress monitoring, pause/resume, abort with confirmation and the Server Controller debugging tool"},
        ],
    },
    "extract-zip-file": {
        "category": "scripting", "targets": [
            {"token": "$API.File$",
             "outbound_desc": "File API method covered end-to-end here",
             "inbound_desc": "A complete video tutorial guide on File.extractZipFile() covering the extraction callback object, progress monitoring, cancellation and error handling"},
        ],
    },
    "file-filesystem-api": {
        "category": "scripting", "targets": [
            {"token": "$API.FileSystem$",
             "outbound_desc": "FileSystem API covered end-to-end here",
             "inbound_desc": "A complete video tutorial walkthrough of the HISE FileSystem and File APIs covering getFolder, getChildFile, loadAsString, writeString, browse and createDirectory"},
            {"token": "$API.File$",
             "outbound_desc": "File API covered alongside FileSystem in this walkthrough",
             "inbound_desc": "A complete video tutorial walkthrough of the HISE FileSystem and File APIs covering getFolder, getChildFile, loadAsString, writeString, browse and createDirectory"},
        ],
    },
    "hide-reveal-passwords": {
        "category": "scripting", "targets": [
            {"token": "$API.ScriptLabel$",
             "outbound_desc": "Label component whose fontStyle property is toggled here",
             "inbound_desc": "A video tutorial that shows how to toggle password masking on a Label component using the fontStyle property set to 'Password' or 'plain'"},
        ],
    },
    "increment-decrement": {
        "category": "scripting", "targets": [
            {"token": "$LANG.hisescript$",
             "outbound_desc": "HiseScript language reference covering operator semantics",
             "inbound_desc": "A video tutorial that explains pre/post increment and decrement operators, their performance differences and how to benchmark code with Console.startBenchmark/stopBenchmark"},
        ],
    },
    "indexof-multiple-values": {
        "category": "scripting", "targets": [
            {"token": "$API.Array$",
             "outbound_desc": "Array.indexOf used for multi-value matching",
             "inbound_desc": "A video tutorial that shows how to use Array.indexOf() with an inline array to cleanly check if a value matches any of several discrete values"},
        ],
    },
    "lazy-loading-purge-until-played": {
        "category": "scripting", "targets": [
            {"token": "$API.Sampler$",
             "outbound_desc": "Sampler API used to implement purge-until-played",
             "inbound_desc": "A video tutorial that shows how to implement lazy loading (purge until played) in HISE samplers via scripting, reducing RAM usage by keeping samples purged until first triggered"},
        ],
    },
    "linked-knobs-reverb": {"category": "scripting", "targets": []},
    "linked-slider-packs": {
        "category": "scripting", "targets": [
            {"token": "$API.SliderPackData$",
             "outbound_desc": "shared data object that links multiple SliderPack components",
             "inbound_desc": "A video tutorial that shows how to link multiple SliderPack components to a shared SliderPackData object using Engine.createSliderPackData() and referToData(), including cross-script linking"},
        ],
    },
    "load-previous-next-preset-buttons": {
        "category": "scripting", "targets": [
            {"token": "$API.UserPresetHandler$",
             "outbound_desc": "preset handler API used for previous/next navigation",
             "inbound_desc": "A video tutorial that shows how to create previous/next preset navigation buttons using Engine.loadPreviousUserPreset/loadNextUserPreset, including cross-folder navigation"},
        ],
    },
    "microtuning-script-module": {"category": "scripting", "targets": []},
    "multi-file-downloader": {
        "category": "scripting", "targets": [
            {"token": "$API.Server$",
             "outbound_desc": "Server.downloadFile used in parallel for batch downloads",
             "inbound_desc": "A video tutorial that shows how to download multiple files in parallel using Server.downloadFile() with an array of URLs, pause/abort controls and configurable concurrency"},
        ],
    },
    "namespaces": {
        "category": "scripting", "targets": [
            {"token": "$LANG.hisescript$",
             "outbound_desc": "HiseScript language reference covering namespaces and other language features",
             "inbound_desc": "A video tutorial that shows how to organise HiseScript code with namespaces, including reserved-name pitfalls and one-namespace-per-file file layout"},
        ],
    },
    "objects-curly-braces": {
        "category": "scripting", "targets": [
            {"token": "$LANG.hisescript$",
             "outbound_desc": "HiseScript language reference covering object literals",
             "inbound_desc": "A beginner video tutorial that covers HiseScript objects: creating with curly braces, key-value pairs, dot vs bracket notation, nesting arrays/objects and iterating nested structures"},
        ],
    },
    "odd-even-modulo": {"category": "scripting", "targets": []},
    "one-knob-controlling-multiple-modules": {"category": "scripting", "targets": []},
    "parseint-command": {
        "category": "scripting", "targets": [
            {"token": "$LANG.hisescript$",
             "outbound_desc": "HiseScript language reference covering numeric conversion built-ins",
             "inbound_desc": "A video tutorial that demonstrates the parseInt function for converting string representations of numbers to integers and for truncating floats to whole numbers"},
        ],
    },
    "regex-matches-count-substrings": {
        "category": "scripting", "targets": [
            {"token": "$LANG.regex$",
             "outbound_desc": "regex reference for the pattern syntax used here",
             "inbound_desc": "A video tutorial that shows how to use Engine.getRegexMatches() to find all occurrences of a pattern in a string and count them"},
        ],
    },
    "reserve-array-memory": {
        "category": "scripting", "targets": [
            {"token": "$API.Array$",
             "outbound_desc": "Array.reserve API for pre-allocating memory",
             "inbound_desc": "A video tutorial that shows how to use Array.reserve() to pre-allocate memory for arrays of known size, avoiding incremental resizing during population"},
        ],
    },
    "round-decimal-numbers": {"category": "scripting", "targets": []},
    "scripting-paradigm-factory-scripts": {
        "category": "scripting", "targets": [
            {"token": "$LANG.hisescript$",
             "outbound_desc": "HiseScript language reference framing the modular scripting paradigm",
             "inbound_desc": "A video tutorial that explains HISE's modular scripting architecture (Interface Script plus small MIDI Processor scripts) and demonstrates built-in factory scripts like Legato, Transposer and MIDI Muter"},
        ],
    },
    "show-message-box": {"category": "scripting", "targets": []},
    "snake-game": {
        "category": "scripting", "targets": [
            {"token": "$API.ScriptPanel$",
             "outbound_desc": "ScriptPanel API powering the game's drawing, timer and input",
             "inbound_desc": "A step-by-step video tutorial that builds a Snake game using ScriptPanel timers, key press callbacks, paint routines and grid-based game logic"},
        ],
    },
    "sort-arrays": {
        "category": "scripting", "targets": [
            {"token": "$API.Array$",
             "outbound_desc": "Array sorting methods covered comprehensively here",
             "inbound_desc": "A video tutorial that covers all array sorting methods: sort() for numeric, reverse() for descending, sortNatural() for embedded numbers and Engine.sortWithFunction() for custom comparators"},
        ],
    },
    "timer-objects": {
        "category": "scripting", "targets": [
            {"token": "$API.Timer$",
             "outbound_desc": "Timer object API covered end-to-end here",
             "inbound_desc": "A complete video tutorial guide to Engine.createTimerObject() covering creation, start/stop/reset, real-time speed changes and combining multiple animations into one timer callback"},
        ],
    },
    "transposer-realtime-threads": {
        "category": "scripting", "targets": [
            {"token": "$API.Message$",
             "outbound_desc": "Message API used for real-time MIDI transposition",
             "inbound_desc": "A video tutorial that builds a MIDI transposer using a two-script architecture: a deferred UI script for display and a non-deferred ScriptProcessor for real-time Message.setTransposeAmount calls"},
        ],
    },
    "typeof-command": {
        "category": "scripting", "targets": [
            {"token": "$LANG.hisescript$",
             "outbound_desc": "HiseScript language reference covering runtime type checks",
             "inbound_desc": "A video tutorial that explains how to use the typeof operator and Array.isArray() to check variable types at runtime, including the caveat that typeof returns object for both arrays and plain objects"},
        ],
    },
    "velocity-table-presets": {
        "category": "scripting", "targets": [
            {"token": "$API.Table$",
             "outbound_desc": "Table API used to save/restore table shapes via base64",
             "inbound_desc": "A video tutorial that shows how to save and restore velocity modulator table shapes using base64 strings and radio buttons with restoreFromBase64"},
        ],
    },
    "website-link-button": {"category": "scripting", "targets": []},
    "while-key-held-timer": {
        "category": "scripting", "targets": [
            {"token": "$API.Timer$",
             "outbound_desc": "Timer object API used to repeat actions while a key is held",
             "inbound_desc": "A video tutorial that shows how to repeat an action while a MIDI key is held using Engine.createTimerObject(), since HISE has no blocking wait statement"},
        ],
    },

    # ---------------- ui ----------------
    "auto-colour-keys-sample-mapping": {
        "category": "ui", "targets": [
            {"token": "$UI.FloatingTiles.Keyboard$",
             "outbound_desc": "keyboard component whose key colours are driven by sample mapping",
             "inbound_desc": "A video tutorial that shows how to automatically colour keyboard keys to reflect which notes have samples mapped, updating dynamically via a Panel loading callback"},
        ],
    },
    "button-filmstrips": {
        "category": "ui", "targets": [
            {"token": "$UI.Components.ScriptButton$",
             "outbound_desc": "button component whose filmstrip image setup this covers",
             "inbound_desc": "A video tutorial that shows how to assign a filmstrip image to a HISE button with the correct 6-frame layout, dimensions and HiDPI scale factor"},
        ],
    },
    "checkboxes-look-and-feel": {
        "category": "ui", "targets": [
            {"token": "$API.ScriptLookAndFeel$",
             "outbound_desc": "LAF API used to draw buttons as icon checkboxes",
             "inbound_desc": "A video tutorial that shows how to draw buttons as icon checkboxes using Look and Feel, SVG path data and a shared LAF callback that selects icons via the button's text property"},
        ],
    },
    "custom-keyboard-panel": {
        "category": "ui", "targets": [
            {"token": "$API.ScriptPanel$",
             "outbound_desc": "ScriptPanel API powering this custom on-screen keyboard",
             "inbound_desc": "A video tutorial that builds a fully custom on-screen keyboard from a ScriptPanel with painted keys, mouse interaction, MidiList-based event ID tracking and MIDI input synchronisation"},
        ],
    },
    "custom-mouse-cursor": {
        "category": "ui", "targets": [
            {"token": "$API.ScriptPanel$",
             "outbound_desc": "ScriptPanel API where the custom cursor is set",
             "inbound_desc": "A video tutorial that shows how to set a custom mouse cursor on a ScriptPanel using an SVG path, with colour tinting and hit-point positioning, applied instrument-wide"},
        ],
    },
    "custom-performance-meter": {
        "category": "ui", "targets": [
            {"token": "$API.ScriptPanel$",
             "outbound_desc": "ScriptPanel used as the canvas for the meter",
             "inbound_desc": "A video tutorial that builds a custom Panel-based performance meter displaying live CPU usage, RAM usage and voice count with per-metric colours and timer callbacks"},
        ],
    },
    "custom-tooltips": {
        "category": "ui", "targets": [
            {"token": "$UI.FloatingTiles.TooltipPanel$",
             "outbound_desc": "built-in tooltip floating tile referenced as a baseline",
             "inbound_desc": "A video tutorial that covers tooltips end-to-end, from the built-in TooltipPanel floating tile to fully custom tooltip displays using a ScriptPanel with timer and SVG icons"},
            {"token": "$API.ScriptPanel$",
             "outbound_desc": "ScriptPanel API used for the custom tooltip implementation",
             "inbound_desc": "A video tutorial that builds custom tooltip displays using a ScriptPanel with a timer, background drawing and SVG info icons"},
        ],
    },
    "custom-vector-sliders": {
        "category": "ui", "targets": [
            {"token": "$UI.Components.ScriptSlider$",
             "outbound_desc": "slider component combined with painted panels for custom vector sliders",
             "inbound_desc": "A video tutorial that teaches how to build fully customizable vector sliders by combining invisible slider widgets with painted panels, covering unidirectional and bidirectional implementations"},
        ],
    },
    "drawing-text-on-panel": {
        "category": "ui", "targets": [
            {"token": "$API.Graphics$",
             "outbound_desc": "Graphics API for the three text-drawing methods covered",
             "inbound_desc": "A video tutorial that covers the three Graphics text-drawing methods available in panel paint routines: drawText, drawAlignedText and drawFittedText with multi-line wrapping"},
        ],
    },
    "dynamic-tabbed-interfaces": {
        "category": "ui", "targets": [
            {"token": "$API.ScriptPanel$",
             "outbound_desc": "ScriptPanel API used to group controls and toggle visibility for tabs",
             "inbound_desc": "A video tutorial that shows how to build tabbed and multi-page interfaces by grouping controls into panels and toggling their visibility with buttons, knobs or combo boxes"},
        ],
    },
    "expansion-packs": {
        "category": "architecture", "targets": [
            {"token": "$API.ExpansionHandler$",
             "outbound_desc": "ExpansionHandler API used to enable and load expansions",
             "inbound_desc": "A complete video tutorial guide to HISE expansion packs covering enabling the feature, expansion folders, dynamic sample-map loading with {EXP::} prefixes, expansion-scoped presets and JSON manifest loading"},
            {"token": "$API.Expansion$",
             "outbound_desc": "Expansion API for working with individual expansion packs",
             "inbound_desc": "A complete video tutorial guide to HISE expansion packs covering enabling the feature, expansion folders, dynamic sample-map loading with {EXP::} prefixes, expansion-scoped presets and JSON manifest loading"},
        ],
    },
    "file-drag-drop-panel": {
        "category": "ui", "targets": [
            {"token": "$API.ScriptPanel$",
             "outbound_desc": "ScriptPanel API powering the drag-and-drop panel",
             "inbound_desc": "A video tutorial that builds a custom file drag-and-drop panel using ScriptPanel's paint routine, Path-based dashed borders and the setFileDropCallback API"},
        ],
    },
    "get-local-bounds": {
        "category": "ui", "targets": [
            {"token": "$API.ScriptPanel$",
             "outbound_desc": "ScriptPanel API method getLocalBounds covered here",
             "inbound_desc": "A video tutorial that demonstrates using getLocalBounds() to get a panel's bounds array with automatic margin/inset calculation, replacing manual coordinate math"},
        ],
    },
    "import-vectors": {
        "category": "ui", "targets": [
            {"token": "$API.Path$",
             "outbound_desc": "Path API used to load and draw imported SVG paths",
             "inbound_desc": "A video tutorial that shows how to convert SVG path data using the HISE Producer tool, load it into a Path object and draw or fill it on a Panel with proper centering"},
        ],
    },
    "invisible-controls": {"category": "ui", "targets": []},
    "keyboard-look-and-feel": {
        "category": "ui", "targets": [
            {"token": "$UI.FloatingTiles.Keyboard$",
             "outbound_desc": "keyboard component whose appearance this LAF customizes",
             "inbound_desc": "A video tutorial that builds a custom-styled MIDI keyboard using drawWhiteNote and drawBlackNote LAF functions with triangle shapes, key-press animation and Engine.setKeyColour for key-switch markers"},
            {"token": "$API.ScriptLookAndFeel$",
             "outbound_desc": "LAF API used to register custom keyboard paint functions",
             "inbound_desc": "A video tutorial that builds a custom-styled MIDI keyboard using drawWhiteNote and drawBlackNote LAF callbacks with triangle shapes, key-press animation and hover effects"},
        ],
    },
    "laf-button-images": {
        "category": "ui", "targets": [
            {"token": "$API.ScriptLookAndFeel$",
             "outbound_desc": "LAF API used to draw buttons with sprite images",
             "inbound_desc": "A video tutorial that shows how to use frame-based sprite images with Look and Feel to draw custom button states, using loadImage and drawImage inside drawToggleButton"},
        ],
    },
    "laf-buttons": {
        "category": "ui", "targets": [
            {"token": "$API.ScriptLookAndFeel$",
             "outbound_desc": "LAF API used to register the drawToggleButton callback",
             "inbound_desc": "A video tutorial that shows how to build multiple button styles (icon, text, toggle, MIDI channel list) within a single drawToggleButton LAF function using obj.text prefix matching and obj.parentType"},
            {"token": "$UI.Components.ScriptButton$",
             "outbound_desc": "button component whose appearance this LAF customizes",
             "inbound_desc": "A video tutorial that shows how to build multiple button styles (icon, text, toggle, MIDI channel list) within a single drawToggleButton LAF function"},
        ],
    },
    "laf-knobs-sliders": {
        "category": "ui", "targets": [
            {"token": "$UI.Components.ScriptSlider$",
             "outbound_desc": "slider component reference",
             "inbound_desc": "A video tutorial that shows how to draw custom rotary, horizontal and vertical sliders with drawRotarySlider and drawLinearSlider LAF callbacks"},
            {"token": "$API.ScriptLookAndFeel$",
             "outbound_desc": "LAF scripting API reference",
             "inbound_desc": "A video tutorial that shows how to register drawRotarySlider and drawLinearSlider paint functions for fully custom knob and slider rendering"},
        ],
    },
    "led-style-button-look-and-feel": {
        "category": "ui", "targets": [
            {"token": "$API.ScriptLookAndFeel$",
             "outbound_desc": "LAF API used to draw the LED button entirely in script",
             "inbound_desc": "A step-by-step video tutorial that draws a realistic LED toggle button entirely in HiseScript using a local Look and Feel, covering layered gradient fills, radial gradients, drop shadow glow and interactive hover/press feedback"},
        ],
    },
    "lottie-animations": {
        "category": "ui", "targets": [
            {"token": "$API.ScriptPanel$",
             "outbound_desc": "ScriptPanel API used to display Lottie animation frames",
             "inbound_desc": "A video tutorial that shows how to load Lottie animations into HISE, display them on a Panel and wire a knob to scrub through animation frames"},
        ],
    },
    "paint-images-on-panel": {
        "category": "ui", "targets": [
            {"token": "$API.Graphics$",
             "outbound_desc": "Graphics API method drawImage used in panel paint routines",
             "inbound_desc": "A video tutorial that shows how to load an image into a Panel, draw it in a paint routine using g.drawImage and control positioning with offsets"},
        ],
    },
    "paint-routines-vector-graphics": {
        "category": "ui", "targets": [
            {"token": "$API.Graphics$",
             "outbound_desc": "Graphics API behind all panel drawing covered here",
             "inbound_desc": "A comprehensive video tutorial guide to drawing vector graphics with paint routines, covering shapes, text, fonts, drop shadows, gradients and interactive button menus with mouse callbacks"},
        ],
    },
    "panel-timers-progress-bar": {
        "category": "ui", "targets": [
            {"token": "$API.ScriptPanel$",
             "outbound_desc": "ScriptPanel API for setTimerCallback and storing animation state",
             "inbound_desc": "A video tutorial that builds a progress bar using the panel's built-in timer, demonstrating setTimerCallback, startTimer/stopTimer and looping animations with modulo"},
        ],
    },
    "resizable-interface-zoom": {"category": "ui", "targets": []},
    "set-key-colours": {
        "category": "ui", "targets": [
            {"token": "$UI.FloatingTiles.Keyboard$",
             "outbound_desc": "keyboard whose individual key colours are set via Engine.setKeyColour",
             "inbound_desc": "A video tutorial that shows how to use Engine.setKeyColour() to colour individual keys or ranges on the HISE onscreen keyboard, with Colours namespace constants and alpha transparency"},
        ],
    },
    "set-opacity-paint-routine": {
        "category": "ui", "targets": [
            {"token": "$API.Colours$",
             "outbound_desc": "Colours API method withAlpha covered by this tutorial",
             "inbound_desc": "A video tutorial that shows how to use Colours.withAlpha() to control colour opacity at draw time within a panel paint routine"},
        ],
    },
    "sharing-paint-routines": {
        "category": "ui", "targets": [
            {"token": "$API.Graphics$",
             "outbound_desc": "Graphics API targeted by the shared inline drawing function",
             "inbound_desc": "A video tutorial that shows how to eliminate repetitive paint routine code by extracting shared drawing logic into an inline function and adding panel-specific extras on top"},
        ],
    },
    "striped-panel": {
        "category": "ui", "targets": [
            {"token": "$API.Graphics$",
             "outbound_desc": "Graphics API used for fillRect and rotate stripe patterns",
             "inbound_desc": "A video tutorial that shows how to draw alternating-colour vertical, horizontal or diagonal stripes on a Panel using a paint routine loop with g.fillRect and g.rotate"},
        ],
    },
    "sustain-pedal-indicator": {"category": "ui", "targets": []},
    "transparent-image": {
        "category": "ui", "targets": [
            {"token": "$API.Graphics$",
             "outbound_desc": "Graphics API used for image opacity in paint routines",
             "inbound_desc": "A video tutorial that shows how to control image opacity in a Panel paint routine using g.setColour with Colours.withAlpha before g.drawImage"},
        ],
    },
    "visual-guides-interface-designer": {
        "category": "ui", "targets": [
            {"token": "$API.Content$",
             "outbound_desc": "Content API method addVisualGuide for layout debugging",
             "inbound_desc": "A video tutorial that shows how to use Content.addVisualGuide to draw temporary alignment lines and rectangles in the HISE Interface Designer for layout debugging"},
        ],
    },
    "xy-pad": {
        "category": "ui", "targets": [
            {"token": "$API.ScriptPanel$",
             "outbound_desc": "ScriptPanel API powering the XY pad control",
             "inbound_desc": "A video tutorial that builds an XY pad control from a ScriptPanel with mouse tracking, normalised 0-1 data storage, clamped dot rendering and wiring to LFO modulators via CC Modulator default values"},
        ],
    },
    "xy-pad-with-sliders": {
        "category": "ui", "targets": [
            {"token": "$API.ScriptPanel$",
             "outbound_desc": "ScriptPanel API for the XY pad whose position is bidirectionally linked to sliders",
             "inbound_desc": "A video tutorial that shows how to add two knobs that bidirectionally control the X and Y position of a Panel-based XY pad, keeping mouse and knob input in sync"},
        ],
    },

    # ---------------- scriptnode ----------------
    "compile-scriptnode-networks": {
        "category": "scriptnode", "targets": [
            {"token": "$LANG.cpp-dsp-nodes$",
             "outbound_desc": "C++ DSP nodes reference for compiled ScriptNode networks",
             "inbound_desc": "A video tutorial that shows how to compile ScriptNode networks into a native DLL and load them as Hardcoded Master Effects for lower CPU overhead and simpler UI wiring"},
        ],
    },
}


# ---------------------------------------------------------------------------
# Outbound: append **See also:** to each video page
# ---------------------------------------------------------------------------

def apply_outbound():
    """Insert (or refresh) the **See also:** line directly under the YAML
    frontmatter. Video pages have no source-level H1 — Nuxt auto-inserts
    one — so the first body content sits right after the closing `---`.
    """
    written = 0
    for slug, entry in PLAN.items():
        targets = entry["targets"]
        if not targets:
            continue
        category = entry["category"]
        video_path = VIDEOS_DIR / category / f"{slug}.md"
        if not video_path.is_file():
            print(f"  MISSING video: {video_path}")
            continue

        content = video_path.read_text(encoding="utf-8")
        items = ", ".join(
            f'{t["token"]} -- {t["outbound_desc"]}' for t in targets
        )
        new_line = f"**See also:** {items}"

        # Strip any existing See also line wherever it sits, so re-runs
        # converge on the canonical position.
        content = re.sub(
            r'\n*^\*\*See also:\*\* [^\n]+\n*',
            "\n\n",
            content,
            flags=re.MULTILINE,
        )

        # Find frontmatter end: opening `---\n` then closing `\n---\n`.
        fm_match = re.match(r'^---\n.*?\n---\n', content, re.DOTALL)
        if not fm_match:
            print(f"  NO frontmatter in {video_path}")
            continue
        insert_pos = fm_match.end()
        # Skip leading blank lines after frontmatter so we don't stack them.
        rest = content[insert_pos:]
        skip = re.match(r'\n+', rest)
        skip_len = skip.end() if skip else 0
        new_content = (
            content[:insert_pos]
            + "\n"
            + new_line
            + "\n\n"
            + rest[skip_len:]
        )
        if new_content != content:
            video_path.write_text(new_content, encoding="utf-8")
            written += 1
    return written


# ---------------------------------------------------------------------------
# Inbound: build map of target -> incoming videos, then apply per domain
# ---------------------------------------------------------------------------

TOKEN_RE = re.compile(r'^\$([A-Z]+)\.([^$]+)\$$')


def build_inbound_map():
    """target_key -> [(video_slug, inbound_desc), ...]
    target_key = (domain, target_str)
    """
    inbound = defaultdict(list)
    for slug, entry in PLAN.items():
        for tgt in entry["targets"]:
            m = TOKEN_RE.match(tgt["token"])
            if not m:
                continue
            domain, target_str = m.group(1), m.group(2)
            inbound[(domain, target_str)].append((slug, tgt["inbound_desc"]))
    return inbound


def apply_inbound_module(target, items):
    """target = module ID, e.g. 'GlobalModulatorContainer'."""
    path = MODULES_DIR / f"{target}.md"
    if not path.is_file():
        print(f"  MISSING module page: {path}")
        return 0
    content = path.read_text(encoding="utf-8")
    return _append_to_see_also_line(path, content, items)


def apply_inbound_ui(target, items):
    """target = 'Components.Name' or 'FloatingTiles.Name'."""
    if "." not in target:
        return 0
    sub, name = target.split(".", 1)
    subdir = "components" if sub == "Components" else "floating-tiles"
    path = UI_DIR / subdir / f"{name}.md"
    if not path.is_file():
        print(f"  MISSING UI page: {path}")
        return 0
    content = path.read_text(encoding="utf-8")
    # If the placeholder See also exists, replace it
    placeholder = "**See also:** <!-- populated during cross-reference post-processing -->"
    if placeholder in content:
        new_items = ", ".join(f"$VIDEO.{slug}$ -- {desc}" for slug, desc in items)
        content = content.replace(placeholder, f"**See also:** {new_items}")
        path.write_text(content, encoding="utf-8")
        return 1
    return _append_to_see_also_line(path, content, items)


def apply_inbound_lang(target, items):
    """target = lang slug (e.g. 'hisescript', 'regex')."""
    path = LANG_DIR / f"{target}.md"
    if not path.is_file():
        print(f"  MISSING LANG page: {path}")
        return 0
    content = path.read_text(encoding="utf-8")
    # For LANG, append a fresh See also block at the end of the file.
    # (Existing section-level See alsos in hisescript.md were placed manually.)
    new_items = ", ".join(f"$VIDEO.{slug}$ -- {desc}" for slug, desc in items)
    new_block = f"\n\n**See also:** {new_items}\n"
    # Idempotency: skip if any of these video slugs already linked
    if any(f"$VIDEO.{slug}$" in content for slug, _ in items):
        return 0
    content = content.rstrip() + new_block
    path.write_text(content, encoding="utf-8")
    return 1


def apply_inbound_api(target, items):
    """target = API class name. Adds entries to class_survey_data.json."""
    survey = json.loads(SURVEY_PATH.read_text(encoding="utf-8"))
    cls_data = survey.get("classes", {}).get(target)
    if cls_data is None:
        print(f"  MISSING API class in survey: {target}")
        return 0
    see_also = cls_data.setdefault("seeAlso", [])
    existing_slugs = {e.get("video") for e in see_also if e.get("video")}
    added = 0
    for slug, desc in items:
        if slug in existing_slugs:
            continue
        see_also.append({"video": slug, "distinction": desc})
        added += 1
    if added:
        SURVEY_PATH.write_text(
            json.dumps(survey, indent=2, ensure_ascii=False) + "\n",
            encoding="utf-8",
        )
    return added


def _append_to_see_also_line(path, content, items):
    """For prose pages with a `**See also:** ...` line, append video tokens.

    If multiple See also lines exist, append to the last one (assumed to be
    the page-level summary). If none, create a new line at the end.
    """
    appended = ", ".join(f"$VIDEO.{slug}$ -- {desc}" for slug, desc in items)

    # Idempotency: skip if any of these video slugs already linked
    if any(f"$VIDEO.{slug}$" in content for slug, _ in items):
        return 0

    matches = list(re.finditer(r'^\*\*See also:\*\* .+$', content, re.MULTILINE))
    if matches:
        last = matches[-1]
        merged = last.group(0).rstrip().rstrip(",") + ", " + appended
        content = content[:last.start()] + merged + content[last.end():]
    else:
        content = content.rstrip() + f"\n\n**See also:** {appended}\n"
    path.write_text(content, encoding="utf-8")
    return 1


def apply_inbound():
    inbound = build_inbound_map()
    counts = defaultdict(int)
    for (domain, target), items in inbound.items():
        if domain == "MODULES":
            counts["MODULES"] += apply_inbound_module(target, items)
        elif domain == "UI":
            counts["UI"] += apply_inbound_ui(target, items)
        elif domain == "LANG":
            counts["LANG"] += apply_inbound_lang(target, items)
        elif domain == "API":
            counts["API"] += apply_inbound_api(target, items)
        else:
            print(f"  SKIP inbound for unsupported domain: {domain}.{target}")
    return counts


# ---------------------------------------------------------------------------

def main():
    print("Applying outbound see-also lines to video pages...")
    out_count = apply_outbound()
    print(f"  {out_count} video pages updated\n")

    print("Applying inbound video links to target pages...")
    in_counts = apply_inbound()
    for domain, n in in_counts.items():
        print(f"  {domain}: {n} target pages updated")

    # Stats
    have_targets = sum(1 for v in PLAN.values() if v["targets"])
    skipped = sum(1 for v in PLAN.values() if not v["targets"])
    total_targets = sum(len(v["targets"]) for v in PLAN.values())
    print(f"\nPlan: {len(PLAN)} videos, {have_targets} with targets, "
          f"{skipped} skipped, {total_targets} total target links")


if __name__ == "__main__":
    main()
