# fx.pitch_shift - HSC Scenario

## Node

- Factory path: `fx.pitch_shift`
- Source page: `scriptnode_enrichment/output/fx/pitch_shift.md`

## Scenario

- Title: Microshift chorus doubler
- Project context: A vocal or synth insert needs a subtle widening/chorus layer without writing a full delay-line chorus. The wet path uses `fx.pitch_shift` with a small ratio offset around `1.0`, then blends it with the dry input for a simple microshift doubler.
- Teaching goal: Demonstrate `fx.pitch_shift` as an audio pitch shifter in a block-processing dry/wet effect, with FreqRatio exposed in meaningful musical bounds.

## Support Nodes

- Required: [`template.dry_wet`]
- Optional: [`core.gain`]
- Rationale: The dry/wet template supplies a practical insert-style mix and keeps the pitch-shifted layer separate from the dry signal. Optional gain can tame the wet layer if trace or listening levels are too high.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: yes

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Keep the node in a block-processing context; `fx.pitch_shift` does not support frame processing.
- Narrow `FreqRatio` around `1.0` for a chorus/doubler example, rather than exposing the full two-octave range.
- Avoid a polyphonic host for this public example unless needed, because per-voice pitch shifting is CPU-heavy.
- Include a visible note that the node introduces processing latency due to the time-stretch engine.
