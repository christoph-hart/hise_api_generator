---
title: Script Processor
moduleId: ScriptProcessor
type: MidiProcessor
subtype: MidiProcessor
tags: [custom]
builderPath: b.MidiProcessors.ScriptProcessor
screenshot: /images/v2/reference/audio-modules/scriptprocessor.png
cpuProfile:
  baseline: negligible
  polyphonic: false
  scalingFactors:
    - { parameter: "User script complexity", impact: "variable", note: "CPU depends entirely on the callbacks the user writes" }
seeAlso:
  - { id: ScriptVoiceStartModulator, type: companion, reason: "Per-voice modulation via HiseScript callbacks - use when you need scripted note-on logic that returns a modulation value" }
commonMistakes:
  - title: "Blocking the audio thread in callbacks"
    wrong: "Performing heavy operations (file I/O, network requests, large loop iterations) inside onNoteOn or onController"
    right: "Use Synth.deferCallbacks(true) for heavy processing, or move work to onTimer / onControl"
    explanation: "By default, MIDI callbacks run on the audio thread. Expensive operations cause audio dropouts."
  - title: "Expecting onController to fire only for CC messages"
    wrong: "Writing onController logic that assumes Message.getControllerNumber() is always valid"
    right: "Check the event type first - onController also fires for pitch bend, aftertouch, and program change"
    explanation: "The onController callback handles all continuous controller-type events, not just MIDI CC messages."
  - title: "Using onControl for processor-connected components"
    wrong: "Expecting onControl to fire for a knob that has its processorId and parameterId properties set"
    right: "Connected components bypass onControl entirely - remove the connection if you need the callback"
    explanation: "When a UI component is connected to a processor parameter, macro control, or global cable, value changes are routed directly to the target without triggering onControl."
llmRef: |
  Script Processor (MidiProcessor/MidiProcessor)

  The central scripting module in HISE. Processes incoming MIDI events through six HiseScript callbacks and hosts the plugin's user interface when set as the front interface. All parameters are defined dynamically via UI components created in the onInit callback.

  Signal flow:
    MIDI in -> event dispatch -> onNoteOn / onNoteOff / onController / onTimer -> MIDI out
    UI component change -> onControl

  CPU: negligible (framework overhead), variable (depends on user script complexity), monophonic.

  Callbacks:
    onInit - runs once at compile time, declare variables, create UI, set up references
    onNoteOn - fires on note-on, access event via Message object
    onNoteOff - fires on note-off, access event via Message object
    onController - fires on CC, pitch bend, aftertouch, program change
    onTimer - fires at interval set by Synth.startTimer(), sample-accurate in real-time mode
    onControl(number, value) - fires when a UI component value changes

  API objects available:
    Message, Engine, Synth, Sampler, Content, Console, Settings, FileSystem, Threads, Date, Server, Colours

  Threading:
    Default: all MIDI callbacks on audio thread (real-time safe)
    Synth.deferCallbacks(true): MIDI callbacks on message thread (not sample-accurate)
    onControl: runs on scripting thread when triggered from UI
    onInit: always runs on scripting thread

  When to use:
    Every HISE project needs at least one ScriptProcessor. Use it for MIDI processing, UI creation, and plugin control logic. Set as front interface for the main plugin UI.

  Common mistakes:
    Blocking audio thread with heavy operations in MIDI callbacks.
    Expecting onController to fire only for CC (it also handles pitch bend, aftertouch, program change).
    Expecting onControl to fire for processor-connected components.

  See also:
    companion ScriptVoiceStartModulator - per-voice modulation via HiseScript
---

::category-tags
---
tags:
  - { name: custom, desc: "Modules that run user-defined logic via HiseScript callbacks" }
---
::

![Script Processor screenshot](/images/v2/reference/audio-modules/scriptprocessor.png)

The Script Processor is the central scripting module in HISE. It processes incoming MIDI events through six HiseScript callbacks and, when set as the front interface, hosts the plugin's entire user interface. Every HISE project contains at least one Script Processor - typically as the first module in the main synth chain's MIDI processor slot.

Unlike most modules, the Script Processor has no fixed parameters or signal path. Its behaviour is entirely defined by the user's script. Parameters are created dynamically through UI components added in the `onInit` callback, and the processing logic lives in the MIDI and timer callbacks. The module supports both real-time operation (audio thread) and deferred mode (message thread) for callbacks that need to perform heavier work.

## Signal Path

::signal-path
---
glossary:
  functions:
    onInit:
      desc: "Runs once when the script compiles. Declare variables, create UI components, set up module references"
    onNoteOn:
      desc: "Fires on every incoming note-on event. Read and modify the event via the Message object"
    onNoteOff:
      desc: "Fires on every incoming note-off event. Read and modify the event via the Message object"
    onController:
      desc: "Fires on CC, pitch bend, aftertouch, and program change events. Read and modify the event via the Message object"
    onTimer:
      desc: "Fires at a regular interval set by Synth.startTimer(). Sample-accurate when not in deferred mode"
    onControl:
      desc: "Fires when a UI component value changes. Receives the component reference and new value"
