# Test Metadata Authoring Guidelines

Authoritative reference for writing `testMetadata` to validate API documentation examples. The validator executes examples via the HISE REST API and checks results.

---

## When to Mark Examples as Testable

### Mark `testable: true` when:
- Example is complete, executable HISEScript code
- Example has deterministic output (no randomness, no external dependencies)
- Configuration methods can be completed with minimal setup chains
- Example does NOT require file I/O, user interaction (MIDI, mouse), timers/async callbacks, or external audio samples

### Mark `testable: false` when:
- Pseudo-code or signature templates
- Examples requiring file I/O, MIDI input, or timers
- Partial snippets that cannot be completed with trivial additions
- Non-deterministic output (e.g., `Math.random()`)

### Completing Partial Examples

If an example is missing only trivial additions, complete it before adding metadata. Use `--edit` to update example code (see CLI Reference below).

**Complete if missing:** simple variable definitions, function invocation calls, trivial constants.

**Mark `testable: false` if missing:** external resources (audio files, MIDI controllers, file system), complex setup that changes the example's purpose, business logic that's intentionally abstracted, dependencies that CANNOT be created via API.

### Module/UI References vs. External Dependencies

**Common mistake:** Seeing a module or UI component reference and marking `testable: false`.

| Resource type | Where to create | Why |
|--------------|----------------|-----|
| **UI components** (`Content.add*()`) | Inline setup block | Environment setup |
| **Modules** (Builder API) | Inline setup block | Environment setup |
| **Broadcasters** | Example code | Subject of the example, not setup |
| **Cables** | Example code | Should show full acquisition pattern |
| **External files, MIDI, hardware** | Cannot create | Mark `testable: false` |

### Callback Testability: Programmatic Triggers

**Common mistake:** Seeing a callback registration and marking `testable: false` because the callback "needs" external input.

The real question: **Can I trigger this callback from script?** If yes, the example is testable. Sync vs. async dispatch is irrelevant for REPL verification - by the time REPL runs, all async callbacks have completed.

**Prefer natural API triggers** over `Console.testCallback`. If a callback can be invoked through normal API calls, use those - they test the real code path.

| Callback / state | Programmatic trigger | Verify with |
|-----------------|---------------------|-------------|
| Transport change | `startInternalClock(0)` / `stopInternalClock(0)` | REPL: callback log or `th.isPlaying()` |
| Tempo change | `Engine.setHostBpm(newValue)` | REPL: callback log |
| Grid configuration | `setEnableGrid(true, tempoFactor)` | REPL: `th.getGridLengthInSamples()` |
| Broadcaster listeners | `bc.sendSyncMessage([...])` | REPL: listener side-effects |
| Control callbacks | `component.setValue(x); component.changed()` | REPL: callback log or component state |
| Key press callbacks | `Console.testCallback(component, "setKeyPressCallback", eventObj)` | REPL: callback side-effects |
| Panel mouse callbacks | `Console.testCallback(panel, "setMouseCallback", eventObj)` | REPL: `panel.data` or callback side-effects |

`Console.testCallback` synchronously invokes a registered callback with a predetermined argument object. It supports a limited set of callback types per component - check the component's `testCallback` override in `ScriptingApiContent.h` for what's available. Where supported, it validates the argument against the component's configuration (e.g., checks `allowCallbacks` level for mouse events, rejects invalid JSON properties).

For `setControlCallback`, prefer the natural trigger (`setValue() + changed()`) since it tests the real dispatch path. Use `Console.testCallback` only when no natural trigger exists (key press, mouse events).

> If you discover a new programmatic trigger for a callback type not listed here, add it to this table.

Mark `testable: false` only when there is truly no scriptable trigger: bypass detection (watchdog-based), audio playback tick callbacks (`setOnBeatChange`, `setOnGridChange`), DAW time signature changes, table interaction callbacks (click, selection, slider/button/combobox cell events), or hardware interaction.

---

## Markdown Source Format

Test metadata lives in phase `.md` source files. The validator reads these directly -- no intermediate JSON step.

### File Locations

| `--source` | Phase | Path pattern |
|------------|-------|-------------|
| `auto` | Phase 1 | `enrichment/phase1/{Class}/methods.md` (PascalCase dir, `## method` headings) |
| `project` | Phase 2 | `enrichment/phase2/{Class}/{method}.md` (PascalCase dir, camelCase file) |
| `manual` | Phase 3 | `enrichment/phase3/{class}/{method}.md` (all lowercase) |

