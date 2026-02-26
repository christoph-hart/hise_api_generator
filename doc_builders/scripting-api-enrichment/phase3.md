# Phase 3: Manual Markdown Overrides

Phase 3 is the highest-priority layer. It provides manually authored or edited documentation that overrides all prior phases. This is the final editorial pass.

---

## Source Directory

```
enrichment/phase3/ClassName/Readme.md        # Class-level overrides
enrichment/phase3/ClassName/methodName.md    # Method-specific overrides
```

The folder structure mirrors Phase 1. Using `Readme.md` for class-level overrides allows directly pulling in existing documentation from docs.hise.dev, which uses the same filename convention.

---

## Class-Level Override Format

`enrichment/phase3/ClassName/Readme.md` uses the same format as Phase 1's Readme.md:

```markdown
# ClassName -- Class Analysis

## Brief
~10-15 words. Search-optimized summary.

## Purpose
2-5 sentences. Concise technical summary.

## Details
Full structured technical reference.
(Omit to keep Phase 1's details unchanged.)

## obtainedVia
`Engine.createSomething()`

## Constants
| Name | Value | Type | Description | Group |
|------|-------|------|-------------|-------|
| ... | ... | ... | ... | ... |

## Dynamic Constants
| Name | Type | Description |
|------|------|-------------|
| ... | ... | ... |

## Common Mistakes
| Wrong | Right | Explanation |
|-------|-------|-------------|
| ... | ... | ... |

## codeExample
```javascript
// Manually crafted usage example
```

## Alternatives
Related classes, or "None."

## Related Preprocessors
`USE_BACKEND`, etc. -- or "None."
```

All sections are optional -- only include sections you want to override.

---

## Method Override Format

`enrichment/phase3/ClassName/methodName.md` uses the same format as Phase 1's method entries:

```markdown
## methodName

**Signature:** `returnType methodName(Type1 param1, Type2 param2)`
**Return Type:** `String`
**Call Scope:** safe | warning | unsafe | init | unknown
**Call Scope Note:** (optional -- explanation for warning tier or non-obvious classification)

**Description:**
Manually written description overriding Phase 1.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| param1 | Number | yes | Corrected description | 0-127 |

**Pitfalls:**
- A manually documented gotcha.

**Cross References:**
- `OtherClass.relatedMethod`

**Example:**
```javascript
// Manually crafted example
```
```

All fields are optional -- only include fields you want to override.

---

## Raw Docs Format

Phase 3 also accepts unstructured markdown files from the existing docs.hise.dev documentation. When a method file does NOT contain structured markers (`**Signature:**`, `**Description:**`, etc.), the parser treats it as **raw docs** and splits it automatically.

### Splitting Rules

- **Prose** (everything outside code fences) -> `userDocs` field (tagged as manual-grade)
- **Code fences** -> `examples` array entries (tagged `"source": "manual"`)
- **Prose only** (no code fences) -> `userDocs` only, no `examples`
- **Code fences only** (no prose) -> `examples` only, no `userDocs`

The raw docs `userDocs` does NOT overwrite the Phase 1 technical `description` field. They serve different audiences: `description` is for LLMs/MCP consumers, `userDocs` is for human readers on the docs website.

### Link Conversion

Inline links to other API methods are converted to backtick references in the prose and extracted as `crossReferences`:

| Input | Output in prose | crossReference added |
|---|---|---|
| `[Array.push](/scripting/scripting-api/array#push)` | `` `Array.push()` `` | `"Array.push"` |
| `[Buffer](/scripting/scripting-api/buffer)` | `` `Buffer` `` | -- (class-level, no method) |
| `[text](/scriptnode/...)` | stripped | -- (non-API link) |
| `![](/images/...)` | stripped | -- (image reference) |

Link-to-class/method name resolution uses a case-insensitive lookup against the known classes and methods from the base JSON.

### Preserved Elements

- **Blockquotes** (`> Note that...`) -- preserved as-is in `userDocs` (contain valuable caveats)
- **Tables** (`| Column | ... |`) -- preserved as-is in `userDocs` (e.g. value mode tables)
- **Bold/italic** and other inline formatting -- preserved

### Stripped Elements

- **`#### Example` headings** -- removed (the code block is extracted to `examples`)
- **Image references** (`![alt](/path)`) -- removed entirely
- **Non-API links** (anything not matching `/scripting/scripting-api/...`) -- link markup removed, link text preserved

### userDocs Priority

When Phase 3 raw docs provide a `userDocs` value, it follows this priority in the merge:

