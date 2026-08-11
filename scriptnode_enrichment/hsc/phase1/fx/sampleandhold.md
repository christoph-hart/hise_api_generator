# fx.sampleandhold - HSC Scenario

## Node

- Factory path: `fx.sampleandhold`
- Source page: `scriptnode_enrichment/output/fx/sampleandhold.md`

## Scenario

- Title: Tempo-stepped random texture
- Project context: A sound-design insert needs stepped, low-rate movement rather than smooth modulation. A noise source or simple generated signal is reduced by `fx.sampleandhold`, then used as a visibly staircase-like random texture or control-rate modulation source.
- Teaching goal: Demonstrate that `fx.sampleandhold` holds samples for a fixed Counter value, making Counter the direct control over time resolution.

## Support Nodes

- Required: [`core.oscillator`, `core.gain`]
- Optional: [`control.converter`, `core.tempo_sync`, `filters.one_pole`]
- Rationale: A noise oscillator makes the sample-hold steps obvious, gain keeps the generated texture controlled, and optional tempo conversion can map musical rates to the Counter value if the live graph can do this cleanly.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: yes

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- `Counter` is the only parameter. Do not use the outdated `Position` parameter name from older copied docs.
- Counter `1` is pass-through, so the public range should start above `1` if the example's default must sound or trace as decimated.
- If tempo-sync support makes the topology too large or unclear, prefer a direct integer `Counter` macro and describe it as sample periods rather than beats.
- Keep the source deterministic enough for validation if signal trace is used; random/noise behaviour may require parameter or structural verification instead of exact sample-value assertions.
