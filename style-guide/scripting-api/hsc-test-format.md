# `.hsc` Test File Authoring Guide

Authoritative reference for writing executable test files for HISE API documentation examples. Tests run via `hise-cli --run` against a live HISE instance.

`.hsc` files are the **single source of truth** for testable examples. They live in `enrichment/tests/{Class}/{method}/{slug}.hsc`. The api_enrich pipeline auto-discovers them and inlines their content as ```` ```hsc ```` fences in the generated documentation.

Non-testable examples (those requiring external resources, hardware, or DAW interaction) stay as ```` ```javascript:slug ```` blocks in the phase1/2/3 .md sources — see "When to Test" below.

---

## When to Test

Convert an example to a `.hsc` test when its behaviour is observable from script. Leave it as a non-testable `javascript` block in the .md source when it requires external resources that cannot be created via API.

| Resource type | Where it lives | Why |
|---|---|---|
| **UI components** (`Content.add*()`) | `.hsc` setup region | Created via `/ui add` mode |
| **Modules** (Builder API) | `.hsc` setup region | Created via `/builder add` mode |
| **Broadcasters** | `.hsc` example body | Subject of the example, not setup |
| **Cables** | `.hsc` example body | Should show full acquisition pattern |
| **External files, MIDI, hardware** | `.md` non-testable block | Cannot be created from script |

### Callback Testability: Programmatic Triggers

The real question: **can you fire this callback from script?** If yes, the example is testable.

| Callback / state | Programmatic trigger | Verify with |
|---|---|---|
| Transport change | `th.startInternalClock(0)` / `th.stopInternalClock(0)` | REPL: callback log or `th.isPlaying()` |
| Tempo change | `Engine.setHostBpm(newValue)` | REPL: callback log |
| Grid configuration | `setEnableGrid(true, tempoFactor)` | REPL: `th.getGridLengthInSamples()` |
| Broadcaster listeners | `bc.sendSyncMessage([...])` | REPL: listener side-effects |
| UI control callbacks | `triggerScript: ui-set` (in test region) → `/ui set X.value <v>` | REPL: callback side-effects |
| Key press callbacks | `Console.testCallback(component, "setKeyPressCallback", eventObj)` | REPL: callback side-effects |
| Panel mouse callbacks | `Console.testCallback(panel, "setMouseCallback", eventObj)` | REPL: `panel.data` or callback side-effects |
| Cable value (sync) | `cable.setValue(x)` in test-only (fires immediately during onInit) | REPL: `reg` variable set by extra sync callback |
| Cable value (async) | `cable.setValue(x)` in test-only (fires on next UI tick) | `/wait <ms>ms` + REPL: `reg` variable set by callback |
| Cable data callbacks | `secondRef.sendData(obj)` (second reference bypasses recursion guard) | log-output or REPL: callback side-effects |

`Console.testCallback` synchronously invokes a registered callback with a predetermined argument object. It supports a limited set of callback types per component — check the component's `testCallback` override in `ScriptingApiContent.h`.

> If you discover a new programmatic trigger for a callback type not listed here, add it to this table.

**Cannot be tested in playground mode** (mark non-testable, leave in `.md`):
- Bypass detection (watchdog-based)
- DAW time-signature changes
- Table interaction callbacks (click/selection/cell events)
- Hardware interaction
- Audio playback tick callbacks (`setOnBeatChange`, `setOnGridChange`) — unproven; mark non-testable

---

## File Location & Naming

```
enrichment/tests/{Class}/{method}/{slug}.hsc
```

- `{Class}` — PascalCase class/namespace name (e.g. `Content`, `Broadcaster`, `Effect`)
- `{method}` — method name (e.g. `getComponent`, `setBypassed`)
- `{slug}` — kebab-case identifier unique within the method (e.g. `caching-component-refs`)

One `.hsc` file per testable example. Multiple `.hsc` files per method get auto-discovered and inlined into the generated documentation.

