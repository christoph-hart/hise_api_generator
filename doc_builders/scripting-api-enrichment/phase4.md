# Phase 4: User-Facing Documentation Authoring -- Agent Instructions

Phase 4 transforms the raw C++ analysis from Phases 1-3 into user-facing documentation for HISEScript developers. The agent reads the complete merged `api_reference.json` for a single class and produces `userDocs` content for the class overview and each method. Phase 4 also renders SVG diagrams for methods/classes that have a `diagram` specification.

**Audience:** HISEScript developers who have no knowledge of C++ internals. They want to know what a method does, how to use it, and what to watch out for.

**ASCII-only rule:** All output files must use ASCII characters only. Use `--` instead of em-dashes, straight quotes instead of curly quotes.

**Phase 3 priority:** When Phase 3 raw docs already provide `userDocs` for a method, Phase 4 auto does NOT overwrite it. Phase 4 only generates `userDocs` for methods without Phase 3 coverage. Phase 4 manual overrides everything.

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
- `diagram` -- diagram specification (if present): `type` + `description`

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
```

The `# ClassName` heading is required. The content below it should be concise and scannable -- no subheadings, but markdown tables and bullet lists are allowed when they improve readability (e.g. a table showing distinct modes or a short list of method groups). Target a length between the Phase 1 `purpose` and `details` -- substantial enough to orient a scripter, but with all C++ internals stripped.

### Method-level: `phase4/auto/ClassName/methodName.md`

```
[1-3 sentences describing what this method does and how to use it.
No heading required -- the method name is inferred from the filename.]
```

Bare prose, no heading, no structured fields. Just the user-facing description.

---

## Authoring Guidelines

See `enrichment/resources/guidelines/userdocs_style.md` for the complete prose writing rules, including what to include, what to strip (C++ internals, preprocessor guards, implementation details), tone, length, class-level deduplication, formatting conventions, and reference examples.

---

## Workflow

### Per-class execution

The agent runs once per class. **Diagrams are rendered first**, then userDocs are written -- this allows the `.md` files to embed or link to diagram SVGs.

1. Read the merged `api_reference.json`
2. Extract the target class entry
3. **Triage diagrams** (see Diagram Triage below):
   - Review all diagram descriptions from Phase 1 (class-level `diagrams[]` and method-level `diagram` fields)
   - For each diagram, decide: render as SVG, or cut in favor of prose/tables
   - Diagrams that survive triage proceed to rendering; cut diagrams are simply not rendered (the text description remains in the JSON for LLM consumers)
4. **Render surviving SVG diagrams** (see Diagram SVG Rendering below):
   - For each class-level diagram that survived triage, render an SVG
   - For each method diagram that survived triage, render an SVG
   - Skip if a manual or auto SVG already exists
5. Write class-level `Readme.md`:
   - Check `phase4/manual/ClassName/Readme.md` -- if present, skip
   - Check if class already has `userDocs` from Phase 3 -- if so, skip
   - Check `phase4/auto/ClassName/Readme.md` -- if present, skip
   - Write `Readme.md` with user-facing prose; **embed class-level diagram SVGs** as `![brief](filename.svg)` (see Embedding Diagrams below)
   - If a diagram was cut during triage because a table or prose covers the same information better, use that table/prose instead -- do not reference the cut diagram
6. Write method-level `.md` files:
   - Check `phase4/manual/ClassName/methodName.md` -- if present, skip
   - Check if the method already has `userDocs` from Phase 3 -- if so, skip
   - Check `phase4/auto/ClassName/methodName.md` -- if present, skip
   - Write `methodName.md` with user-facing prose
   - If the method has a `diagram` field that survived triage, embed the SVG as `![brief](filename.svg)`
   - If the method has a `diagramRef` field pointing to a rendered class-level diagram, link to the anchor: `[See: brief](#diagram-id)`
   - If the method's diagram or diagramRef was cut during triage, do not reference it

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
