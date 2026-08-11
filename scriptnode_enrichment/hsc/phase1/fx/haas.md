# fx.haas - HSC Scenario

## Node

- Factory path: `fx.haas`
- Source page: `scriptnode_enrichment/output/fx/haas.md`

## Scenario

- Title: Per-voice stereo scatter
- Project context: A polyphonic voice-level FX should spread each note to a stable stereo position without using level-based panning. Each active voice receives one random position when the note starts, then `fx.haas` delays one channel by a few milliseconds so the note appears from that side of the stereo field.
- Teaching goal: Demonstrate `fx.haas` as a stereo positioning effect and show why its Position value is useful as a per-voice, note-start modulation target.

## Support Nodes

- Required: [`control.voice_bang`, `control.random`, `control.bipolar`]
- Optional: [`core.gain`, `envelope.simple_ar`]
- Rationale: A `PolyScriptFX` receives existing per-voice audio, `control.voice_bang` creates one trigger per note start, `control.random` supplies a static per-voice value, and `control.bipolar` centres/scales that value into a controllable left-right Position range for `fx.haas`.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: yes

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- This example must use `PolyScriptFX`, not a plain monophonic `ScriptFX`, so that note-start randomisation is meaningful per voice.
- `fx.haas` requires a stereo signal. If the oscillator or host path is mono in live construction, Phase 2 must add the smallest stereo conversion step before `fx.haas`.
- The random value should be generated once per voice start and held stable for that voice; do not use a continuously changing random source for Position.
- Narrow the public spread control so the maximum Haas delay stays musical and does not become an obvious slap echo.