---

## File Structure

Every `.hsc` test follows this template. Region sentinels (`// setup`, `// end setup`, `// test`, `// end test`) are JS comments — they're inert at runtime but used by the website to auto-collapse boilerplate when the test is rendered as a code example. Keep them exact.

```
// setup

# Startup & health check
/hise
/expect status contains online or abort
playground open
/exit

/builder reset

# Setup: build environment (UI components, modules)
{SETUP_BLOCK}

/script
/callback onInit
// end setup
{EXAMPLE_CODE}
// test
{TEST_ONLY_BLOCK}
/compile

# Verify
{EXPECTS}
/exit
// end test
```

**Region semantics for the website renderer:**
- Lines between `// setup` and `// end setup` → collapsed (env scaffold)
- Lines between `// end setup` and `// test` → **visible** (the example, doc-quality code)
- Lines between `// test` and `// end test` → collapsed (test invocation + assertions)

This means the `EXAMPLE_CODE` region must be clean, idiomatic HiseScript — no test-flavored noise.

---

## Header Block (always identical)

```
// setup

# Startup & health check
/hise
/expect status contains online or abort
playground open
/exit

/builder reset
```

- `/hise` enters runtime-control mode. `/expect status contains online or abort` checks HISE responds; `or abort` halts script if not (avoids cryptic downstream errors).
- `playground open` creates a sandboxed snippet-browser instance and routes all subsequent runtime endpoints (`/builder`, `/ui`, `/script`, REPL) to it. **Critical for website-launched tests**: without this, the test would mutate the user's currently loaded project. With it, the test runs in an isolated snippet without touching their work state.
- `/builder reset` clears the playground's module tree (single-line form: mode + command on same line, no mode persistence).

---

## Setup Block (variable)

Only included if the example needs an environment. Pick the right mode:

### UI components — `/ui` mode

For examples that reference components via `Content.getComponent("Name")`. Each `Content.addKnob/addButton/addPanel` call in the original example becomes one `/ui add` line.

```
/ui
add ScriptSlider "GainKnob" at 10 10 128 48
add ScriptButton "BypassBtn" at 300 10 128 32
/exit
```

| HiseScript call | `/ui add` form |
|---|---|
| `Content.addKnob("X", x, y)` | `add ScriptSlider "X" at x y 128 48` |
| `Content.addButton("X", x, y)` | `add ScriptButton "X" at x y 128 32` |
| `Content.addPanel("X", x, y)` | `add ScriptPanel "X" at x y 128 48` |
| `Content.addLabel("X", x, y)` | `add ScriptLabel "X" at x y 128 32` |
| `Content.addComboBox("X", x, y)` | `add ScriptComboBox "X" at x y 128 32` |

Loops in original setup must be unrolled — `/ui add` has no loop construct.

### Module tree — `/builder` mode

For examples that reference modules via `Synth.getEffect("Name")`, `Synth.getModulator("Name")`, etc. Each `builder.create(...)` call becomes one `/builder add` line.

```
/builder
add SimpleGain as "ChannelEq 1"
add SimpleGain as "ChannelEq 2"
add SineSynth as MySynth
/exit
```

Chain (FX/MIDI/gain/pitch) auto-resolves from module type. Modulators need explicit chain: `add LFO to MySynth.gain`. See `builder-reference.md` for module type names.

### Combined UI + builder

Two adjacent mode blocks, each with its own `/exit`:

```
/builder
add SineSynth as MySynth
/exit

/ui
add ScriptSlider "VolumeKnob" at 10 10 128 48
/exit
```

### No setup needed

Skip the `{SETUP_BLOCK}` entirely. Example flows straight from `/builder reset` into `/script`.

---

## Example Code Region

```
/script
/callback onInit
// end setup
{EXAMPLE_CODE}
// test
```

