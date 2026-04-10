---
name: update-forum
description: "Forum enrichment pipeline: search HISE forum, extract insights, distribute to documentation pages. Supports modules, scriptnode, and scripting API. Use when asked to enrich targets with forum data."
argument-hint: <scope:target> [scope:target ...]
allowed-tools: Read Write Edit Grep Glob Bash Agent
model: claude-opus-4-6
---

# Forum Enrichment Agent

You enrich HISE documentation pages with forum-derived insights. Full pipeline: search -> extract -> verify -> distribute -> validate.

## Invocation

The user tells you what to enrich via arguments. Examples:

- `/update-forum modules:SynthGroup`
- `/update-forum modules:Delay modules:PolyphonicFilter`
- `/update-forum scriptnode:fx.reverb`
- `/update-forum api:ScriptPanel`
- `/update-forum ui:PresetBrowser`
- `/update-forum language:css`

Process each target sequentially.

## Paths

All paths relative to `HISE/tools/api generator/`.

| Domain | Scope | Page | Exploration | Insights out |
|--------|-------|------|-------------|-------------|
| modules | `modules:{Id}` | `module_enrichment/pages/{Id}.md` | `module_enrichment/exploration/{Id}.md` | `module_enrichment/forum/insights/{Id}.json` |
| scriptnode | `scriptnode:{Id}` | `scriptnode_enrichment/output/{cat}/{Id}.md` | `scriptnode_enrichment/exploration/{Id}.md` | `scriptnode_enrichment/forum/insights/{Id}.json` |
| api | `api:{Id}` | `enrichment/phase4/auto/{Id}/Readme.md` | `enrichment/phase1/{Id}/Readme.md` | `enrichment/forum/insights/{Id}.json` |
| ui | `ui:{Id}` | `ui_enrichment/pages/components/{Id}.md` or `ui_enrichment/pages/floating-tiles/{Id}.md` | (none) | `ui_enrichment/forum/insights/{Id}.json` |
| language | `language:{Id}` | `language_enrichment/output/{Id}.md` | (none) | `language_enrichment/forum/insights/{Id}.json` |

## Pipeline

### 1. Forum Search

Generate search terms from the target name and run:

```bash
cd "HISE/tools/api generator/forum-search"
python forum-search.py update "{Name}" --also "{alt1}" "{alt2}" --scope {domain}:{Id}
```

Generate `--also` terms intelligently:
- Modules: include purpose words (e.g., SynthGroup --also "Synthesiser Group" "unison" "FM synthesis")
- Scriptnode: include node path AND common name
- API: include key method names users ask about; add `--include-features`

The script filters by title relevance, signal score, and post quality automatically. If the output file exceeds 400KB, refine your search terms.

### 2. Read Existing Data

Before extraction, **actually read** (not just reference) these files:
- `style-guide/general.md` - writing rules. All prose you write must follow these. Key rule: no C++ class names, preprocessor guards, or implementation internals in user-facing text.
- The target page (see Paths table)
- `module_enrichment/issues.md` (for modules - lists known bugs and vestigial parameters)
- The exploration file (see Paths table)

### 3. Extract Insights

Use the **Agent tool** to spawn a sonnet-model subagent for extraction. The agent reads its own instructions from the AGENT.md file. Run in **insights mode only** (skip questions mode - it produces redundant output for already-enriched targets):

```
Agent({
  description: "Extract {Name} forum insights",
  model: "sonnet",
  prompt: "Read your instructions from D:/Development/Projekte/hise_project_analysis/HISE/tools/api generator/.claude/agents/extract-forum-insights/AGENT.md and follow them exactly.\n\nMODE: insights\nTARGET: {Name}\nSCOPE: {domain}:{Id}\nINPUT: {full path to forum_cache/{domain}_{Id}.json}\nOUTPUT: {full path to insights output}\nEXPLORATION: {full path to exploration file}\nEXISTING: {list key facts already documented on the page, so the agent skips them}"
})
```

If the agent can't write the output file, write it yourself from the returned JSON.

For **api** targets only, also run examples mode:
```bash
python forum-search.py extract-code --scope api:{Id}
```
Then spawn the agent again with `MODE: examples`.

### 4. Verify

For each insight with `verify: true`:
1. Check the exploration file you already read in Step 2 - does it already confirm or deny the claim?
2. Check `issues.md` you already read in Step 2 - is this already a tracked bug?
3. If neither source answers: use the **Agent tool** to spawn a haiku-model subagent for verification. Do NOT verify claims yourself by reading C++ source - the verify agent uses a cheaper model and is purpose-built for this.

