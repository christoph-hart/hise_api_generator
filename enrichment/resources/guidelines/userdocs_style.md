# userDocs Writing Style Guidelines

Authoritative reference for all `userDocs` prose -- class-level and method-level. This file is the single source of truth; `phase4.md` references it rather than duplicating these rules.

---

## Purpose and Audience

`userDocs` is the human-facing documentation displayed on docs.hise.dev. Its audience is HISEScript developers who have no knowledge of C++ internals. They want to know what a method does, how to use it, and what to watch out for.

`userDocs` is distinct from the `description` field:

| Field | Audience | Purpose |
|-------|----------|---------|
| `description` | LLMs, MCP server, autocomplete | Self-contained technical summary. May include C++ context for precision. Intentionally repeats class-wide facts so each method stands alone. |
| `userDocs` | Human readers on docs.hise.dev | Concise explanation for a page where all methods are shown together. No C++ internals. No repetition of class-wide facts. |

Do not duplicate content between them. If `description` already says something, `userDocs` should add value, not echo it.

---

## What to Include

- **What the method does** in practical terms
- **What you pass in** and **what you get back**, in HISEScript terms
- **Behavioral notes** that affect the scripter (e.g. "only works in the HISE IDE", "the value is cloned at capture time")
- **Practical limitations** (e.g. "only one benchmark can be active at a time")
- **Cross-references** to related methods when it helps understanding (e.g. "Call `Console.startBenchmark()` first, then `Console.stopBenchmark()` to see the result")
- **String enum tables:** When a method accepts a fixed set of string values and the Phase 1 data includes a `valueDescriptions` field, present them in a table in the userDocs prose rather than listing them inline. This gives the reader real information beyond the method signature. For trivial self-explanatory values, an inline list is acceptable -- use judgment on whether a table adds value. When in doubt, prefer the table: it prevents the userDocs from becoming a stub that just restates the method name

---

## What to Strip

These elements must NEVER appear in userDocs. They are implementation details that mean nothing to a HISEScript developer.

- **C++ class names** -- e.g. `AudioThreadGuard::Suspender`, `JavascriptThreadPool::ScopedSleeper`, `DynamicObject`
- **Preprocessor guard names** -- e.g. `USE_BACKEND`, `HISE_INCLUDE_PROFILING_TOOLKIT`, `HI_EXPORT_AS_PROJECT_DLL`
- **Implementation details** -- e.g. "uses `reportScriptError` internally", "casts to `bool` via JUCE `var` conversion", "delegates to the underlying `WeakReference`"
- **Thread safety internals** -- e.g. "dispatched asynchronously to the message thread via `MessageManager::callAsync`". Instead say "runs asynchronously on the UI thread" if the threading behavior matters to the scripter.
- **C++ type system references** -- e.g. "`var`", "`const String&`", "`dynamic_cast`", "`static_cast`". Use HISEScript types instead: "String", "Number", "Array", "Object", "Function".
- **Source code references** -- e.g. "defined in `ScriptingApi.cpp` line 6693", "see `MainController::UserPresetHandler`"
- **Negative guidance that duplicates pitfalls** -- don't tell the user what values are *not* allowed when the API already reports a script error for invalid input. State what to do, not what to avoid. Mention restrictions only when they are non-obvious and the API won't catch them with an error message.

**Translation examples:**

| Phase 1 description (C++ aware) | userDocs equivalent |
|---|---|
| "Calls `reportScriptError` if the index is out of bounds" | *(omit -- the API handles it)* |
| "Dispatched via `MessageManager::callAsync` to avoid blocking the audio thread" | "Runs asynchronously on the UI thread" |
| "Returns a `var` containing the JSON object" | "Returns the configuration as a JSON object" |
| "Guarded by `USE_BACKEND` -- no-op in exported plugins" | "Only works in the HISE IDE" |

---

## Tone

- **Direct and practical.** Write as if you are explaining the method to a colleague who knows HISEScript but hasn't used this particular method before.
- **Concise.** Most methods need 1-2 sentences. Only use 3 sentences if there is genuinely more to say.
- **Specific.** Avoid vague statements like "useful for debugging" -- say what it actually does.
- **No marketing language.** No "powerful", "flexible", "easy-to-use", etc.

---

## Length