- `/script` enters HiseScript mode
- `/callback onInit` starts collecting lines into the `onInit` callback body
- `// end setup` marks the boundary — example code starts here
- Code is **verbatim** from the documentation. No inline assertions, no `Console.print` for testing only, no test-flavored mutations
- `// test` marks the end of the example, start of test region

The example region is what readers see on the website. Keep it clean.

---

## Test Region

```
// test
{TEST_ONLY_BLOCK}
/compile

# Verify
{EXPECTS}
/exit
// end test
```

### Test-only block

Code that triggers the example's behavior but isn't part of the canonical example. Examples: invoking a defined function, calling `bc.sendSyncMessage(...)` to fire a listener, calling `setValue` to trigger a callback.

```javascript
// test
toggleGlobalBypass();
bc.sendSyncMessage(["active", 5]);
/compile
```

Test-only lines are inside the `/callback onInit` body (before `/compile`), so they compile and run as part of the script. They're just visually grouped in the collapsed test region.

### `/compile`

Compiles the collected `onInit` body. Compile errors abort the script unless asserted via `/expect-compile throws`.

### Assertions

Five `/expect` verbs are available:

#### `is` — exact value match

```
/expect channelVolumes.length is 4
/expect gainKnob.get("id") is "GainKnob"
/expect bc.status is "active"
```

- Value types: number, string (quoted), boolean (`true`/`false`)
- Numeric tolerance: `is 0.5 within 0.01`
- Use for REPL-style return-value verification

#### `contains` — substring match (string return values)

```
/expect status contains "online"
/expect get Master.Volume contains "-6"
```

#### `logs` — capture single Console.print output

```
/expect Console.print(1234) logs 1234
/expect Console.print("hi") logs "hi"
```

#### `/expect-logs` — multi-line log assertion (post-compile)

After `/compile`, hise-cli stores the `result.logs` array from the compile response. `/expect-logs` reads from that buffer.

```
/script
/callback onInit
var a = ["Alice", "Bob", "Charlie"];
a.forEach(function(name){ Console.print("Hello " + name); });
/compile
/expect-logs ["Hello Alice", "Hello Bob", "Hello Charlie"]
```

Log lines are normalized: `"Interface: "`, `"Script Processor: "`, `"ScriptProcessor: "` prefixes stripped before compare. Per-line match is exact-string OR float-within-tolerance OR JSON-structural-equal.

`/capture` is reserved for the test phase — when test invocations after compile (e.g. `someComponent.changed()`) need their output asserted. For canonical example assertions, use the `/compile` + `/expect-logs` flow above.

#### `throws` — runtime error substring match

```
/expect undefinedFn() throws "not a function"
/expect Console.assertEqual(1, 2) throws "Assertion failed"
```

For testing API methods that should fail.

#### `/expect-compile throws` — compile-time error substring match

```
/callback onInit
var x = undefinedFunction();
/expect-compile throws "not a function"
```

Does NOT abort the script. Use when the example demonstrates an intentional compile error (e.g. `Console.assert*` examples).

### `or abort` modifier

```
/expect status contains online or abort
```

Halts the entire script if the assertion fails. Use sparingly — only for prerequisite checks (HISE running, project loaded). Regular `/expect` continues on failure and collects all results.

### Async assertions — `delay` field

For async behavior (broadcasters, timers, deferred callbacks), add `delay` (milliseconds) to a verify check. The translator emits `/wait <ms>ms` before the corresponding `/expect` line.

```json
{
  "verifyScript": [
    {"type": "REPL", "expression": "Display1.getValue()", "value": 0.4, "delay": 300}
  ]
}
```

→
```
# Verify
/wait 300ms
/expect Display1.getValue() is 0.4
```

Use sparingly — only when the canonical example genuinely needs async resolution. Default to no delay; add only after observing flaky test behavior. Common values: 100ms (broadcaster sync), 300ms (broadcaster async / UI repaint), 500-1000ms (timer/network).

### Trigger block (UI value changes)

