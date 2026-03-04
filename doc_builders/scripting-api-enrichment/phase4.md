# Phase 4a: User-Facing Documentation Authoring - Agent Instructions

Phase 4a transforms the raw C++ analysis from Phases 1-3 into user-facing documentation for HISEScript developers. The agent reads the complete merged `api_reference.json` for a single class and produces `userDocs` content for the class overview and each method. Phase 4a also renders SVG diagrams for methods/classes that have a `diagram` specification.

> **Note:** This file covers Phase 4a (human-facing docs). For Phase 4b (LLM C++ reference), see `phase4b.md`.

**Audience:** HISEScript developers who have no knowledge of C++ internals. They want to know what a method does, how to use it, and what to watch out for.

**ASCII-only rule:** All output files must use ASCII characters only. No em-dashes (use a regular dash or rewrite the sentence), no curly quotes.

**Phase 3 as input:** Phase 3 files are the author's "no-filters diary" - conversational notes with high-level ideas, integration patterns, and domain insights. These files will be **injected into your prompt** when they exist. Extract unique insights, transform conversational prose to technical style, and incorporate into your userDocs. Phase 3 does NOT mechanically set userDocs - you read it as source material and decide what to include.

**Pitfalls and common mistakes are authored here.** Phase 1 and Phase 2 produce structured pitfall and common mistake data in the JSON. Phase 4a is responsible for curating and integrating this content directly into the `.md` files (as blockquote warnings and a Common Mistakes section). The merge/preview pipeline does not inject them mechanically - what you write is what appears on the page.

---

## Source Material

The agent reads from `enrichment/output/api_reference.json`, specifically the entry for the target class. The following fields are the primary source material:

### Class level
- `description.brief` -- one-line summary
- `description.purpose` -- technical summary (2-5 sentences)
- `description.details` -- full technical reference (may reference C++ internals)
- `description.projectContext` -- real-world usage context from analyzed HISE projects (Phase 2). Contains structured sub-sections: Real-World Use Cases (concrete examples from specific projects), Complexity Tiers (progressive method groups from beginner to advanced), Practical Defaults (most common configuration choices with evidence), and Integration Patterns (method-to-method connections with other HISE systems). Use this to ground the user-facing overview in practical reality -- it provides the "how it's actually used" perspective that C++ analysis cannot. When present, prefer project-derived use cases over generic descriptions.
- `description.codeExample` -- usage example
- `description.obtainedVia` - how the object is obtained in HISEScript
- `commonMistakes` - common mistakes table (Phase 1 auto + Phase 2 project-tagged entries; curate into a `## Common Mistakes` section in the Readme.md)

### Method level
- `description` - technical description (may reference C++ internals)
- `signature` - method signature with types
- `parameters` - parameter table with types and descriptions
- `pitfalls` - non-obvious behaviors (Phase 1/2 structured data; curate into userDocs as `> **Warning:**` blockquotes)
- `examples` - code examples
- `crossReferences` - related methods
- `diagram` - diagram specification (if present): `type` + `description`

### Phase 3: Author's Diary (Injected into Prompt When Present)

Phase 3 files are conversational notes written by the author - high-level ideas, integration patterns, domain insights, and real-world conventions. When they exist, they will be **injected directly into your prompt** (not available in the JSON).

**Location:**
- `enrichment/phase3/{ClassName}/Readme.md` - class-level diary
- `enrichment/phase3/{ClassName}/{methodName}.md` - method-level diary

**Your Task: Extract Substance, Strip Filler**

Read Phase 3 content and extract:
- **Integration patterns** - "GlobalCable: prepend `/` to cable ID to make it an OSC address"
- **Cross-system interop** - "GlobalCable is the preferred way to communicate from C++ scriptnode nodes"
- **Workflow patterns** - "TransportHandler: stop internal clock before loading preset, restart after"
- **Domain conventions** - "Broadcaster metadata: use `/**` comment to auto-populate comment field"
- **Design rationale** - Why the API works this way
- **Use case narratives** - High-level "how you'd use this" stories

**Ignore conversational filler:**
- "in order to", "just", "also", "super helpful", "will come in handy"
- Redundant restatements of Phase 1 technical facts
- Vague introductions without concrete detail