Directory lookups are case-insensitive.

### Format Elements

**Slugs** -- kebab-case identifier on the code fence, unique per method per phase:
````markdown
```javascript:my-example-slug
// code here
```
````

**Inline titles** -- `// Title:` as first line (stripped before execution, preserved in file):
````markdown
```javascript:guard-clause-pattern
// Title: Guard clauses in a data-binding utility
Console.assertTrue(isDefined(panel));
```
````

**Inline setup scripts** -- `// --- setup ---` / `// --- end setup ---` markers (extracted and run separately before the example):
````markdown
```javascript:knob-set-value
// --- setup ---
const var knob = Content.addKnob("Knob1", 0, 0);
knob.set("saveInPreset", false);
// --- end setup ---
knob.setValue(0.5);
```
````

**testMetadata blocks** -- JSON fence with `json:testMetadata:<slug>` matching the example's slug:
````markdown
```json:testMetadata:cable-to-gain
{
  "testable": true,
  "verifyScript": [
    {"type": "REPL", "expression": "cable.getValueNormalised()", "value": 0.75}
  ]
}
```
````

**Legacy format:** Phase 3 files may use unslugged ```` ```javascript ```` fences. The reader auto-generates slugs as `{filename}-{N}` (1-based). These work for validation but cannot be targeted by `--add-metadata` or `--edit`.

---

## Test Metadata Schema

### Required Fields

- **`testable`**: boolean (required)
- **`setupScript`**: string (optional) -- code to run before the example. Omit when using inline setup instead.
- **`verifyScript`**: object or array of objects (required if `testable: true`)

### Non-Testable Example

````markdown
```json:testMetadata:clearing-connections
{
  "testable": false
}
```
````

---

## Verification Types

### 1. Log Output (`type: "log-output"`)

Use when the example produces `Console.print()` output.

```json
{"type": "log-output", "values": ["expected", "log", "entries"]}
```

**Matching rules:** Exact count match required. Type normalization (`10` matches `"10"` matches `"10.0"`). "Interface: " prefix auto-stripped. Case-sensitive. Whitespace trimmed.

### 2. REPL (`type: "REPL"`)

Use when the example creates variables or modifiable state.

**Single check:**
```json
{"type": "REPL", "expression": "myVar", "value": 42}
```

**Multiple checks (recommended -- better error messages):**
```json
[
  {"type": "REPL", "expression": "doubled.length", "value": 3},
  {"type": "REPL", "expression": "doubled[0]", "value": 2}
]
```

**Rules:** `value` field is REQUIRED. Type normalization same as log-output. `"undefined"` string handled specially. Stops at first failure.

### 3. Error (`type: "expect-error"`)

Use when the example intentionally triggers an error (assertions, runtime errors).

```json
{"type": "expect-error", "errorMessage": "Assertion failure: condition is false"}
```

**Matching rules:** Execution must fail. Line/column prefix auto-stripped. Case-insensitive substring match.

**CRITICAL: Verify error patterns before adding metadata.** Predict the error based on code intent, then run. If prediction doesn't match actual, fix the code -- don't lock in broken error patterns.

**Red flags (broken code, not intentional errors):** "is not a function" (typo), "unexpected token" (syntax error), error unrelated to example's stated purpose.

**Common assertion patterns:**

| Method | Error Pattern |
|--------|--------------|
| `assertTrue(false)` | `"Assertion failure: condition is false"` |
| `assertEqual(1, 2)` | `"Assertion failure: 1 != 2"` |
| `assertIsDefined(undefined)` | `"Assertion failure: variable is undefined"` |

### 4. Mixed Verification

Combine types in an array. Each object needs an explicit `"type"` field.

```json
[
  {"type": "log-output", "values": ["Processing..."]},
  {"type": "REPL", "expression": "result.status", "value": "complete"}
]
```

**Rule:** `expect-error` MUST be last (execution stops on error, subsequent checks never run).

---

## Setup Scripts

Use setup when the example needs UI components, modules, or pre-existing variables. Prefer inline setup blocks (inside the code fence) over the `setupScript` field in testMetadata.

### Creating UI Components

````markdown
```javascript:button-value-test
// Title: Setting a button value
// --- setup ---
const Button1 = Content.addButton("Button1", 0, 0);
Button1.set("saveInPreset", false);
// --- end setup ---

