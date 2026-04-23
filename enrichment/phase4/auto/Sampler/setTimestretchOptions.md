Configures the timestretch engine from a JSON object. The `Mode` property selects one of four modes:

| Mode | Behaviour |
|------|-----------|
| `"Disabled"` | No timestretching applied |
| `"VoiceStart"` | New voices use the current ratio; active voices keep theirs |
| `"TimeVariant"` | All active voices update to the same ratio in real-time |
| `"TempoSynced"` | Ratio calculated automatically from sample length and current tempo |

Additional properties: `Tonality` (0.0-1.0), `SkipLatency` (boolean), `PreferredEngine` (engine identifier), and two mutually exclusive ways to define the source length for TempoSynced mode:

- `SourceBPM` (double, default 0.0): the tempo of the source material in BPM. When non-zero, the quarter-note count is derived automatically from the sample duration and this tempo.
- `NumQuarters` (double, default 0.0): the length of the sample in quarter notes, used when `SourceBPM` is zero. If both are zero the sampler guesses the quarter-note count from the sample duration and the current tempo.

Use `Sampler.getTimestretchOptions()` to read the current configuration.