For examples that need to fire control callbacks via simulated user interaction. Use the `triggerScript` field in `testMetadata` (alongside `verifyScript`):

```json
{
  "testable": true,
  "triggerScript": [
    {"type": "ui-set", "target": "Attack", "value": 0.7}
  ],
  "verifyScript": [
    {"type": "REPL", "expression": "attackCable.getValueNormalised()", "value": 0.7}
  ]
}
```

The translator emits between `/compile` and `/expect`:

```
/compile

# Trigger
/ui set Attack.value 0.7

# Verify
/expect attackCable.getValueNormalised() is 0.7
```

`/ui set <componentID>.value <value>` goes through the REST API path that triggers the registered control callback (unlike `setValue() + changed()` from inside the script, which has callback-recursion guards). `<componentID>` is the string passed to `Content.add*("ID", ...)`, not the script-side variable name.

**`triggerScript` types:**

| Type | .hsc emission | Use for |
|---|---|---|
| `ui-set` | `/ui set <target>.value <value>` | Component value change, fires control callback (knob, button, combobox, label) |

### `/exit`

Exits the current mode. The final `/exit` after assertions returns to default mode before script termination.

---

## Verification Strategy

### Integration / Connection Examples

Integration examples must verify **both sides** of the connection. A single-sided check only proves the API call ran, not that the connection actually moves data.

| Integration type | Verify API call side | Verify effect side |
|---|---|---|
| Cable → Module | `cable.getValue()` | `module.getAttribute(param)` |
| Component → Cable | `component.getValue()` | `cable.getValue()` |
| Broadcaster → Listener | `broadcaster.argName` | Listener state/effect |

Recognition keywords: "connect", "link", "drive", "sync", "route", "bind" → verify both endpoints.

### Configuration Chains

Methods that configure state without producing direct output need a minimal chain to create verifiable state:
- Tables: `setTableMode` → `setTableColumns` → `setTableRowData` → `setValue` → verify `getValue`
- Broadcasters: `createBroadcaster` → `addListener` → `sendSyncMessage` → verify listener side-effect

### Read-Side Caveats

The playground runs a full HISE instance — audio thread is live. Two patterns still fool naive assertions:

- **Smoothers on cable→module connections**: `cable.setValueNormalised()` sets the smoother target. The smoother ramps internally and drives the audio-side gain, but `module.getAttribute(<param>)` reads the nominal parameter, not the smoothed value. Don't assert the downstream parameter value — verify only the cable-side state (`cable.getValueNormalised()`).
- **Tempo-synced modulators (LFO, etc.)**: most LFO modes only advance phase while transport is playing. Start it explicitly:
  ```
  const var th = Engine.createTransportHandler();
  th.startInternalClock(0);
  ```
  Then `/wait` long enough for the modulator to step at least one period.

### Async Callbacks

Async callbacks (broadcasters with delay, expansion handler, deferred timers) write their side effect after `/compile` returns. Use `/wait <ms>ms` (or `delay` field in metadata for the migration script) before the assertion that checks the callback's side effect.

```
/compile
/wait 300ms
/expect lastBroadcastValue is "fired"
```

---

## Mode Quick Reference

| Mode | Purpose | Key commands |
|---|---|---|
| `/hise` | Runtime control | `status`, `launch`, `shutdown`, `screenshot` |
| `/builder` | Module tree | `add`, `remove`, `set`, `clone`, `bypass`, `show tree`, `reset` |
| `/ui` | UI components | `add`, `remove`, `set`, `move`, `rename`, `show` |
| `/script` | HiseScript REPL + callbacks | `/callback <name>`, `/compile`, `/capture`, `/expect-logs` |

Modes persist across lines until next `/<mode>` or `/exit`. Single-line form (e.g. `/builder reset`) doesn't change persistent mode.

---

## Running Tests

```bash
# From the api generator directory:
hise-cli --run ./enrichment/tests/Content/getComponent.hsc --verbose
```