```
Agent({
  description: "Verify: {short claim summary}",
  model: "haiku",
  prompt: "Read your instructions from D:/Development/Projekte/hise_project_analysis/HISE/tools/api generator/.claude/agents/verify-forum-claim/AGENT.md and follow them exactly.\n\nCLAIM: {the claim}\nSEARCH_HINTS: {grep terms, file paths}\nCONTEXT: {source tid, username, date if known}"
})
```

### 5. Distribute

Follow `style-guide/forum-distribution-guide.md`. For each insight, classify as:

- **A. Parameter hint** - add `hints` array to the parameter table row
- **B. Notes prose** - weave into existing Notes section
- **C. commonMistakes** - add to frontmatter (every entry MUST have a `title` field). Use exactly 2-space indent for `- title:` and 4-space for `wrong:`, `right:`, `explanation:` - match the existing entries in the file
- **D. Cross-domain** - write to the target file FIRST, then add See Also link. For Scripting API targets, dual-write to both `enrichment/phase4/auto/{Class}/` and `enrichment/phase4b/{Class}/`
- **E. Skip** - feature requests, already documented, too general
- **F. Bug/issue** - missing validation, missing bounds checks, trivially fixable code bugs. Write these to `module_enrichment/issues.md` (not to user-facing docs). Do NOT tell users to work around bugs that should be fixed in code.

Skip insights that are already covered by the existing page content.

### 6. Update llmRef

Update the `llmRef` field in the page frontmatter to reflect new content.

### 7. Restructure Notes

After distribution, review the Notes section. Move each paragraph to a better location:

- **Already in parameter table or commonMistakes** - remove (don't duplicate)
- **Module identity** (what it is/isn't, fundamental characteristics) - merge into the intro paragraphs
- **Setup/placement requirements** - new `###` subsection in top prose (before Signal Path)
- **Behavioural details** (sync, crossfade, rendering) - new `###` subsection by topic or extend related intro paragraph
- **Timing/limits/edge cases** - new `### Limitations` or similar subsection
- **Workflow patterns** (workarounds, scripting tips) - new `###` subsection by topic
- **Initialisation quirks** (minor, one-sentence) - tuck into intro prose

Goal: eliminate the `## Notes` section entirely. Every paragraph becomes either part of the intro prose, a named `###` subsection, or is removed as redundant.

### 8. Forum Reference Citations

After distribution and Notes restructuring, select the 2-3 most citation-worthy insights for the page. Not every insight deserves a citation — pick only those where provenance adds value:

**Citation-worthy:** Non-obvious gotchas, confirmed behavioral quirks, practical workarounds sourced from real user experience.

**Skip:** General API knowledge, information already confirmed via C++ exploration, bugs moved to issues.md, feature requests.

For each selected insight:

A. Add a `forumReferences` entry to the YAML frontmatter (after `commonMistakes`, before `customEquivalent`):

```yaml
forumReferences:
  - id: 1
    title: "Short insight title"
    summary: "One-sentence summary of the finding"
    topic: 2054
  - id: 2
    title: "..."
    summary: "..."
    topic: 7006
```

B. Place an inline citation in the page body where the insight's content appears: `[1]($FORUM_REF.2054$)`

The `[N]` number is sequential per page (1, 2, 3). The `$FORUM_REF.{tid}$` token contains the actual forum topic ID — `publish.py` resolves it to `https://forum.hise.audio/topic/{tid}`. The Nuxt.js renderer auto-injects a `::forum-references` component from the frontmatter data.

Rules:
- Maximum 2-3 citations per page
- Place citations at the end of the sentence/paragraph where the insight content appears
- Only cite in body prose, parameter hints, or modulation chain descriptions — NOT in frontmatter-only fields (commonMistakes, llmRef)
- If an insight's content doesn't appear in the page body, don't force a citation — skip it
- If no insights are citation-worthy, omit `forumReferences` entirely (no empty array)

### 9. Validate

```bash
cd "HISE/tools/api generator"
python publish.py "D:/Development/Projekte/hise_website_v2/content/v2"
```

Confirm 0 errors. Warnings about missing images are expected and unrelated.

## Rules

- Follow `style-guide/general.md` for all prose. No C++ class names, preprocessor guards, or implementation details in user-facing text.
- Read the target page and exploration data BEFORE spawning any extraction or verification agents.
- Do NOT run questions mode (`MODE: questions`) for already-enriched targets. It duplicates insights.
- Generate search terms thoughtfully. Short/generic names (Delay, Chorus) need specific `--also` terms.
- Cross-domain writes: always write the target file first, then update the source page's See Also.
- Process targets sequentially (forum API rate limiting).
