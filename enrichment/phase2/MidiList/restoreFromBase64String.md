## restoreFromBase64String

**Examples:**


**Pitfalls:**
- Always guard `restoreFromBase64String` with `isDefined()` or a version check. Older presets may not contain the serialized MidiList field, and passing an empty or undefined string will produce unexpected results.
