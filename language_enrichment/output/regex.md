---
title: Regex in HISE
description: "Standard regular expressions for pattern matching across HISE APIs and UI features"

guidance:
  summary: >
    Reference for regular expression usage in HISE. All regex consumers use
    standard ECMAScript regular expressions - fully standard compliant with
    no HISE-specific modifications. This page lists every API method and UI
    feature that accepts regex patterns, with practical examples for common
    use cases like component filtering, sound selection, and text matching.
  concepts:
    - regex
    - regular expressions
    - pattern matching
    - Content.getAllComponents
    - Sampler.selectSounds
    - Engine.getRegexMatches
    - Engine.matchesRegex
    - String.match
  prerequisites:
    - hisescript
  complexity: beginner
---

HISE uses standard ECMAScript regular expressions for all pattern matching. The syntax is fully standard compliant — there are no HISE-specific modifications or limitations to the regex engine itself.

This page focuses on *where* regex is used in HISE and practical patterns for common tasks. For full regex syntax, refer to the [MDN Regular Expressions guide](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Regular_expressions) — HISE's regex flavour matches JavaScript's regex syntax.


## Scripting API Consumers

### Content.getAllComponents(regex)

Returns an array of UI component references whose names match the pattern. The most commonly used regex consumer — essential for the $LANG.hisescript$ modular code pattern.

```javascript
// All components matching a pattern
const var knobs = Content.getAllComponents("Knob[0-9]+");

// All components (fast path — skips regex evaluation)
const var all = Content.getAllComponents(".*");

// Buttons starting with "Filter"
const var filterBtns = Content.getAllComponents("Filter.*Button");
```

### Sampler.selectSounds(regex)

Selects sampler sounds whose filename matches the pattern. Supports special prefix operators for building complex selections:

```javascript
// Select all round-robin variants 1 and 2
Sampler.selectSounds(".*_RR[12]_.*");

// Add to current selection
Sampler.selectSounds("add:.*_C3_.*");

// Subtract from current selection
Sampler.selectSounds("sub:.*noise.*");

// AND operator — must match both patterns
Sampler.selectSounds(".*Piano.*&.*ff.*");
```

| Prefix | Behavior |
| --- | --- |
| *(none)* | Replace selection with matches |
| `add:` | Add matches to current selection |
| `sub:` | Remove matches from current selection |
| `&` (between patterns) | AND — sound must match all patterns |

### Engine.matchesRegex(string, regex)

Returns `true` if the pattern is found anywhere in the string (partial match, not full-string match).

```javascript
if (Engine.matchesRegex(filename, "C[0-9]"))
    Console.print("Contains a C note");
```

### Engine.getRegexMatches(string, regex)

Returns an array of all matches including capture groups. The first element is the full match, followed by each capture group.

```javascript
var m = Engine.getRegexMatches("v1.2.3", "(\\d+)\\.(\\d+)\\.(\\d+)");
// m[0] = "1.2.3" (full match)
// m[1] = "1"     (first capture group)
// m[2] = "2"     (second capture group)
// m[3] = "3"     (third capture group)
```

### String.match(regex)

Called on a string value, returns an array of all matches.

```javascript
var results = "hello world 123 test 456".match("\\d+");
// ["123", "456"]
```

### Synth.getAllModulators(regex)

Returns an array of modulator references whose IDs match the pattern.

```javascript
const var lfos = Synth.getAllModulators("LFO.*");
const var envelopes = Synth.getAllModulators(".*Envelope.*");
```

### Synth.getAllEffects(regex)

Returns an array of effect references whose IDs match the pattern.

```javascript
const var reverbs = Synth.getAllEffects("Reverb.*");
const var allFx = Synth.getAllEffects(".*");
```

### ChildReference.getAllComponents(regex)

Same as `Content.getAllComponents` but scoped to children of a dynamic container's child reference.

```javascript
var buttons = childRef.getAllComponents("Button.*");
```


## UI Features

### Sampler Table Search Bar

The search field in the Sampler Table accepts regex patterns with the same syntax and prefix operators (`add:`, `sub:`, `&`) as `Sampler.selectSounds()`. Type a pattern to filter the sample list in real time.

### Code Editor — Find All Occurrences

The code editor's Find dialog has a **regex toggle**. When enabled, the search term is interpreted as a regex pattern instead of plain text.


## Common Patterns

| Pattern | Matches | Use case |
| --- | --- | --- |
| `Knob[0-9]+` | `Knob1`, `Knob12`, `Knob100` | Component arrays by naming convention |
| `.*Button` | `PlayButton`, `StopButton` | All components ending with "Button" |
| `^Filter` | `FilterCutoff`, `FilterQ` | Components starting with "Filter" |
| `.*_RR[1-4]_.*` | Filenames with round-robin 1-4 | Sample selection by round-robin |
| `(\\d+)` | Capture numeric parts | Extract numbers from strings |
| `.*\\.wav` | Files ending in `.wav` | File type filtering |
| `[A-G]#?[0-9]` | `C3`, `F#4`, `Bb2` | Note name matching |

> [!Tip:Double-escape backslashes in HiseScript] In HiseScript strings, backslashes must be doubled: write `"\\d+"` to match digits, not `"\d+"`.


## Differences from Standard

HISE uses standard ECMAScript regular expressions — there are no deviations from the standard. All ECMAScript regex features work as documented, including:

- Character classes (`[a-z]`, `\d`, `\w`, `\s`)
- Quantifiers (`*`, `+`, `?`, `{n,m}`)
- Anchors (`^`, `$`)
- Groups and captures (`()`)
- Alternation (`|`)
- Lookahead (`(?=...)`, `(?!...)`)

The only HISE-specific extensions are the prefix operators in $API.Sampler.selectSounds$ (`add:`, `sub:`, `&`), which are processed before the regex is evaluated.


## What's Next

**See also:** $API.Engine.getRegexMatches$ -- full match extraction, $API.Engine.matchesRegex$ -- boolean pattern test, $API.Content.getAllComponents$ -- component filtering