- **Class-level `Readme.md`:** 4-8 sentences (one or two substantial paragraphs). Cover what the class is for, how you typically obtain/use it, the main method groups, and any important behavioral notes (e.g. "most methods are no-ops in exported plugins"). For simple utility classes 4 sentences may suffice; for complex classes with multiple modes or subsystems, use the full 8.
- **Method-level files:** 1-3 sentences. Most simple methods (getters, setters, assertions) need just 1 sentence. Methods with non-obvious behavior or multi-step workflows may need 2-3.

---

## Class-Level Deduplication

The Phase 1 method descriptions are intentionally self-contained -- each method repeats class-wide facts (e.g. "only works in the HISE IDE") so it can stand alone when served by the MCP server. In Phase 4, the agent sees the full class and writes prose that will be displayed together on a single page. Repeating class-wide facts on individual methods creates noise rather than reinforcement.

Before writing method-level userDocs, identify behavioral patterns that apply across multiple methods:

- Build restrictions (e.g. "IDE-only", "no-op in exported plugins")
- Prerequisite requirements (e.g. "requires the profiling toolkit")
- Thread restrictions (e.g. "cannot be called from the message thread")

State these once in the class-level `Readme.md`. Then omit them from individual method files unless a method is a notable *exception* to the class-wide rule (e.g. one method that *does* work in exported plugins when the rest don't).

This means an individual method's userDocs may be shorter and more focused than its Phase 1 description -- that is intentional. The Phase 1 description remains the authoritative standalone reference; the Phase 4 userDocs is the page-context version.

---

## Lead with the Concept, Not the Signature

The reader can already see the method signature. userDocs should explain the *concept* or *use case* that motivates the method, not restate what the signature already says.

**Good** -- explains the concept that makes `clone()` necessary:
> If you assign an array reference to another variable, you're only setting the reference. Changes to one will affect the other. Use `clone()` to create an independent copy.

**Bad** -- restates the signature:
> The `clone` method creates a copy of the array and returns it.

**Good** -- explains the mental model behind the data flow:
> There is not a data queue for the sender side -- if you register a target after data has been sent, it will not receive the previously sent value.

**Bad** -- restates what the method does:
> The `sendData` method sends data to the cable targets.

---

## Don't Restate the Signature

If a method is `getSampleRate()` and returns a number, writing "Returns the sample rate of the audio file" adds nothing. Instead, explain something the reader would not know from the signature alone:

**Good** -- explains the distinction between two similar methods:
> Returns the sample rate of the loaded file, which may differ from `Engine.getSampleRate()` (the audio driver's rate). Divide the two to get the playback speed ratio for matching pitch.

**Bad** -- restates the obvious:
> The `getSampleRate` method returns the sample rate of the audio file. The sample rate is the number of samples per second.

If a method truly has nothing to add beyond its signature, a single focused sentence is still better than a padded paragraph. "Returns the width of this component in pixels." is acceptable for a trivial getter.

---

## No Code Examples in Prose

The `userDocs` prose should NOT include code examples -- those are already captured in the `examples` field of the JSON and are rendered separately by the preview/website. Focus purely on explanation.

---

## Cross-References in Prose

When referencing other methods in the same class, use backtick-wrapped names: e.g. `` `Console.startBenchmark()` ``. When referencing methods in other classes, use the full qualified name: e.g. `` `Engine.logSettingWarning()` ``.

Weave cross-references into natural sentences. Do not use bulleted "Related Methods:" lists -- those are a leftover from the old docs format and read as boilerplate.

**Good:**
> You can customize the sort order by supplying a comparison function via `Engine.sortWithFunction()`.

**Bad:**
> **Related Methods:**
> - `Engine.sortWithFunction`

---

## Formatting

The following formatting elements are preserved in `userDocs` output and should be used where they improve readability:

- **Blockquotes** (`> ...`) -- use for non-obvious caveats, threading warnings, and edge-case behavior. These stand out visually on the docs site.
- **Tables** (`| Column | ... |`) -- use for enumerated options, mode lists, or value descriptions. Prefer tables over long comma-separated lists.
- **Bold/italic** -- use sparingly for emphasis.
- **Inline code** (`` `backticks` ``) -- use for method names, property names, string values, and HISEScript keywords.

The following are **stripped** by the parser and should not be relied upon:

- **Images** (`![alt](/path)`) -- removed entirely. Write for text-only rendering.
- **Non-API links** (`[text](/some/path)`) -- link markup removed, link text preserved as plain text.
- **`#### Example` headings** -- removed (code blocks go to the `examples` array).

---

## Reference Examples

Two completed classes illustrate the target style. Review both before authoring a new class to avoid style overfitting to either one.

### Console (simple namespace, 17 methods)

Console is a small namespace where every method is IDE-only. The class-level Readme states this once, so individual methods omit it.

**Class Readme excerpt:**
```
Console provides logging, assertion, and profiling methods for use during development
in the HISE IDE. Most methods are no-ops in exported plugins, and the profiling
methods (startBenchmark, stopBenchmark, startSampling, sample) require the profiling
toolkit to be active.
```

**Method example -- `print.md`:**
```
Logs a value to the HISE console. Accepts any type -- numbers, strings, objects,
and arrays are all printed in a readable format.
```

**Method example -- `stopBenchmark.md`:**
```
Stops the benchmark timer started by `Console.startBenchmark()` and prints the
elapsed time to the console.
```

Key patterns: class-wide restrictions stated once in the Readme; method docs focus purely on what each method does; cross-references use backtick-wrapped names.

### ScriptedViewport (UI component, 41 methods -- 34 common, 7 unique)

ScriptedViewport demonstrates a different challenge: most methods are common to all UI components, and the class has three distinct operational modes. The Readme uses a table to present the modes compactly and keeps the method grouping to a birds-eye statement.

**Class Readme excerpt:**
```
# ScriptedViewport

ScriptedViewport is a UI component created with `Content.addViewport("id", x, y)`.
It operates in one of three modes:

| Mode | How to activate | Value |
|------|----------------|-------|
| Viewport | Default (no flags) | Scroll position |
| List | Set `useList` property to `true` | Selected index |
| Table | Call `setTableMode()` in onInit | `[column, row]` array |

In table mode, you define columns with `setTableColumns()`, populate rows with
`setTableRowData()`, and receive interactions through `setTableCallback()`. [...]
All table setup methods must be called during `onInit` -- only `setTableRowData()`
can update content later.

The viewport-specific methods handle table setup and interaction. The remaining
methods are common to all UI components.
```

**Method example -- `setTableMode.md` (viewport-specific, multi-step setup):**
```
Converts this viewport into a table component. Pass a metadata object with optional
"CallbackOnSliderDrag" (default true) and "MultiColumnMode" (default false)
properties. In multi-column mode, the component's value becomes a `[column, row]`
array on selection. Must be called during onInit.
```

**Method example -- `getWidth.md` (common, trivial getter):**
```
Returns the width of this component in pixels.
```

**Method example -- `setConsumedKeyPresses.md` (common, prerequisite pattern):**
```
Registers which key presses this component should consume when focused. Pass an
array of key descriptions, a single key string, or "all"/"all_nonexclusive". Must
be called before `setKeyPressCallback()`.
```

Key patterns: the Readme uses a table for the three modes instead of prose; method grouping is a brief birds-eye statement ("viewport-specific" vs. "common to all UI components") without listing individual method names; no C++ inheritance language; init-time restrictions are noted on the specific methods that require them (since only 3 of 41 methods have this restriction, it is not a class-wide fact); trivial common getters get one sentence.

---

## Quality Checklist

Before finalizing `userDocs` for a class, verify:

- [ ] No C++ class names, preprocessor guards, or implementation details leak through
- [ ] Every method has a `userDocs` that would make sense to someone who only knows HISEScript
- [ ] Methods with Phase 3 raw docs `userDocs` were skipped (not overwritten)
- [ ] Class-level `Readme.md` provides useful context and groups methods logically
- [ ] Cross-references use backtick-wrapped method names
- [ ] All content is ASCII-only (no em-dashes, curly quotes, etc.)
- [ ] Prose reads naturally -- no robotic "this method does X" repetition across every entry
- [ ] Class-wide facts are stated once in the Readme, not repeated on each method
- [ ] No "Related Methods:" bullet lists -- cross-references are woven into sentences
- [ ] No code examples in the prose -- those belong in the `examples` field
- [ ] SVG diagrams rendered for all methods/classes with a `diagram` field (unless manual SVG exists)