**Transformation Example:**

Phase 3 prose:
> "If you want to use a cable as OSC address that can send and receive values from external applications, you just need to prepend `/` before the id, so any cable that has an ID like `/some_osc_id` will automatically be used as OSC address as soon as you start using the global routing system as OSC server."

Your extraction:
> "Cable IDs with `/` prefix become OSC addresses when the global routing system runs as OSC server."

**Length Warning:**

If Phase 3 files exceed 500 lines, they will be noted in your prompt. Document this in your decision log: "Phase 3 {file} is {N} lines. Skimmed for unique patterns, found {X} insights incorporated."

---

## Output Directories

```
enrichment/phase4/auto/ClassName/       # LLM-generated userDocs + auto SVGs (agent writes here)
enrichment/phase4/manual/ClassName/     # Human-edited overrides + manual SVGs (never touched by agent)
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

## Common Mistakes

- **Wrong:** [code or description of the mistake]
  **Right:** [code or description of the correct approach]
  *[1-2 sentence explanation of why the wrong version fails.]*

[Repeat for each curated common mistake.]
```

The `# ClassName` heading is required. The overview content below it should be concise and scannable - no subheadings in the overview prose, but markdown tables and bullet lists are allowed when they improve readability (e.g. a table showing distinct modes or a short list of method groups). Target a length between the Phase 1 `purpose` and `details` - substantial enough to orient a scripter, but with all C++ internals stripped.

The `## Common Mistakes` section is optional but recommended for classes with non-trivial usage patterns. Curate from the `commonMistakes` array in the JSON - you have editorial discretion to omit entries that are too obvious, too niche, or redundant with the overview prose. The format must be exactly as shown above (the preview pipeline renders it from the markdown).

### Method-level: `phase4/auto/ClassName/methodName.md`

```
[1-3 sentences describing what this method does and how to use it.
No heading required - the method name is inferred from the filename.]

> **Warning:** [non-obvious behavioral gotcha curated from the pitfalls array]
```

Bare prose, no heading, no structured fields. Optionally followed by `> **Warning:**` blockquotes for important pitfalls. See "Pitfall Integration" below for curation guidance.

---

## Authoring Guidelines

See `enrichment/resources/guidelines/userdocs_style.md` for the complete prose writing rules, including what to include, what to strip (C++ internals, preprocessor guards, implementation details), tone, length, class-level deduplication, formatting conventions, and reference examples.

---

## Pitfall Integration

Phase 1 and Phase 2 produce structured `pitfalls` data for methods. These remain in the JSON for LLM/MCP consumers. Phase 4a's job is to curate which pitfalls appear on the docs page and how they are phrased.

### Curation rules

1. **Check each method's `pitfalls` array** before writing its `.md` file.
2. **Integrate important pitfalls** as `> **Warning:** ...` blockquotes at the end of the method's prose.
3. **Omit pitfalls that are:**
   - Too obvious from the signature (e.g., "throws an error if index is out of bounds")
   - Already caught by the API with an error message (the API handles it; no need to warn the reader)
   - Redundant with the prose you just wrote (do not restate the same fact in both prose and a warning)
   - Too niche or edge-case for the docs page (they stay in the JSON for power users via MCP)
4. **One warning per method is typical; two is the practical maximum.** More than two warnings makes the method feel like a minefield. If you have three important pitfalls, weave one into the prose naturally and use blockquotes for the other two.
5. **Do not duplicate between prose and warning.** Pick one location for each fact. If the prose already covers it, skip the blockquote.

### Format

```markdown
Registers a callback that fires on each musical beat. The callback receives
the beat index and a boolean for whether this is the first beat of a new bar.

> **Warning:** Does not fire immediately upon registration (unlike `setOnTempoChange`
> and `setOnTransportChange`). The first callback arrives at the next beat boundary.
```

The `> **Warning:**` format renders as a styled callout on the docs page. Use `**Warning:**` consistently (not "Note:", "Caution:", etc.).

---

## Common Mistakes Integration

The `commonMistakes` array in the JSON contains wrong/right/explanation entries from Phase 1 (auto-detected) and Phase 2 (project-derived). Phase 4a curates these into a `## Common Mistakes` section in the class-level `Readme.md`.

