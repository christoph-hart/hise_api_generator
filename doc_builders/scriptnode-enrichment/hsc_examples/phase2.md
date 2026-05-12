# HSC Examples Phase 2 - Topology Planning Pass

**Purpose:** Convert approved scenarios into deterministic graph plans. This phase decides the network topology, public parameters, channel assumptions, friction comments, and visual focus before live CLI construction.

**Batch mode:** Horizontal. Process many approved Phase 1 artifacts at once.

**Input:**
- `scriptnode_enrichment/hsc/phase1/{factory}.{node}.md`
- `scriptnode_enrichment/output/{factory}/{node}.md`

**Output:**
- `scriptnode_enrichment/hsc/phase2/{factory}.{node}.md`

**User gate:** The user approves topology, channel assumptions, public controls, and visual focus before live CLI work.

---

## Planning Rules

1. Use `CamelCase` for module IDs.
2. Use `snake_case` for network IDs.
3. Keep the graph minimal. Add only nodes required to demonstrate the target node.
4. Use as many channels as necessary, but only plan non-default routing when it is relevant to the node.
5. Public/root parameters should expose raw target-node values with sensible narrowed ranges.
6. Prefer `connect ... matched` whenever possible. Narrow the target parameter range first if needed.
7. Identify default-value sets that should be omitted from the final command sequence.
8. Identify friction-point comments where the graph design is non-obvious.
9. Plan screenshot cosmetics: main node accent colour, relevant support nodes dim colour, utility nodes folded.

---

## Friction-Point Comment Rules

Phase 2 must identify comments for decisions that are not obvious from commands alone.

Use comments for:
- Non-default host/module routing.
- Non-default channel counts.
- Channel isolation topology such as `container.multi`.
- Sidechain, send/receive, matrix routing, or other topology nodes whose purpose is not visually obvious.
- Public parameter range narrowing before `matched` connections.
- Intentionally empty branches.
- Widened parameter ranges.

Do not comment:
- Obvious parameter values.
- Basic `add` commands unless the node's role is non-obvious.
- Default values that will be intentionally omitted.

---

## Output Format

Write one file per node:

```text
scriptnode_enrichment/hsc/phase2/{factory}.{node}.md
```

Use this exact structure:

```markdown
# {factory}.{node} - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/{factory}.{node}.md`
- Reference: `scriptnode_enrichment/output/{factory}/{node}.md`

## Naming

- Module ID: `{CamelCase}`
- Network ID: `{snake_case}`

## Graph Plan

```text
{root}
  {node tree}
```

## Channel Plan

- Required channels: {description}
- Module routing: {default | matrix}
- Master routing: {default | matrix}
- Channel-specific comments needed: [{comment summary}, ...]

## Public Parameters

- {MacroName} -> {TargetNode}.{Parameter} matched
- Target range before connection: `{range}`
- Macro range: `{range}`
- Default: `{value}`

## Defaults To Omit

- `{Node.Param}` default `{value}`

## Friction Comments To Weave In

- Before `{command/topic}`: {comment text}

## Cosmetic Plan

- Main node: `{NodeId}`
- Accent colour: `0xAARRGGBB`
- Supporting relevant nodes: [`NodeId`, ...]
- Supporting colour: `0xAARRGGBB`
- Folded nodes: [`NodeId`, ...]
- Nodes that must stay visible: [`NodeId`, ...]

## Open Questions

- {question, or "None"}
```

---

## Batch Summary

After writing all artifacts, return a concise table:

```text
factory.node | module/network | channels | public controls | open questions
```

Do not proceed to Phase 3 until the user approves or edits the topology plans.
