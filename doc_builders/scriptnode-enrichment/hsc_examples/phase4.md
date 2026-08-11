# HSC Examples Phase 4 - Public HSC Assembly Pass

**Purpose:** Convert approved Phase 3 construction artifacts into public `.hsc` example scripts. This phase is a deterministic formatting/conversion step and must not reinterpret topology decisions, applied builder setup, or locked build values.

**Batch mode:** Horizontal and stateless. Process many approved Phase 3 artifacts at once.

**Input:**
- `scriptnode_enrichment/hsc/phase3/{factory}/{node}.md`
- `language_enrichment/resources/CLI_GRAMMAR.md`

**Output:**
- `scriptnode_enrichment/hsc/phase4/{factory}/{node}.hsc`

**User gate:** Optional script review. If Phase 3 artifacts are approved, this phase should be mechanical.

---

## Required Reading

Read `language_enrichment/resources/CLI_GRAMMAR.md` once at the start of the batch. Disregard other grammar references.

Use the internal mode grammar, not shell flag syntax:

```text
/hise playground open
/builder
reset
add ScriptFX as "ExampleModule"
set ExampleModule.network "example_network"
/exit

/dsp
cd ExampleModule
add factory.node as "NodeId"
set NodeId.Param 1
create_parameter example_network.Macro [0, 1] default 0 stepSize 0.01
connect example_network.Macro to NodeId.Param matched
/exit
```

---

## Assembly Rules

1. Do not use live HISE unless the user explicitly asks for validation.
2. Treat `Builder Setup Applied` and `Locked Build Values Applied` in the Phase 3 artifact as authoritative context for understanding the command sequence. Do not invent alternatives.
3. Do not reinterpret graph topology, parameter values, comments, cosmetics, applied builder setup, or locked build values.
4. Convert only the approved Phase 3 optimized public shell command sequence.
5. If HSC assembly or validation exposes a HISE or `hise-cli` bug, stop the current node and create a bug report in `scriptnode_enrichment/hsc/issues.md` with a fresh-instance DSL reproduction. Do not rewrite the HSC into a workaround unless the user explicitly approves it after reviewing the bug report.
6. Exclude `save` from public `.hsc`.
7. Exclude `screenshot` from public `.hsc`.
8. Preserve friction-point comments and place them near the relevant commands.
9. Use `add <type> as "Name"` for all creation commands.
10. Use `set X.field value` or `set X.Param.field value` for writes.
11. Use `create_parameter Container.Param [min, max] default D stepSize S` for macro parameters.
12. Use `connect Source.Param to Target.Param matched` whenever Phase 3 says matched was used.
13. Use only `0xAARRGGBB` colour literals.
14. Ensure `scriptnode_enrichment/hsc/phase4/{factory}/` exists before writing `.hsc` files.
15. Enter DSP mode with `/dsp`, then select the host module with `cd <ModuleId>`. Do not emit `/dsp <ModuleId>`.
16. Translate parameter metadata as `.stepSize`, `.middlePosition`, and `.skewFactor`. Do not emit `.step`, `.mid`, or `.skew`.
17. Preserve DSP appearance writes such as `NodeColour`, `Comment`, and `Folded`; these are valid node attributes used for screenshot-focused examples.
18. Run `python scriptnode_enrichment/hsc/resources/hsc_pipeline.py validate-hsc --node {factory.node}` after assembly. Fix all HSC safety issues before Phase 5. The full `validate` command remains required once Phase 5 exists.
19. The first three executable non-comment lines must be exactly `/hise playground open`, `/builder`, and `reset`, in that order. Emit Playground activation exactly once and before every builder or DSP mutation.
20. Never emit a Playground close or disable command in a public `.hsc` script.
21. Preserve approved Interface script initialization blocks for complex-data examples. Use `/script` for the default Interface, `/callback onInit`, the exact HiseScript body, `/compile`, and `/exit` after the DSP graph exists so `Synth.getTableProcessor()` or `Synth.getSliderPackProcessor()` can resolve the host module. Do not use `/script.Interface` in public HSC scripts; the runner expects `/script` for the default processor.