### Curation rules

1. **Review the full `commonMistakes` array** including project-tagged entries.
2. **Keep entries that represent genuine, non-obvious traps.** A good common mistake is one where the code looks reasonable but silently does the wrong thing.
3. **Omit entries that are:**
   - Redundant with the overview prose (if the overview already explains the correct approach clearly, a "don't do the opposite" entry adds little)
   - Caught by the API with a clear error message (the scripter will see the error; no need to pre-warn)
   - Too specific to a single edge case
4. **Reword entries freely.** The Phase 1/2 text is raw analysis; your version should read naturally as user-facing guidance.
5. **Typical count: 2-5 entries.** Fewer for simple classes, more for classes with complex setup requirements.

---

## Editorial Self-Review

After writing all `.md` files (Readme + methods), re-read them together as a single page. Apply these edits directly to the source files:

1. **Consolidate repeated cross-method facts.** If 3+ methods state the same fact (e.g., "this is a global operation"), move it to the Readme and remove from individual methods. Keep it on a specific method only if it is genuinely surprising there.
2. **Resolve prose/warning overlap.** If a method's prose restates what its warning blockquote says, cut the weaker version.
3. **Remove filler.** "currently", "as its argument", "this specific", unnecessary "will".
4. **No em-dashes.** Use a regular dash or rewrite the sentence.
5. **Merge redundant sentences** within a single method's prose.

This step catches redundancy patterns that are only visible when all methods are read together. It is the final step before running the mechanical merge + preview.

---

## Example Selection (Phase 3 vs Phase 2 Triage)

When both Phase 3 (hand-written) and Phase 2 (project-extracted) examples exist for the same method, choose based on quality:

**Prefer Phase 3 when:**
- Minimal, focused demonstration of a specific feature
- Clear comments explaining the pattern
- Self-contained (minimal setup boilerplate)
- Shows conventions or patterns not in Phase 2

**Prefer Phase 2 when:**
- Real-world integration with multiple classes/methods
- Demonstrates practical complexity Phase 3 doesn't cover
- Includes error handling or edge cases
- Shows architectural patterns from actual projects

**Include both when:**
- Both are high quality and show complementary aspects
- Label as "Basic Example" (Phase 3) and "Real-World Usage" (Phase 2)

**Close calls:**
- If quality is similar, prefer Phase 3 (author intent)
- Document close calls in decision log: "Close call between Phase 2 and Phase 3 examples. Used Phase 3 for clarity, but Phase 2 shows more realistic ID naming (`masterVolume` vs `volume`)"

---

## Decision Logging

Create a decision log in `enrichment/output/decisions/{ClassName}_phase4a.md` documenting **non-obvious decisions** made during authoring.

**What to Document (Non-Obvious Only):**

Skip obvious cases like "used Phase 3 example because no Phase 2 exists". Document judgment calls:

**Example Selection:**
- When you chose one example over another (Phase 3 vs Phase 2 triage)
- When you included both examples (rationale for complementary value)
- When you omitted an example (too long, duplicates concepts, poor quality)

**Phase 3 Content:**
- What insights you incorporated from Phase 3 (OSC patterns, C++ interop, workflows)
- What you omitted from Phase 3 (redundant with Phase 1, too conversational, not valuable)
- Length warnings (if Phase 3 file exceeded 500 lines)

**Diagram Decisions:**
- Why you rendered a diagram (complex topology, timing critical)
- Why you cut a diagram (redundant with prose/table, simple concept)

**Pitfall Integration:**
- When you merged multiple pitfalls into one warning (deduplication)
- When you omitted a pitfall (redundant, not actionable)

**Style Consolidations:**
- When you moved repeated facts from methods to class overview
- When you resolved prose/warning duplication

**Format:**

Structure the decision log with **two sections**:

1. **Class-Level Decisions** - big-picture decisions affecting the entire class
2. **Method Decisions** - per-method decisions, grouped under `### {MethodName}` headings

**Only include methods with non-obvious decisions.** Skip methods where all choices were obvious (e.g., "used Phase 3 example because no Phase 2 exists").

