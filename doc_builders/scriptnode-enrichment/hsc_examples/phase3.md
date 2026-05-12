# HSC Examples Phase 3 - Stateful Construction Pass

**Purpose:** Build one approved scriptnode example in a live HISE session, verify behaviour, optimize the successful shell `hise-cli` command list, apply comments and cosmetics, and produce the handoff artifact for public `.hsc` assembly.

**Batch mode:** Stateful per node. Do not process large batches in one session. This phase combines live prototyping, command optimization, friction comments, and cosmetics because these steps depend on shared context.

**Input:**
- `scriptnode_enrichment/hsc/phase2/{factory}.{node}.md`
- `scriptnode_enrichment/output/{factory}/{node}.md`
- Live HISE reachable via `hise-cli`

**Output:**
- `scriptnode_enrichment/hsc/phase3/{factory}.{node}.md`

**User gate:** The user approves the live-built network, optimized command list, comments, cosmetics, and screenshot command before Phase 4.

---

## Construction Rules

1. Work one node at a time unless the user explicitly requests a small related batch.
2. Use `hise-cli agent-context` and command-specific help when uncertain.
3. Build incrementally and inspect after meaningful steps with `dsp tree`, `dsp show`, `dsp get`, and `dsp connections`.
4. Capture only successful shell `hise-cli ...` commands for the final artifact. Exclude failed attempts and CLI-fix exploration.
5. Optimize the final command list:
   - Add nodes directly to their final parent.
   - Omit default-value no-ops.
   - Avoid move/reparent commands if direct parent creation is possible.
   - Keep `matched` connections whenever possible.
6. Public/root parameters should expose raw target-node values with sensible narrowed ranges.
7. If using `matched`, narrow the target parameter range before connecting.
8. Use as many channels as required by the node. For most nodes, default stereo should be enough.
9. For channel/routing examples, explicitly verify module routing, master routing, and channel-isolation topology.
10. Do not write HSC mode grammar in this artifact. Phase 4 performs that conversion.
11. Do not put `save` or `screenshot` into the public command list. Keep them under pipeline-only commands.

---

## Cosmetic Rules

1. The demonstrated node gets the accent colour and a concise Markdown comment explaining the project context.
2. Relevant non-utilitarian support nodes get a dim/desaturated colour.
3. Fold all nodes that are not relevant to understanding the demonstrated node.
4. Exception: if the demonstrated node is a control/output node, keep the target node visible if needed to show the cable.
5. Add comments to non-obvious topology containers.
6. Use only `0xAARRGGBB` colour literals.

---

## Friction Comments

During construction, update the Phase 2 friction comments with what actually mattered. These comments must be woven into the final `.hsc` in Phase 4.

Include comments for:
- Host/module routing that differs from defaults.
- Internal channels vs output channels.
- Why a topology node such as `container.multi` is required.
- Why a branch is intentionally empty.
- Why a parameter range is narrowed before `matched`.
- Why a parameter range is widened.

Keep comments short and place them near the relevant command in the final command sequence.

---

## Output Format

Write one file per node:

```text
scriptnode_enrichment/hsc/phase3/{factory}.{node}.md
```

Use this exact structure:

```markdown
# {factory}.{node} - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/{factory}.{node}.md`
- Reference: `scriptnode_enrichment/output/{factory}/{node}.md`

## Status

- Built in HISE: {true|false}
- User approved: {true|false}
- Notes: {brief status}

## Naming

- Module ID: `{CamelCase}`
- Network ID: `{snake_case}`

## Verified Parameters

- `{Node.Param}` = `{value}` range `{min..max}` stepSize `{stepSize}`

## Verified Connections

- `{Source.Param}` -> `{Target.Param}` matched: {true|false}

## Optimized Public Shell Commands

These shell `hise-cli` commands are intended for Phase 4 conversion to public `.hsc`. They must not include `save` or `screenshot`.

```bash
{hise-cli builder ...}
{hise-cli dsp ...}
```

## Pipeline-Only Commands

These commands are not included in public `.hsc`.

```bash
hise-cli dsp save --module {ModuleId} --agent
hise-cli dsp screenshot --module {ModuleId} --scale 200% --output "scriptnode_enrichment/hsc/phase5/{factory}/{node}.png" --agent
```

## Comments To Preserve In HSC

- Before `{command/topic}`: {comment text}

## Cosmetics Applied

- Main node: `{NodeId}` colour `0xAARRGGBB`
- Support nodes: [`NodeId`, ...] colour `0xAARRGGBB`
- Folded nodes: [`NodeId`, ...]
- Visible target nodes: [`NodeId`, ...]

## Defaults Omitted

- `{Node.Param}` default `{value}`

## Open Issues

- {issue, or "None"}
```

---

## Final Response

Return:
- The optimized public command sequence summary.
- Any pipeline-only commands.
- Any unresolved issues.
- Whether the user must approve before Phase 4.
