# Phase 4: User-Facing Documentation Authoring -- Agent Instructions

Phase 4 transforms the raw C++ analysis from Phase 1 into user-facing documentation for HISEScript developers. The agent reads the complete merged `api_reference.json` for a single class and produces `userDocs` content for the class overview and each method.

**Audience:** HISEScript developers who have no knowledge of C++ internals. They want to know what a method does, how to use it, and what to watch out for.

**ASCII-only rule:** All output files must use ASCII characters only. Use `--` instead of em-dashes, straight quotes instead of curly quotes.

---

## Source Material

The agent reads from `enrichment/output/api_reference.json`, specifically the entry for the target class. The following fields are the primary source material:

### Class level
- `description.brief` -- one-line summary
- `description.purpose` -- technical summary (2-5 sentences)
- `description.details` -- full technical reference (may reference C++ internals)
- `description.codeExample` -- usage example
- `description.obtainedVia` -- how the object is obtained in HISEScript
- `commonMistakes` -- common mistakes table

### Method level
- `description` -- technical description (may reference C++ internals)
- `signature` -- method signature with types
- `parameters` -- parameter table with types and descriptions
- `pitfalls` -- non-obvious behaviors
- `examples` -- code examples
- `crossReferences` -- related methods

---

## Output Directories

```
enrichment/phase4/auto/ClassName/       # LLM-generated (this agent writes here)
enrichment/phase4/manual/ClassName/     # Human-edited overrides (never touched by agent)
```

The agent ONLY writes to `phase4/auto/`. Never read or modify files in `phase4/manual/`.

---

## Output File Format

### Class-level: `phase4/auto/ClassName/Readme.md`

```markdown
# ClassName

[4-8 sentences providing a user-facing overview of what this class does,
how you typically use it, the main method groups, and any important
behavioral notes. One or two paragraphs.]
```

The `# ClassName` heading is required. The content below it is a flat prose block -- no subheadings, no bullet lists, no tables. Just clear, well-structured paragraphs. Target a length between the Phase 1 `purpose` and `details` -- substantial enough to orient a scripter, but with all C++ internals stripped.

### Method-level: `phase4/auto/ClassName/methodName.md`

```
[1-3 sentences describing what this method does and how to use it.
No heading required -- the method name is inferred from the filename.]
```

Bare prose, no heading, no structured fields. Just the user-facing description.

---

## Authoring Guidelines

### What to include

- **What the method does** in practical terms
- **What you pass in** and **what you get back**, in HISEScript terms
- **Behavioral notes** that affect the scripter (e.g. "only works in the HISE IDE", "the value is cloned at capture time")
- **Practical limitations** (e.g. "only one benchmark can be active at a time")
- **Cross-references** to related methods when it helps understanding (e.g. "Call `Console.startBenchmark()` first, then `Console.stopBenchmark()` to see the result")

### Class-level deduplication

The Phase 1 method descriptions are intentionally self-contained -- each method repeats class-wide facts (e.g. "only works in the HISE IDE") so it can stand alone when served by the MCP server. In Phase 4, the agent sees the full class and writes prose that will be displayed together on a single page. Repeating class-wide facts on individual methods creates noise rather than reinforcement.

Before writing method-level userDocs, identify behavioral patterns that apply across multiple methods:

- Build restrictions (e.g. "IDE-only", "no-op in exported plugins")
- Prerequisite requirements (e.g. "requires the profiling toolkit")
- Thread restrictions (e.g. "cannot be called from the message thread")

State these once in the class-level `Readme.md`. Then omit them from individual method files unless a method is a notable *exception* to the class-wide rule (e.g. one method that *does* work in exported plugins when the rest don't).

This means an individual method's userDocs may be shorter and more focused than its Phase 1 description -- that is intentional. The Phase 1 description remains the authoritative standalone reference; the Phase 4 userDocs is the page-context version.

### What to strip

- C++ class names (e.g. `AudioThreadGuard::Suspender`, `JavascriptThreadPool::ScopedSleeper`)
- Preprocessor guard names (e.g. `USE_BACKEND`, `HISE_INCLUDE_PROFILING_TOOLKIT`)
- Implementation details (e.g. "uses `reportScriptError` internally", "casts to `bool` via JUCE `var` conversion")
- Thread safety internals (e.g. "dispatched asynchronously to the message thread via `MessageManager::callAsync`")
- C++ type system references (e.g. "`var`", "`const String&`", "`dynamic_cast`")
- Source code references (e.g. "defined in `ScriptingApi.cpp` line 6693")

### Tone

- **Direct and practical.** Write as if you are explaining the method to a colleague who knows HISEScript but hasn't used this particular method before.
- **Concise.** Most methods need 1-2 sentences. Only use 3 sentences if there is genuinely more to say.
- **Specific.** Avoid vague statements like "useful for debugging" -- say what it actually does.
- **No marketing language.** No "powerful", "flexible", "easy-to-use", etc.

### Length

- **Class-level `Readme.md`:** 4-8 sentences (one or two substantial paragraphs). The goal is a length between the Phase 1 `purpose` and `details` fields, but with all C++ internals stripped. Cover what the class is for, how you typically obtain/use it, the main method groups, and any important behavioral notes (e.g. "most methods are no-ops in exported plugins"). For simple utility classes 4 sentences may suffice; for complex classes with multiple modes or subsystems, use the full 8.
- **Method-level files:** 1-3 sentences. Most simple methods (getters, setters, assertions) need just 1 sentence. Methods with non-obvious behavior or multi-step workflows may need 2-3.

### Examples

The `userDocs` prose should NOT include code examples -- those are already captured in the `examples` field of the JSON and are rendered separately by the preview/website. Focus purely on explanation.

### Cross-references in prose

When referencing other methods in the same class, use backtick-wrapped names: e.g. `` `Console.startBenchmark()` ``. When referencing methods in other classes, use the full qualified name: e.g. `` `Engine.logSettingWarning()` ``.

---

## Workflow

### Per-class execution

The agent runs once per class:

1. Read the merged `api_reference.json`
2. Extract the target class entry
3. Identify which methods need `userDocs`:
   - Check `phase4/manual/ClassName/` -- any file here means "skip, human-reviewed"
   - Check `phase4/auto/ClassName/` -- any file here means "skip, already authored"
   - Only write files for methods that have neither
4. Also check if `Readme.md` needs writing (same logic -- manual wins, then auto, then write)
5. Write all new files to `phase4/auto/ClassName/`

### Session prompt

```
Follow tools/api generator/doc_builders/scripting-api-enrichment/phase4.md.
Run phase4 authoring for [ClassName].
```

### After authoring

```bash
python api_enrich.py merge
python api_enrich.py preview [ClassName]
```

Then review `[ClassName].html` for user-facing quality. If any method's `userDocs` needs manual adjustment:

1. Copy `phase4/auto/ClassName/methodName.md` to `phase4/manual/ClassName/methodName.md`
2. Edit the manual copy
3. Re-run merge + preview

---

## Quality Checklist

Before finalizing `userDocs` for a class, verify:

- [ ] No C++ class names, preprocessor guards, or implementation details leak through
- [ ] Every method has a `userDocs` that would make sense to someone who only knows HISEScript
- [ ] Class-level `Readme.md` provides useful context and groups methods logically
- [ ] Cross-references use backtick-wrapped method names
- [ ] All content is ASCII-only
- [ ] Prose reads naturally -- no robotic "this method does X" repetition across every entry