```markdown
# Phase 4a Authoring Decisions - {ClassName}

Generated: {timestamp}

## Class-Level Decisions

- Incorporated OSC address pattern from Phase 3 class diary (/ prefix for OSC addresses)
- Rendered 2 diagrams (cable-dispatch, callback-threading), cut 1 (registerCallback - redundant with class-level)
- Consolidated "global operation" statement (repeated on 3 methods) into class overview

## Method Decisions

### setSyncMode

- Used Phase 2 example over Phase 3. Rationale: Phase 2 shows preset-switching integration, Phase 3 is minimal demo.
- Merged Phase 1 pitfall #2 and Phase 2 common mistake into single warning.

### startInternalClock

- Used Phase 3 example (minimal, clear). Phase 2 example too complex for basic usage.
- Phase 3 method diary is 650 lines - skimmed for patterns, incorporated timestamp workflow.

### setOnGridChange

- Close call between Phase 2 and Phase 3 examples. Used Phase 3 for clarity.

(Methods with no non-obvious decisions are not listed)
```

**Keep it concise:** Only document judgment calls, not obvious choices.

---

## Workflow

### Per-class execution

The agent runs once per class. **Diagrams are rendered first**, then userDocs are written (this allows the `.md` files to embed or link to diagram SVGs), then the editorial self-review pass runs.

1. Read the merged `api_reference.json`
2. Extract the target class entry
3. **Validate examples** (pre-authoring quality gate):
   ```bash
   python snippet_validator.py --validate --source all --class ClassName
   ```
   Fix any failing examples before proceeding. Do not write user-facing prose about examples that fail validation.
4. **Review Phase 3 diary** (if present):
   - Check for Phase 3 files: `enrichment/phase3/{ClassName}/Readme.md` (class-level), `enrichment/phase3/{ClassName}/{methodName}.md` (method-level)
   - If found, Phase 3 content will be **injected into your prompt** by the orchestration system
   - Read and extract unique insights not in Phase 1/2 (integration patterns, cross-system interop, workflow sequences, domain conventions)
   - Note for decision log: what you incorporated, what you omitted, any length warnings (if file >500 lines)
5. **Triage diagrams** (see Diagram Triage below):
   - Review all diagram descriptions from Phase 1 (class-level `diagrams[]` and method-level `diagram` fields)
   - For each diagram, decide: render as SVG, or cut in favor of prose/tables
   - Diagrams that survive triage proceed to rendering; cut diagrams are simply not rendered (the text description remains in the JSON for LLM consumers)
6. **Render surviving SVG diagrams** (see Diagram SVG Rendering below):
   - For each class-level diagram that survived triage, render an SVG
   - For each method diagram that survived triage, render an SVG
   - Skip if a manual or auto SVG already exists
7. Write class-level `Readme.md`:
   - Check `phase4/manual/ClassName/Readme.md` - if present, skip
   - Check `phase4/auto/ClassName/Readme.md` - if present, skip (Phase 3 no longer sets userDocs)
   - Write `Readme.md` with user-facing prose incorporating Phase 3 insights in technical style
   - Add a `## Common Mistakes` section (curated from `commonMistakes` array)
   - Embed class-level diagram SVGs as `![brief](filename.svg)` (see Embedding Diagrams below)
   - If a diagram was cut during triage because a table or prose covers the same information better, use that table/prose instead
8. Write method-level `.md` files:
   - Check `phase4/manual/ClassName/methodName.md` - if present, skip
   - Check `phase4/auto/ClassName/methodName.md` - if present, skip (Phase 3 no longer sets userDocs)
   - Write `methodName.md` with user-facing prose incorporating Phase 3 insights
   - Integrate important pitfalls from the method's `pitfalls` array as `> **Warning:**` blockquotes (see Pitfall Integration above)
   - If the method has a `diagram` field that survived triage, embed the SVG as `![brief](filename.svg)`
   - If the method has a `diagramRef` field pointing to a rendered class-level diagram, link to the anchor: `[See: brief](#diagram-id)`
   - If the method's diagram or diagramRef was cut during triage, do not reference it
9. **Document authoring decisions** (see Decision Logging below):
   - Create `enrichment/output/decisions/{ClassName}_phase4a.md` with non-obvious decisions made during authoring