---

```
// Script Processor - HiseScript MIDI processing and UI
// MIDI in -> callbacks -> MIDI out

onInit() {
    // Runs once at compile time
    // Declare variables, create UI components
    // Set up module references with Synth.getModulator() etc.
}

onNoteOn() {
    // Access: Message.getNoteNumber(), Message.getVelocity()
    // Modify: Message.setNoteNumber(), Message.ignoreEvent()
    // Play notes: Synth.playNote(), Synth.addVolumeFade()
}

onNoteOff() {
    // Access: Message.getNoteNumber()
    // Modify: Message.ignoreEvent()
}

onController() {
    // Fires for CC, pitch bend, aftertouch, program change
    // Access: Message.getControllerNumber(), Message.getControllerValue()
}

onTimer() {
    // Fires at interval set by Synth.startTimer(seconds)
    // Sample-accurate in real-time mode
    // Not sample-accurate in deferred mode
}

onControl(number, value) {
    // number = the UI component that changed
    // value  = the new value
    // Only fires for components not connected to a processor
}
```

::

### onInit

The `onInit` callback runs once each time the script is compiled. Use it to declare variables, create UI components with `Content.addKnob()`, `Content.addButton()`, and similar methods, and set up references to other modules using `Synth.getModulator()`, `Synth.getEffect()`, etc. Objects created here persist across all other callbacks. Call `Content.makeFrontInterface(width, height)` to designate this Script Processor as the plugin's main interface.

### onNoteOn

Fires on every incoming MIDI note-on event. The `Message` object provides access to the event's properties: `Message.getNoteNumber()`, `Message.getVelocity()`, `Message.getChannel()`, `Message.getTimestamp()`. You can modify the event in place with `Message.setNoteNumber()`, `Message.setVelocity()`, `Message.setChannel()`, or suppress it entirely with `Message.ignoreEvent(true)`. Use `Synth.playNote()` to generate additional notes or `Synth.addVolumeFade()` to schedule volume changes.

### onNoteOff

Fires on every incoming MIDI note-off event. The same `Message` object is available for reading and modifying the event. Typical uses include releasing held notes in a custom legato script or triggering release samples.

### onController

Fires on all continuous controller-type events: MIDI CC messages, pitch bend, channel aftertouch, and program change. Use `Message.getControllerNumber()` and `Message.getControllerValue()` for CC messages. For pitch bend, the controller number is not meaningful - use the value directly. This callback handles the sustain pedal (CC#64) automatically before the script runs, updating the internal sustain state.

:::{.warning}
This callback fires for pitch bend, aftertouch, and program change events in addition to standard CC messages. Always check the event type if your logic is specific to CC numbers.
:::

### onTimer

Fires at a regular interval set by `Synth.startTimer(seconds)`. Call `Synth.stopTimer()` to disable it. In real-time mode (the default), timer events are sample-accurate - they arrive at precise sample positions within the audio buffer. In deferred mode, the timer runs on the message thread and is not sample-accurate. Common uses include sequencer-style note generation, periodic parameter updates, and animation-driving logic.

### onControl

Fires when a UI component's value changes. Receives two parameters:
- `number` - a reference to the component that changed
- `value` - the new value of the component

This callback only fires for components that are **not** connected to a processor parameter, macro control, global cable, or custom control callback. If a component has its `processorId` and `parameterId` properties set, value changes are routed directly to the target processor without triggering `onControl`.

### Deferred Mode

Call `Synth.deferCallbacks(true)` to move all MIDI callbacks from the audio thread to the message thread. This is useful for scripts that perform expensive operations (complex UI updates, data processing) that would cause audio dropouts on the audio thread. The trade-off is that deferred callbacks are no longer sample-accurate and have slightly higher latency. The timer switches from sample-accurate events to a standard periodic timer in deferred mode.

### Available API Objects

The following scripting API objects are available in all callbacks:

- **Message** - read and modify the current MIDI event
- **Synth** - control the parent synthesiser, manage voices, start/stop the timer
- **Engine** - access global engine properties (sample rate, host tempo, buffer size)
- **Content** - create and manage UI components
- **Console** - debug output (`Console.print()`)
- **Sampler** - sampler-specific functions (only functional when the parent is a Sampler module)
- **Server** - HTTP client/server functionality
- **FileSystem** - file read/write operations
- **Settings** - project settings access

**See also:** $MODULES.ScriptVoiceStartModulator$ -- per-voice modulation via HiseScript callbacks
