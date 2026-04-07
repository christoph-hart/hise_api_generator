# Forum Code Example Validation — Analysis Session

You are going to analyze HiseScript forum code examples and generate validation metadata so they can be tested against the HISE runtime.

## Context

- The validation pipeline lives in `forum-search/forum_validator.py`
- Raw batch files are in `forum-search/code_examples/batch_*.json` and `snippet_batch_*.json`
- Validated output goes to `forum-search/code_examples/validated/<same filename>`
- HISE is running on `localhost:1900` with a REST API for compilation and REPL evaluation

## Your Task

Process **batch_001.json** (73 examples, indices 15-72 still need analysis; 0-14 are done).

For each example:
1. Read the code and classify it into a testability tier (1-4)
2. Use MCP tools (`query_scripting_api`, `list_module_types`, `list_ui_components`) to look up any unfamiliar HISE APIs
3. Generate a validation JSON object per the schema below
4. Write a JSON file keyed by example index, then apply it:
   ```
   python3 forum_validator.py --apply-metadata batch_001.json <your_metadata_file.json>
   ```
5. Run validation:
   ```
   python3 forum_validator.py --validate --batch batch_001.json --keep-alive
   ```
6. For any failures, analyze the error, fix the metadata, re-apply, and re-validate

## Validation Object Schema

```json
{
  "tier": 1-4,
  "testable": true/false,
  "skipReason": "string or null",
  "setupCode": "string or null",
  "testOnlyCode": "string or null", 
  "verifyScript": [array of checks] or null,
  "notes": "string or null"
}
```

## Tier Classification

- **Tier 1**: Self-contained. No external components or modules needed.
- **Tier 2**: Needs UI components. Code calls `Content.getComponent("Knob1")` etc. Setup must create them.
- **Tier 3**: Needs audio modules + possibly components. Code calls `Synth.getEffect(...)`, `Synth.getSampler(...)` etc.
- **Tier 4**: Untestable. External resources (images via `loadImage`, `Server.*`, `FileSystem.browse` modal dialogs, font files, C++ code). Mark `testable: false`.

## Setup Code Rules

Setup code is **prepended** to the example before compilation:

1. Add `Content.makeFrontInterface(600, 400);` if the example doesn't have it
2. Create components the example references:
   - `Knob*`/`knb*` → `Content.addKnob("name", x, y);`
   - `Button*`/`btn*` → `Content.addButton("name", x, y);`  
   - `Panel*`/`pnl*` → `Content.addPanel("name", x, y);`
   - `Label*`/`lbl*` → `Content.addLabel("name", x, y);`
   - `ComboBox*`/`cmb*` → `Content.addComboBox("name", x, y);`
   - `FloatingTile*`/`ft_*` → `Content.addFloatingTile("name", x, y);`
   - `Image*` → `Content.addImage("name", x, y);`
   - Check `.setPaintRoutine` → Panel, `.addItem` → ComboBox
   - Default to `addKnob` if ambiguous
3. Don't duplicate components the example already creates via `Content.add*`

**For modules** (Tier 3), prefix with `// MODULE_SETUP: ` — the validator splits these into a separate compilation step (modules persist across recompilations, components don't):
```
// MODULE_SETUP: Synth.addEffect("SimpleGain", "Simple Gain1", -1);
Content.makeFrontInterface(600, 400);
Content.addKnob("Knob1", 0, 0);
```

Use MCP tool `list_module_types` to find valid module type strings (e.g., `SimpleGain`, `Delay`, `PolyphonicFilter`).

## REPL Verification

```json
{"type": "REPL", "expression": "variableName", "value": expectedValue, "delay": 0}
```

### CRITICAL: Triggering Callbacks

Control callbacks (`setControlCallback`) are **NOT active during compilation**. Never put `setValue()/changed()` in `testOnlyCode` — it won't trigger anything.

Instead, use a REPL step to trigger, then a subsequent step to verify:
```json
{"type": "REPL", "expression": "MyKnob.setValue(-6.0) || MyKnob.changed()", "value": 0, "delay": 0},
{"type": "REPL", "expression": "targetVariable", "value": -6.0, "delay": 200}
```

The `||` trick: `setValue` and `changed` return undefined/0, so the REPL expression evaluates to 0. The **200ms delay** on the next step is essential — it gives the callback time to fire.

### Other verification types

```json
{"type": "log-output", "values": ["expected", "console", "lines"]}
{"type": "expect-error", "errorMessage": "substring match"}
```

## What NOT to verify via REPL

- LAF/paint routines — compile-only, set `verifyScript: null`
- MIDI callbacks (`function onNoteOn`, `function onController`) — can't trigger via REPL
- Mouse/drag events — can't simulate
- Values depending on unpredictable runtime state (`Math.random`, system time)
- Default knob range is 0.0-1.0 — integer array indexing won't work without reconfiguring the range

## Batch Processing

Work in chunks of ~15 examples. For each chunk:
1. Read the examples from the batch file
2. Generate a metadata JSON (keyed by index)
3. Write to `code_examples/validated/batch_001_metadata_<start>_<end>.json`
4. Apply: `python3 forum_validator.py --apply-metadata batch_001.json <file>`
5. Validate: `python3 forum_validator.py --validate --batch batch_001.json --keep-alive`
6. Check failures and fix

After all examples pass (or are correctly marked as skipped), run coverage:
```
python3 forum_validator.py --coverage --batch batch_001.json
```

## Reference: Validated Examples 0-14

Examples 0-14 are already analyzed and validated (10 passed, 5 skipped). You can inspect them:
```
python3 forum_validator.py --dry-run --batch batch_001.json --index 2
```

Start by reading `forum-search/code_examples/batch_001.json` examples 15 onward.