10. **Editorial self-review** (see Editorial Self-Review above):
   - Re-read all `.md` files together as a single page
   - Consolidate repeated facts, resolve prose/warning overlap, remove filler
   - Edit the source `.md` files directly

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

## Reference Examples

See `enrichment/resources/guidelines/userdocs_style.md` for two completed reference examples (Console and ScriptedViewport) that illustrate the target style. Review both before authoring a new class.

---

## Diagram Triage

Phase 1 generates diagram descriptions generously -- every pattern that could benefit from visualization gets a description. Phase 4's job is to decide which of those descriptions actually deserve an SVG rendering.

### Triage criteria

For each diagram description, evaluate:

1. **Does the diagram add comprehension beyond what prose or tables already provide?** If the same information is already clear in a compact table (e.g. 3 rows showing 3 modes) or a short paragraph, the diagram may not earn its space. Cut it.

2. **Can the diagram replace prose?** If a diagram communicates a concept more effectively than a paragraph of text, render the diagram and trim the redundant prose from the userDocs. This is the best outcome -- a diagram that displaces text rather than duplicating it.

3. **Slightly favor diagrams.** When it is a close call -- the information could work as either prose or a diagram -- lean toward rendering the diagram. Diagrams are more engaging, more scannable, and provide a different modality of understanding.

4. **Each diagram must earn its place independently.** Multiple diagrams per class are fine, but each one must pass the triage on its own merits. Do not render a diagram just because other diagrams exist.

### What happens to cut diagrams

Cut diagrams are simply not rendered as SVGs. The plain-text `description` field remains in `api_reference.json` and is still available to LLM consumers (MCP server, autocomplete) who cannot render SVGs anyway. No data is lost -- only the visual rendering is skipped.

### Triage output

Before rendering, briefly note the triage decision for each diagram in a comment block at the top of the class `Readme.md`:

```markdown
<!-- Diagram triage:
  - topology-overview: RENDER (complex fan-in/fan-out not expressible in prose)
  - setup-sequence: RENDER (replaces setup paragraph)
  - connection-states: CUT (3 states already clear in mode table)
-->
```

This makes triage decisions reviewable. The comment is stripped by the merge script and does not appear in final output.

---

## Diagram SVG Rendering

When a method or class has diagram data that survived triage, Phase 4 renders it as an SVG file. **Diagrams are rendered in step 4 (before userDocs writing)** so that the `.md` files can reference them.

### SVG file naming

- Class-level diagrams: `{type}_{id}.svg` (e.g. `state_viewport-modes.svg`)
- Method-level diagrams: `{type}_{methodName}.svg` (e.g. `timing_registerCallback.svg`)

### Rendering workflow

1. Check `phase4/manual/ClassName/{filename}.svg` -- if present, skip (hand-crafted)
2. Check `phase4/auto/ClassName/{filename}.svg` -- if present, skip (already rendered)
3. Generate an SVG diagram based on `diagram.type`, `diagram.description`, and the full method/class context
4. Write to `phase4/auto/ClassName/{filename}.svg`

### Embedding diagrams in userDocs

After rendering, the `.md` files reference diagrams using standard markdown:

**Class-level `Readme.md`:** Embed class diagrams inline at a natural position in the prose:
```markdown
![Table Mode Setup Sequence](sequence_table-setup.svg)
```

**Method-level `methodName.md`:** Two cases:
- Method has its own `diagram` field: embed directly with `![brief](filename.svg)`
- Method has a `diagramRef` field: link to the class-level diagram anchor instead of embedding:
  ```markdown
  [See: ScriptedViewport Operating Modes](#diagram-viewport-modes)
  ```
  The anchor format is `#diagram-{id}` where `{id}` is the diagram's `id` field.

A method has `diagram`, `diagramRef`, or neither. Never both.

### Manual override

To lock a diagram (prevent re-generation), copy it from `phase4/auto/` to `phase4/manual/`. Manual SVGs are never overwritten by the agent.

### Rendering guidelines

See `enrichment/resources/guidelines/diagram_creation.md` for the full rendering conventions (colors, layout, fonts, diagram type patterns).

---

## Quality Checklist

See `enrichment/resources/guidelines/userdocs_style.md` for the full pre-submission quality checklist.
