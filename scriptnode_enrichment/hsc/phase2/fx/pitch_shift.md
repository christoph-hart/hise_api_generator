# fx.pitch_shift - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/fx/pitch_shift.md`
- Reference: `scriptnode_enrichment/output/fx/pitch_shift.md`

## Naming

- Module ID: `MicroshiftDoubler`
- Network ID: `microshift_doubler`

## Graph Plan

```text
microshift_doubler
  ShiftMix          template.dry_wet
    ShiftMix_wet_path
      MicroPitch    fx.pitch_shift
      WetTrim       core.gain
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - Keep the wet path in default block processing; do not wrap it in a frame container.
- Channel/routing setup:
  - Required channels: default stereo
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: []

## Public Parameters

- Mix -> `ShiftMix.DryWet` matched
- Target range before connection: `[0, 1]`
- Macro range: `[0, 1]`
- Default: `0.35`
- Ratio -> `MicroPitch.FreqRatio` matched
- Target range before connection: `[0.96, 1.04]`
- Macro range: `[0.96, 1.04]`
- Default: `1.015`

## Defaults To Omit

- `MicroPitch.FreqRatio` default `1`

## Locked Build Values

- `MicroPitch.FreqRatio.range` = `[0.96, 1.04]`
- `MicroPitch.FreqRatio.middlePosition` = `1`
- `ShiftMix.DryWet` default = `0.35`
- Do not put `MicroPitch` in a frame-processing container.

## Friction Comments To Weave In

- Before `MicroPitch`: `fx.pitch_shift` is block-based and uses an internal time-stretch engine, so avoid frame containers.
- Before Ratio macro: this example intentionally narrows FreqRatio to microshift values around `1.0`, not the full two-octave range.
- Before final notes: the pitch shifter introduces inherent processing latency.

## Cosmetic Plan

- Main node: `MicroPitch`
- Accent colour: `0xFF2F80ED`
- Supporting relevant nodes: [`ShiftMix`]
- Supporting colour: `0xFF6F8FAF`
- Folded nodes: [`WetTrim`]
- Nodes that must stay visible: [`ShiftMix`, `MicroPitch`]

## Open Questions

- Phase 3 must verify whether `fx.pitch_shift` initialises correctly in the current Playground build; if the time-stretch engine is unavailable, skip publish for this node and record the dependency.
