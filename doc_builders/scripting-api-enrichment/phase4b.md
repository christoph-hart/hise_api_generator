# Phase 4b: LLM C++ Reference -- Agent Instructions

Phase 4b produces structured, concise reference entries for LLMs writing HISEScript or C++ `HardcodedScriptProcessor` code. Each entry is a standalone file optimized for machine consumption: dense, structured, with source code call chains and explicit anti-patterns.

**Audience:** LLM coding agents that need to make correct API choices when writing MIDI/DSP logic in HISEScript or C++ `HardcodedScriptProcessor` code. Not for human readers (that's Phase 4a).

**ASCII-only rule:** All output files must use ASCII characters only. Use `--` instead of em-dashes, straight quotes instead of curly quotes.

> **Note:** For Phase 4a (human-facing docs), see `phase4.md`.

---

## Key Principle: No New Exploration

Phase 4b is a **formatting pass over existing Phase 1 data**. The agent reads two sources and reformats them into the output template. It does NOT explore C++ source code, run searches, or derive new information.

If the exploration file is missing or insufficient for a given class, the correct response is to flag that class as needing a Phase 1 re-run -- not to explore from Phase 4b.

---

## Source Material

The agent reads from three files per class:

### 1. `enrichment/phase1/ClassName/methods.md`

Provides per-method structured data:
- Signature, return type
- callScope and callScopeNote
- Description
- Parameters (name, type, forced, description, constraints)
- Pitfalls
- Cross-references
- Examples

### 2. `enrichment/resources/explorations/ClassName.md`

Provides raw C++ source extracts from Phase 1 exploration:
- File locations (header, implementation, related files) with line numbers
- Full class declaration
- Method implementations with source code
- Call chains showing dispatch from scripting API through to engine internals
- Internal data structures and threading patterns

### 3. `enrichment/phase1/ClassName/Readme.md`

Provides class-level context:
- obtainedVia (how to get an instance)
- Constants and dynamic constants
- Common mistakes
- Alternatives
- Class-level architecture notes

---

## Output

```
enrichment/phase4b/ClassName/methodName.md    # One file per method
```

One file per method. The filename must match the method name exactly (case-sensitive).

---

## Entry Template

```
ClassName::methodName(params) -> returnType

Thread safety: SAFE|WARNING|UNSAFE|INIT + explanation
[1-2 line description]
Required setup: [minimal code to call this method]
Dispatch/mechanics: [what happens internally -- 1-3 lines]
Pair with: [companion methods and why]
Anti-patterns: [what NOT to do and why]
Source:
  file.cpp:line  functionName() -> innerCall() -> deeperCall()
  [key code snippet if illuminating]
```

---

## Field-by-Field Instructions

### Header Line

```
ClassName::methodName(Type1 param1, Type2 param2) -> ReturnType
```

- Use the VarTypes from `methods.md` (e.g., `Double`, `String`, `Function`, `Number`)
- Use `-> undefined` for void methods
- Match the signature exactly as documented in `methods.md`

### Thread Safety

Map from `callScope` in `methods.md`:

| callScope | Phase 4b label | Notes |
|-----------|---------------|-------|
| `safe` | `SAFE` | No qualifiers needed unless callScopeNote exists |
| `warning` | `WARNING` | Always include the callScopeNote explanation |
| `unsafe` | `UNSAFE` | Note what makes it unsafe (allocations, locks, ValueTree mutation) |
| `init` | `INIT` | Note that runtime calls throw a script error |
| `null` | `UNKNOWN -- treat as UNSAFE` | Flag for Phase 1 re-investigation |

If `callScopeNote` exists in `methods.md`, append it after the label:
```
Thread safety: WARNING -- allocates in backend builds (USE_BACKEND), compiled out in exported plugins
```

### Description

1-2 lines. Pull from the `Description` field in `methods.md`. Compress to the essential behavior. Strip prose filler.

**Good:** `Converts input from local range to normalised 0..1 and sends to all cable targets.`
**Bad:** `This method takes a value and converts it using the configured range and then sends it to all targets that are registered with the cable system.`

### Required Setup

Show the minimal code to obtain the object and call the method. Skip this field entirely for:
- Namespace methods (e.g., `Math.max()`, `Engine.getHostBpm()`)
- Methods where the object token is obvious and no setup is needed

Include this field when:
- The object must be obtained via a factory method
- The method requires prior configuration (e.g., setting a range before calling `setValue`)

```
Required setup:
  const var cable = Engine.getGlobalRoutingManager().getCable("myCable");
  cable.setRange(0, 127);
```

### Dispatch/Mechanics

What happens inside, from the scripting API wrapper down to the engine. Pull from the exploration `.md` file which contains the actual call chains and source code.

Skip this field for:
- Simple getters that return a cached value
- Simple setters that assign a value
- Trivial wrappers

Include this field when:
- The method dispatches to multiple targets (e.g., `setValue` fans out to listeners)
- The method has non-obvious internal behavior (e.g., range conversion, clamping)
- The call chain reveals threading or synchronization patterns

Format:
```
Dispatch/mechanics:
  convertTo0to1(input) -> Cable::sendValue(normalised)
    -> iterates targets: GlobalCableNode, ScriptComponent, MacroControl
    -> each target applies its own output range conversion
```

Keep to 1-3 lines. Not a full source code dump -- just enough for an LLM to understand what happens.

### Pair With

Companion methods that are typically used together. Pull from `Cross References` in `methods.md`, but be selective -- only include methods that form a functional pair or workflow.

**Include:**
- `addNoteOn` pairs with `noteOffByEventId` (must release what you create)
- `setValue` pairs with `setRange` (range must be configured first)
- `registerCallback` pairs with `deregisterCallback` (lifecycle)

**Skip:**
- Loose associations (e.g., `getValue` cross-referencing `getValueNormalised` -- these are alternatives, not pairs)

Format:
```
Pair with:
  setRange/setRangeWithSkew/setRangeWithStep -- must configure range before setValue
  registerCallback -- to observe value changes from other sources
```

### Anti-Patterns

What NOT to do. Pull from:
- `Pitfalls` in `methods.md`
- `Common Mistakes` in `Readme.md`
- Insights from the arpeggiator decision tree exercise (documented in the master schema's strategic context)

Format:
```
Anti-patterns:
  - Do NOT call without setting a range first -- defaults to 0..1 identity, making setValue equivalent to setValueNormalised
  - Do NOT use Array to store note events -- Array.push() allocates on the audio thread
```

Skip this field if there are no meaningful anti-patterns for the method.

### Source

File path, line number, and call chain summary. Pull directly from the exploration `.md` file.

Format:
```
Source:
  ScriptingApiObjects.cpp:8952  GlobalCableReference::setValue()
    -> convertTo0to1(input) using NormalisableRange
    -> cable->sendValue(normalised, sendNotification)
```

Always include the file path and line number. The call chain is optional but strongly preferred for non-trivial methods.

---

## Workflow

### Per-class execution

1. Read `enrichment/phase1/ClassName/Readme.md` -- class context
2. Read `enrichment/phase1/ClassName/methods.md` -- all method data
3. Read `enrichment/resources/explorations/ClassName.md` -- source code extracts
4. For each method in `methods.md`:
   a. Extract the relevant data from all three sources
   b. Format into the Phase 4b template
   c. Write to `enrichment/phase4b/ClassName/methodName.md`
5. Verify all methods have an output file

### Session prompt

```
Follow tools/api generator/doc_builders/scripting-api-enrichment/phase4b.md.
Run Phase 4b authoring for [ClassName].
```

### Batch mode

Phase 4b can run on all enriched classes in a single session since it's a pure formatting pass. The agent iterates over all classes that have both a `methods.md` and an exploration file.

---

## What Phase 4b Does NOT Do

- Does NOT explore C++ source code (already done in Phase 1)
- Does NOT produce human-friendly prose (that's Phase 4a)
- Does NOT write into `api_reference.json` -- Phase 4b files are standalone
- Does NOT render diagrams (that's Phase 4a)
- Does NOT generate examples -- the entry is a reference card, not a tutorial
- Does NOT infer new information -- everything comes from Phase 1 artifacts

---

## Quality Checklist

Before submitting a Phase 4b entry, verify:

- [ ] Header line matches the signature in `methods.md` exactly
- [ ] Thread safety label matches `callScope` from `methods.md`
- [ ] Description is 1-2 lines, not prose paragraphs
- [ ] Source file path and line number are present
- [ ] Anti-patterns (if any) describe concrete consequences, not vague warnings
- [ ] No em-dashes, curly quotes, or non-ASCII characters
- [ ] All fields are sourced from Phase 1 artifacts -- nothing invented

---

## Reference Example

### GlobalCable::setValue(Double inputWithinRange) -> undefined

```
GlobalCable::setValue(Double inputWithinRange) -> undefined

Thread safety: SAFE
Converts input from local range to normalised 0..1 and sends to all cable targets.
Clamped internally. Without a configured range, behaves identically to setValueNormalised().

Required setup:
  const var cable = Engine.getGlobalRoutingManager().getCable("myCable");
  cable.setRange(0.0, 127.0);

Dispatch/mechanics:
  convertTo0to1(input) via NormalisableRange -> Cable::sendValue(normalised)
    -> fans out to: GlobalCableNode (scriptnode), ScriptComponent, MacroControl, OSC target
    -> each target applies its own output range

Pair with:
  setRange/setRangeWithSkew/setRangeWithStep -- configure range before calling setValue
  getValue -- reads back the value in the local range
  registerCallback -- observe value changes from other sources

Anti-patterns:
  - Do NOT call without setting a range first -- defaults to 0..1 identity, making
    setValue and setValueNormalised equivalent (confusing, likely a bug)
  - Do NOT use sendData() for numeric values -- sendData is for JSON/string/buffer payloads,
    setValue is for normalised numeric dispatch

Source:
  ScriptingApiObjects.cpp:8952  GlobalCableReference::setValue()
    -> convertTo0to1(input) using NormalisableRange
    -> cable->sendValue(normalised, sendNotification)
    -> iterates registeredTargets: Cable::Target::sendValue()
```