---

## Shell To HSC Mappings

Phase 3 artifacts contain shell-style `hise-cli` commands. Convert them mechanically using these mappings.

Use `Builder Setup Applied` and `Locked Build Values Applied` only to understand why the approved command list looks the way it does. Do not emit separate HSC prose for those sections unless the information already exists as commands or preserved comments in the Phase 3 artifact.

### Builder

```text
hise-cli -hise "playground open" --agent
-> /hise playground open

hise-cli builder reset --agent
-> reset

hise-cli builder add --type T --id ID --agent
-> add T as "ID"

hise-cli builder set --module M --network N --agent
-> set M.network "N"

hise-cli builder set --module M --routing "[0,1]" --agent
-> set M.routing [0, 1]
```

### DSP Entry

```text
hise-cli dsp ... --module M ...
-> /dsp
-> cd M
-> {converted dsp commands}
```

Use one `/dsp` block per module unless comments or command ordering require separate blocks.

### DSP Node Creation

```text
hise-cli dsp add --module M --type factory.node --id ID --agent
-> add factory.node as "ID"

hise-cli dsp add --module M --type factory.node --id ID --parent P --agent
-> add factory.node as "ID" to P
```

### DSP Parameter Writes

```text
hise-cli dsp set --module M --node N --param P --value V --agent
-> set N.P V

hise-cli dsp set --module M --node N --param P --range "a,b" --stepSize S --agent
-> set N.P.range [a, b], N.P.stepSize S

hise-cli dsp set --module M --node N --param P --range "a,b" --middlePosition X --agent
-> set N.P.range [a, b], N.P.middlePosition X

hise-cli dsp set --module M --node N --param P --range "a,b" --skewFactor X --agent
-> set N.P.range [a, b], N.P.skewFactor X
```

### DSP Complex Data

```text
hise-cli dsp set-complex-data --module M --node N --type Table --index I --agent
-> set_complex_data N.Table index I

hise-cli dsp set-complex-data --module M --node N --type SliderPack --index I --agent
-> set_complex_data N.SliderPack index I

hise-cli dsp set-complex-data --module M --node N --type Table --slot S --index I --agent
-> set_complex_data N.Table.S index I
```

Use external indices such as `0` for Table and SliderPack examples that initialize data from Interface `onInit`. Do not convert scripted-initialization examples to embedded `index -1`.

### DSP Macro Parameters And Connections

```text
hise-cli dsp create_parameter --module M --container C --id P --range "a,b" --default D --stepSize S --agent
-> create_parameter C.P [a, b] default D stepSize S

hise-cli dsp connect --module M --source S --source-param P --target T --param Q --matched --agent
-> connect S.P to T.Q matched
```

### DSP Cosmetics

```text
hise-cli dsp set --module M --node N --param NodeColour --value 0xAARRGGBB --agent
-> set N.NodeColour 0xAARRGGBB

hise-cli dsp set --module M --node N --param Comment --value "..." --agent
-> set N.Comment "..."

hise-cli dsp set --module M --node N --param Folded --value true --agent
-> set N.Folded true
```

---

## Public Script Rules

Public `.hsc` files are intended for website users to run interactively.

They must:
- Open the Playground as the first executable line, exactly once.
- Build the example network.
- Include explanatory comments for non-obvious design decisions.
- Avoid writing screenshots or saving files.

They must not:
- Close or disable the Playground.
- Include `save`.
- Include `screenshot`.
- Include failed prototype commands.
- Include CLI-debug comments about tool failures.

---

## Output Format

Write the public script to:

```text
scriptnode_enrichment/hsc/phase4/{factory}/{node}.hsc
```

---

## Batch Summary

After writing all files, return:

```text
factory.node | hsc path | comments preserved | issues
```

If an artifact lacks enough information for deterministic conversion, do not guess. Mark it blocked and ask for Phase 3 clarification.