**Phase 4 manual > Phase 3 raw docs > Phase 4 auto**

This means:
- Phase 3 raw docs `userDocs` overrides Phase 4 auto-generated prose
- Phase 4 manual overrides everything (for human corrections)
- Phase 4 auto is the fallback for methods without Phase 3 coverage

### Example

Given this raw docs file (`phase3/Array/clone.md`):

```markdown
If you assign an array reference to another variable, you're only setting the
reference. Use [Array.clone()](/scripting/scripting-api/array#clone) to create
an independent copy.

> Note: this also works with JSON objects and component references.

```javascript
const arr1 = [0, 1];
var arr2 = arr1;
arr2[0] = 22;
Console.print(trace(arr1)); // [22, 1]
```
```

The parser produces:
- `userDocs`: `"If you assign an array reference to another variable, you're only setting the reference. Use \`Array.clone()\` to create an independent copy.\n\n> Note: this also works with JSON objects and component references."`
- `examples`: `[{ title: "clone", code: "const arr1 = ...", source: "manual" }]`
- `crossReferences`: `["Array.clone"]`

---

## Merge Rules

### Class-Level Fields (Last-Writer-Wins)

Phase 3 overrides all prior phases for these fields:

| Field | Merge Behavior |
|-------|---------------|
| `description.brief` | Replaces Phase 1 value |
| `description.purpose` | Replaces Phase 1 value |
| `description.details` | Replaces Phase 1 value |
| `description.obtainedVia` | Replaces Phase 1 value |
| `description.codeExample` | Replaces Phase 1 value |
| `description.alternatives` | Replaces Phase 1 value |
| `description.relatedPreprocessors` | Replaces Phase 1 value |
| `description.diagram` | Replaces Phase 1 value (entire object) |
| `constants.*` | Last-writer-wins per constant |
| `dynamicConstants.*` | Last-writer-wins per constant |

### Class-Level Fields (Merged Union)

| Field | Merge Behavior | Tag |
|-------|---------------|-----|
| `commonMistakes` | Added to Phase 1 + Phase 2 entries | `"manual"` |

### Method-Level Fields (Last-Writer-Wins)

| Field | Merge Behavior |
|-------|---------------|
| `description` | Replaces all prior |
| `signature` | Replaces all prior |
| `returnType` | Replaces all prior |
| `parameters` | Replaces all prior |
| `callScope` | Replaces all prior |
| `callScopeNote` | Replaces all prior |
| `examples` | **Entire array replaced** |
| `userDocs` | See userDocs Priority above |
| `diagram` | Replaces all prior (entire object) |

### Method-Level Fields (Merged Union)

| Field | Merge Behavior | Tag |
|-------|---------------|-----|
| `pitfalls` | Added to Phase 1 + Phase 2 entries | `"manual"` |
| `crossReferences` | Merged, deduplicated | -- |

### Source Tags

All Phase 3 contributions are tagged with `"source": "manual"`:

```json
{
  "pitfalls": [
    { "description": "...", "source": "auto" },
    { "description": "...", "source": "project" },
    { "description": "Manually added note.", "source": "manual" }
  ]
}
```

---

## Common Workflows

### 1. Edit Phase 1 Output for Clarity

```
1. Copy enrichment/phase1/Broadcaster/Readme.md
      → enrichment/phase3/Broadcaster/Readme.md
2. Edit for clarity, fix errors, add detail
3. Run: python api_enrich.py merge
```

### 2. Import Existing docs.hise.dev Class Documentation

```
1. Copy the markdown source from docs.hise.dev for the class
      → enrichment/phase3/ClassName/Readme.md
2. Ensure the section headings match the template format
3. Run: python api_enrich.py merge
```

### 3. Import docs.hise.dev Method Pages (Raw Docs)

```
1. Copy the method page markdown from docs.hise.dev
      → enrichment/phase3/ClassName/methodName.md
2. No reformatting needed -- prose becomes userDocs, code blocks become examples
3. Doc-site links are auto-converted to cross-references
4. Run: python api_enrich.py merge
```

### 4. Override a Specific Method

```
1. Create enrichment/phase3/ClassName/methodName.md
2. Write only the fields you want to override
3. Run: python api_enrich.py merge
```

### 4. Add a Common Mistake

```
1. Edit enrichment/phase3/ClassName/Readme.md
2. Add a row to the ## Common Mistakes table
3. Run: python api_enrich.py merge
   (The new mistake is ADDED to existing ones, not replacing them)
```