**Path resolution gotcha**: bare relative paths (`enrichment/tests/...`) resolve against the HISE project folder, NOT the shell CWD. Always use `./` prefix to anchor against CWD.

Verbosity:
- `--verbose` — full per-command output + `/expect` rows + `PASSED N/N` footer
- (default) — `/expect` rows + footer only
- `--quiet` — single ✓/✗ pass-fail line

Exit codes: `0` pass, `1` any failure.

JSON output: `--json` returns structured `{ok, value: {expects, error, linesExecuted}}` for programmatic parsing.

---

## Pitfalls & Conventions

1. **Path resolution** — always prefix `./` for tests inside the api generator repo.
2. **REPL is read-only** — `/expect <expr>` runs as expression. No `var` declarations. Use `/capture` for any code that needs locals.
3. **`/capture` preserves prior state** — implicit IIFE wrapping, doesn't replace `onInit`.
4. **Region sentinels are mandatory** — website renderer relies on exact `// setup`, `// end setup`, `// test`, `// end test` markers.
5. **Loops in setup must be unrolled** — `/ui` and `/builder` have no loop construct. Trivial counted loops only need flat enumeration; complex setup with computed names should be inlined as raw `Content.addKnob(...)` calls inside `/script /callback onInit` instead.
6. **Test-only ≠ assertion** — invocations go inside `/callback onInit` (before `/compile`) so they compile + run; assertions go after `/compile` as separate `/expect` lines.
7. **State isolation** — every test starts with `/builder reset`. UI is wiped implicitly by the next compile (or via `/ui` removes if needed).
8. **No `Console.print` for testing** — if the example doesn't naturally produce output, prefer `/expect <var> is <value>` over inserting print statements. Only use `/expect-logs` when `Console.print` is part of the canonical example.
9. **`expect-error` examples** — for `Console.assert*` style examples, use `/expect-compile throws "<pattern>"` since the assertion fires during onInit compilation. Don't follow with `/compile` — `/expect-compile` does its own.

---

## Worked Example

`enrichment/phase1/Content/methods.md` slug `caching-component-refs` →

```
// setup

# Startup & health check
/hise
/expect status contains online or abort
playground open
/exit

/builder reset

# Setup: UI scaffold
/ui
add ScriptSlider "GainKnob" at 10 10 128 48
add ScriptSlider "MixKnob" at 150 10 128 48
add ScriptButton "BypassBtn" at 300 10 128 32
add ScriptSlider "Volume1" at 10 60 128 48
add ScriptSlider "Pan1" at 150 60 128 48
add ScriptSlider "Volume2" at 10 110 128 48
add ScriptSlider "Pan2" at 150 110 128 48
add ScriptSlider "Volume3" at 10 160 128 48
add ScriptSlider "Pan3" at 150 160 128 48
add ScriptSlider "Volume4" at 10 210 128 48
add ScriptSlider "Pan4" at 150 210 128 48
/exit

/script
/callback onInit
// end setup
Content.makeFrontInterface(900, 600);

const var gainKnob = Content.getComponent("GainKnob");
const var mixKnob = Content.getComponent("MixKnob");
const var bypassBtn = Content.getComponent("BypassBtn");

const var NUM_CHANNELS = 4;
const var channelVolumes = [];
const var channelPans = [];

for (i = 0; i < NUM_CHANNELS; i++)
{
    channelVolumes.push(Content.getComponent("Volume" + (i + 1)));
    channelPans.push(Content.getComponent("Pan" + (i + 1)));
}

Console.print(channelVolumes.length);
// test
/compile

# Verify
/expect gainKnob.get("id") is "GainKnob"
/expect channelVolumes.length is 4
/expect channelVolumes[2].get("id") is "Volume3"
/exit
// end test
```

Run: `hise-cli --run ./enrichment/tests/Content/getComponent.hsc --verbose` → `PASSED 4/4`.