Button1.setValue(1);
```
```json:testMetadata:button-value-test
{
  "testable": true,
  "verifyScript": {"type": "REPL", "expression": "Button1.getValue()", "value": 1}
}
```
````

### Creating Modules with Builder API

See Integration Test pattern in Common Patterns below for a full builder setup example.

**Common module types:** `builder.Effects.SimpleGain`, `builder.Effects.PolyphonicFilter`, `builder.Modulators.AHDSR`, `builder.Modulators.LFO`, `builder.SoundGenerators.StreamingSampler`

**Chain indexes:** `builder.ChainIndexes.FX` (effects), `.Gain` (gain mod), `.Pitch` (pitch mod), `.Direct` (sound generators)

**Rules:** Always `builder.clear()` first, always `builder.flush()` last. `parent: 0` for master container.

### What NOT to Put in Setup

- **Broadcasters** -- script-owned, wiped on recompile. Must be in example code.
- **Cables** -- should show full acquisition pattern (`getCable()`) in example code.
- **Example-specific logic** -- setup is only for environment (UI, modules).

### saveInPreset Pattern (CRITICAL for UI Tests)

**Problem:** `setValue()` during `onInit` gets overwritten by HISE's user preset model restore.

**Solution:** Set `saveInPreset: false` immediately after creating the component. (See Creating UI Components example above.)

**Applies to:** All `Content.add*()` components. Required whenever a test calls `setValue()` and verifies with REPL.

**NOT needed for:** `setControlCallback()` tests, creation-only tests, non-testable examples.

### Triggering Callbacks via REPL

**Problem:** `changed()` is a no-op during `onInit`, so control callbacks cannot be triggered from example code. The validator runs all example code as a single `onInit` compilation.

**Solution:** Use REPL verification checks to trigger callbacks after init completes. Chain `setValue()` and `changed()` with `||` in a single REPL expression, then verify the callback's side-effects in a subsequent check:

````json
"verifyScript": [
  {"type": "REPL", "expression": "Component1.setValue(1) || Component1.changed()", "value": false},
  {"type": "REPL", "expression": "callbackLog[0]", "value": 1}
]
````

The `||` operator evaluates both sides (both return undefined/falsy) and returns `false`. The subsequent REPL check verifies the callback executed. REPL checks run sequentially, so order is guaranteed.

**Applies to:** Any callback that requires post-init triggering via `setValue() + changed()`.

### Global State: Transport and BPM

Transport state (playing/stopped) and host BPM persist across recompiles. Examples that depend on or modify these must reset them in an inline setup block:

- **BPM:** `Engine.setHostBpm(-1)` resets to host default (120 in standalone)
- **Transport stopped:** `th.stopInternalClock(0)` (requires `setSyncMode(th.InternalOnly)` first)
- **Transport playing:** `th.startInternalClock(0)` (requires `setSyncMode(th.InternalOnly)` first)

---

## Verification Strategy

Decision tree for choosing verification type.

### Strong vs. Weak Verification

Ask "What capability does this method enable?" and test THAT.

- **Weak (avoid):** `{"expression": "browser.get('width')", "value": 600}` -- only proves existence
- **Strong (prefer):** `{"expression": "browser.getValue()", "value": [0, 1]}` -- proves functionality

Weak is acceptable when: method only sets properties, strong requires non-testable operations, or multiple weak checks collectively prove functionality.

### Decision Tree

- **Console.print() output?** Use `log-output`. **Creates variables/state?** Use `REPL`. **Both?** Use mixed array.

**Configuration method?** (setTableMode, createBroadcaster, etc.) - Complete the minimal setup chain to create verifiable state:
- Tables: setTableMode -> setTableColumns -> setTableRowData -> setValue -> verify getValue
- Broadcasters: createBroadcaster -> addListener -> send value -> verify listener effect (see Common Patterns)
- Mark non-testable if chain requires non-deterministic behavior.

These are just two common chain shapes. Any method that configures state without producing direct output follows the same principle: complete the minimal chain needed to create verifiable state, then verify with REPL.

**Integration/connection example?** - **MUST verify BOTH sides.** Single-sided checks only prove the API call, not the integration. The table below lists common types, but apply the same dual-verification principle to any connection pattern.

| Integration Type | Verify API Call Side | Verify Effect Side |
|-----------------|---------------------|-------------------|
| Cable -> Module | `cable.getValue()` | `module.getAttribute(param)` |
| Component -> Cable | `component.getValue()` | `cable.getValue()` |
| Broadcaster -> Listener | `broadcaster.argName` | Listener state/effect |

**Recognition keywords:** "connect", "link", "drive", "sync", "route", "bind" in titles means verify both endpoints.

**Intentional error?** - Use `expect-error`. Predict the error first, verify prediction matches actual, then add metadata.

**Pure side effects, no observable output?** - Use REPL to check component state, or add `Console.print()`, or mark `testable: false`.

---

## Common Patterns

### Array Methods (REPL)

````markdown
```javascript:mapping-array-values
// Title: Doubling array values with map
const arr = [1, 2, 3];
const result = arr.map(function(x) { return x * 2; });
```
```json:testMetadata:mapping-array-values
{
  "testable": true,
  "verifyScript": [
    {"type": "REPL", "expression": "result.length", "value": 3},
    {"type": "REPL", "expression": "result[0]", "value": 2}
  ]
}
```
````

### Console Output (log-output)

````markdown
```javascript:printing-loop-values
// Title: Printing loop iteration values
for (i = 0; i < 3; i++)
    Console.print("Loop " + i);
