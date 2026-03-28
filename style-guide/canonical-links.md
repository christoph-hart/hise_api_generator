# Canonical Links, Warnings, Tips, and Common Mistakes

**Single source of truth** for cross-reference syntax, warning/tip formatting, and common mistake structure across all HISE documentation pipelines.

All markdown source files (scripting API enrichment, module reference pages, architecture docs) use the formats described here. The `publish.py` script resolves link tokens and converts everything to Nuxt.js MDC components.

---

## 1. Cross-Reference Links

### Link token syntax

Use `$DOMAIN.Target#fragment$` tokens. These are resolved by `publish.py` to final URLs with fuzzy matching and validation.

| Domain | Target format | Example |
|--------|--------------|---------|
| `$API.ClassName$` | Scripting API class | `$API.Effect$` |
| `$API.ClassName.method$` | Scripting API method | `$API.Effect.setBypassed$` |
| `$MODULES.ModuleId$` | Audio module (ID from moduleList.json) | `$MODULES.Convolution$` |
| `$MODULES.ModuleId.ParamId$` | Module parameter | `$MODULES.AHDSR.Attack$` |
| `$UI.Components.Name$` | UI component reference | `$UI.Components.ScriptSlider$` |
| `$UI.FloatingTiles.Name$` | FloatingTile reference | `$UI.FloatingTiles.PresetBrowser$` |
| `$SN.factory.node$` | Scriptnode node | `$SN.math.add$` |
| `$DOC.Section.Page$` | Manual/architecture docs | `$DOC.Architecture.ModuleTree$` |

### Resolution cascade

The publish script resolves tokens in this order:

1. **Exact match** - silent
2. **Case-insensitive** - INFO message (e.g., `$API.transporthandler$` -> `TransportHandler`)
3. **Normalized** (strip dashes/underscores) - INFO message (e.g., `$DOC.Architecture.DataModel$` matches `data-model`)
4. **Fuzzy** (difflib, >0.6 similarity) - WARN message (e.g., `$MODULES.PhaseFX$` -> `Phaser`)
5. **No match** - ERROR (fails build in `--strict` mode)

### In-prose links

Use standard markdown link syntax with tokens as the URL:

```markdown
This module works with the [Global Envelope Modulator]($MODULES.GlobalEnvelopeModulator$) to provide...

Use [Effect.setBypassed]($API.Effect.setBypassed$) to toggle the effect from script.

See the [module tree architecture]($DOC.Architecture.ModuleTree$) for an overview.
```

### See-also references

Use the `**See also:**` format. Entries are comma-separated, with optional `--` descriptions:

```markdown
**See also:** $API.Effect.setBypassed$ -- scripting API for bypass, $MODULES.Convolution$ -- convolution reverb module
```

The publish script converts this to `::see-also` MDC components with proper URLs.

### Where to write cross-references

| Content domain | Source file | Format |
|---------------|-----------|--------|
| API method see-also | `enrichment/phase1/{ClassName}/methods.md` | `**Cross References:**` bullet list: `- \`$API.Target$\`` |
| API in-prose links | `enrichment/phase4/auto/{ClassName}/*.md` | `[text]($DOMAIN.Target$)` inline |
| Module see-also | `module_enrichment/pages/{ModuleId}.md` | `**See also:** $DOMAIN.Target$ -- desc` |
| Module in-prose links | `module_enrichment/pages/{ModuleId}.md` | `[text]($DOMAIN.Target$)` inline |
| Architecture/guide | `content/v2/architecture/*.md`, `content/v2/guide/*.md` | `[text]($DOMAIN.Target$)` inline |

---

## 2. Warnings

Warnings highlight common pitfalls or non-obvious gotchas. Use the titled blockquote format:

```markdown
> [!Warning:Enable grid before registering callbacks] The grid must be enabled via setEnableGrid() before grid callbacks fire. Without it, the callback is registered but never triggered.
```

**Title guidelines:**
- 3-8 words, action-oriented
- Describes the problem or the correct action concisely
- Examples: "Prefetch component references", "Use inline functions for sync callbacks", "Stop clock before preset load"

The publish script converts this to:

```markdown
::warning{title="Enable grid before registering callbacks"}
The grid must be enabled via setEnableGrid() before grid callbacks fire.
::
```

**Legacy format** (`> **Warning:** text`) is still supported but produces untitled warnings.

**Placeholder:** During backport migration, untitled warnings use `> [!Warning:$WARNING_TO_BE_REPLACED$] text`. The publish script emits an INFO message for these so they can be found and titled.

---

## 3. Tips

Tips highlight best practices or useful shortcuts. Same syntax as warnings:

```markdown
> [!Tip:Store references in onInit] Effect references can only be obtained during onInit via Synth.getEffect(). Store them as const var at the top level.
```