```
```json:testMetadata:printing-loop-values
{
  "testable": true,
  "verifyScript": {"type": "log-output", "values": ["Loop 0", "Loop 1", "Loop 2"]}
}
```
````

### Mixed Verification

````markdown
```javascript:object-with-print-and-repl
// Title: Creating object and printing a property
const obj = {"name": "test", "value": 42};
Console.print(obj.name);
```
```json:testMetadata:object-with-print-and-repl
{
  "testable": true,
  "verifyScript": [
    {"type": "log-output", "values": ["test"]},
    {"type": "REPL", "expression": "obj.value", "value": 42}
  ]
}
```
````

### Integration Test (Dual Verification)

````markdown
```javascript:cable-to-gain-integration
// Title: Cable driving a gain parameter end-to-end
// --- setup ---
const var builder = Synth.createBuilder();
builder.clear();
builder.create(builder.Effects.SimpleGain, "SimpleGain1", 0, builder.ChainIndexes.FX);
builder.flush();
// --- end setup ---

const var rm = Engine.getGlobalRoutingManager();
const var cable = rm.getCable("TestCable");
cable.connectToModuleParameter("SimpleGain1", "Gain", {"MinValue": -100, "MaxValue": 0});
cable.setValueNormalised(0.75);
const var gain = Synth.getEffect("SimpleGain1");
```
```json:testMetadata:cable-to-gain-integration
{
  "testable": true,
  "verifyScript": [
    {"type": "REPL", "expression": "cable.getValueNormalised()", "value": 0.75},
    {"type": "REPL", "expression": "gain.getAttribute(gain.Gain)", "value": -25.0}
  ]
}
```
````

### Table Configuration Chain

````markdown
```javascript:table-setup-and-select
// Title: Complete table setup with row selection
const var table = Content.addViewport("DataTable", 0, 0);
table.setTableMode({"RowHeight": 30, "Sortable": true});
table.setTableColumns([{"ID": "Name", "MinWidth": 150}]);
table.setTableRowData([{"Name": "A"}, {"Name": "B"}]);
table.set("saveInPreset", false);
table.setValue([0, 1]);
```
```json:testMetadata:table-setup-and-select
{
  "testable": true,
  "verifyScript": {"type": "REPL", "expression": "table.getValue()", "value": [0, 1]}
}
```
````

### Broadcaster Integration & Configuration Chain

````markdown
```javascript:broadcaster-chain
// Title: Broadcaster with listener and triggered message
const var bc = Engine.createBroadcaster({
    "id": "StatusBroadcaster",
    "args": ["status", "count"]
});

var log = [];

bc.addListener("logger", "Logs status changes",
function(status, count)
{
    log.push(status + ":" + count);
});

bc.sendSyncMessage(["ready", 1]);
bc.sendSyncMessage(["done", 2]);
```
```json:testMetadata:broadcaster-chain
{
  "testable": true,
  "verifyScript": [
    {"type": "REPL", "expression": "log.length", "value": 2},
    {"type": "REPL", "expression": "log[0]", "value": "ready:1"},
    {"type": "REPL", "expression": "bc.status", "value": "done"}
  ]
}
```
````

---

## CLI Reference

All commands require `--source` (`auto` | `project` | `manual` | `all`). Examples are addressed by `--slug` (not integer index). Working directory: `tools/api generator/`.

### Coverage

```bash
python snippet_validator.py --coverage --source all --class Console
python snippet_validator.py --coverage --source all --all-classes
```

### Extract (read-only)

```bash
python snippet_validator.py --extract --source project --class Console --method assertTrue
python snippet_validator.py --extract --source project --class Console --method assertTrue --slug guard-clause-pattern
python snippet_validator.py --extract --source project --class Console --method assertTrue --show-metadata
```

### Edit

```bash
python snippet_validator.py --edit --source project --class Console --method assertLegalNumber \
  --slug detecting-division-by-zero \
  --code $'var inputLevel = 0.0;\nvar gain1 = 1.0 / inputLevel;\n\nConsole.assertLegalNumber(gain1);'
```

### Add Metadata

```bash
# Non-testable
python snippet_validator.py --add-metadata --source project --class Array --method reserve \
  --slug pre-allocating-capacity --testable false

# log-output
python snippet_validator.py --add-metadata --source project --class Array --method concat \
  --slug merging-arrays --testable true --verify-type log-output \
  --verify-values '[3, "[0, 1, 2, 3, 4, 5]"]'

# REPL
python snippet_validator.py --add-metadata --source project --class Array --method clone \
  --slug shallow-copy --testable true --verify-type REPL \
  --verify-checks '[{"expression": "arr2[0]", "value": 22}]'

# expect-error
python snippet_validator.py --add-metadata --source project --class Console --method assertTrue \
  --slug unreachable-code --testable true --verify-type expect-error \
  --verify-error-message "Assertion failure: condition is false"
```

### Validate

```bash
python snippet_validator.py --validate --source all --class Console
python snippet_validator.py --validate --source project --class Console --method assertEqual
```

**Exit codes:** 0 = all passed, 1 = failures, 2 = connection lost mid-run (partial results saved).

---

## Workflow

1. **Check coverage:** `--coverage --source all --class ClassName`
2. **Read examples:** `--extract --source project --class ClassName --method methodName`
3. **Assess testability:** Complete? Deterministic? External deps? (See decision rules above.)
4. **Complete if needed:** `--edit` to fix trivial missing pieces.
5. **Add metadata:** `--add-metadata` with appropriate verification type.
6. **Validate:** `--validate --source project --class ClassName`
7. **Fix failures:** Wrong code? Use `--edit`. Wrong metadata? Use `--add-metadata` (overwrites).
8. **Repeat** for next method.
9. **Final coverage check:** `--coverage --source all --class ClassName`

**Batch tip:** Add metadata for 3-5 methods, then validate the whole class at once. Use `--method` for targeted validation when debugging.

---

## Pipeline Integration

Test metadata lives in phase `.md` source files and follows examples through the merge into `api_reference.json`.

**Phase 1:** Agents synthesize examples with slugs and testMetadata blocks during Step B.

**Phase 2:** Project examples get testMetadata blocks. Mark `testable: false` for examples needing external resources.

**Phase 3:** Manual examples may include testMetadata. When Phase 3 replaces examples, it must carry its own metadata.

**Pre-Phase 4a gate:** Validate all examples before writing user-facing docs (`--validate --source all --class ClassName` - see CLI Reference above).

**Merge behavior:** `api_enrich.py merge` reads the sidecar (`enrichment/output/test_results.json`) during example selection:
- Failed examples (`tested: true, passed: false`) are discarded
- If all winning-phase examples fail, merge falls back to a lower phase
- Untested examples are kept (absence from sidecar = "unknown, might work")
- Decisions logged to `output/decisions/{ClassName}_phase4a.md`

**Sidecar keying:** `Class.method.source.slug` (e.g., `Console.assertEqual.project.verifying-data-array-dimensions`). Results accumulate across runs.

---

## Related Guidelines

- `hisescript_example_rules.md` -- HISEScript syntax rules (inline function, const var, etc.)
- `code_example_quality.md` -- Editorial quality (lead with non-obvious behavior, show edge cases, obtain your objects)

Examples following those guidelines are naturally testable: complete, deterministic, with documented output.