Converts to `::tip{title="Store references in onInit"}`.

**Legacy format** (plain `> blockquote` before `## Methods`) is still supported but produces untitled tips.

**Placeholder:** `> [!Tip:$TIP_TO_BE_REPLACED$] text` for backport migration.

---

## 4. Common Mistakes

Common mistakes appear in class-level Readme.md files (phase4a for API, frontmatter for modules). Each entry has a title, wrong pattern, right pattern, and explanation:

```markdown
## Common Mistakes

- **Prefetch component references**
  **Wrong:** `const var fx = Synth.getEffect("MyFX");` in `onNoteOn`
  **Right:** `const var fx = Synth.getEffect("MyFX");` in `onInit`
  *Synth.getEffect() can only be called during initialisation. Store the reference as a top-level const.*

- **Use named constants for parameters**
  **Wrong:** `fx.setAttribute(0, 1000.0)` using raw integer indices
  **Right:** `fx.setAttribute(fx.Frequency, 1000.0)` using named constants
  *Named constants are generated per effect type. They make code self-documenting and survive parameter reordering.*
```

The publish script converts this to `::common-mistakes` MDC with a `title` field per entry.

**Placeholder:** During backport, untitled entries use `**$COMMON_MISTAKE_TITLE_TO_BE_REPLACED$**` as the title line.

---

## 5. Forum Community Insights

Forum community insights enrich documentation pages with real-world usage patterns, recurring gotchas, and best practices gathered from the HISE forum. This step converts collective community knowledge into Warning and Tip blocks scattered throughout reference pages.

### When to use

As a post-authoring enrichment pass after the initial reference page is written and source completeness has been verified. Applicable to any documentation pipeline (UI components, modules, scripting API), not just UI component enrichment.

### Forum API

The HISE forum (NodeBB) exposes a REST API for searching posts:

```
https://forum.hise.audio/api/search?term={query}&in=titlesposts&sortBy=relevance
```

Returns JSON with `posts[]` containing `content` (HTML), `tid` (topic ID), `topic.title`, `topic.postcount`, and `user.username`. High reply counts indicate widespread confusion or active discussion.

### Query strategy

Run 2-3 searches per component/module/class:

1. **Exact name** — e.g., `ScriptSliderPack`, `AHDSR`
2. **Natural description** — e.g., `table curve editor`, `knob filmstrip`, `preset browser`
3. **Feature-specific** — e.g., `sliderpack callback value index`, `table mouse wheel curve`

### Signal detection

Focus on:
- **Threads with many replies** (10+ posts) — indicates widespread confusion or a nuanced topic
- **Bug reports** revealing non-obvious but intended behaviour
- **Repeated questions** across multiple threads about the same topic
- **Best practices** and clever patterns shared by experienced users (David Healey, Christoph Hart, etc.)

### Output format

| Block type | Use for | Syntax |
|-----------|---------|--------|
| `> [!Warning:title]` | Pitfalls, gotchas, non-obvious behaviour that causes bugs | See § 2 above |
| `> [!Tip:title]` | Best practices, recommended patterns, useful shortcuts | See § 3 above |
| `commonMistakes` (YAML) | Clear wrong/right patterns with explanation | See § 4 above |

### Balance and tone

**Aim for a roughly even mix of Warnings and Tips.** A page with only warnings reads as a minefield — every pitfall has a positive angle that can be framed as a Tip instead. Ask yourself:

- "Users keep making this mistake" → **Warning** (if the consequence is a hard-to-debug issue)
- "Users keep asking how to do this" → **Tip** (the answer is a best practice worth highlighting)
- "This pattern works really well" → **Tip** (a recommended approach from community experience)
- "This silent failure wastes debugging time" → **Warning** (non-obvious gotcha)

### Placement rules

1. **Scatter throughout the page** — place each block adjacent to the property, section, or code example it relates to
2. **Maximum one styled block per page section** — avoid clustering multiple warnings/tips together, which trains readers to skip them
3. **Target 3-5 new blocks per page** — enough to add real value without overwhelming the reference content

### Filtering

- **Skip** content already documented in Notes, commonMistakes, or property descriptions
- **Skip** historical bugs that have been fixed in current HISE versions
- **Skip** feature requests and wishlists — only document current behaviour
- **Focus** on behaviour that is still current and non-obvious from the API surface alone

---

## Validation

Run the publish script to validate all tokens:

```bash
python publish.py --dry-run          # default: warn on broken links
python publish.py --dry-run --strict # CI: fail on broken links
```

- Unresolved `$DOMAIN$` tokens appear as ERROR
- Fuzzy-corrected tokens appear as WARN/INFO
- Untitled warnings/tips/mistakes appear as INFO
