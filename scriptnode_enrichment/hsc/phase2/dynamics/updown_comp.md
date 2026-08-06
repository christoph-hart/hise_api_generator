# dynamics.updown_comp - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/dynamics/updown_comp.md`
- Reference: `scriptnode_enrichment/output/dynamics/updown_comp.md`

## Naming

- Module ID: `OTTCompressor`
- Network ID: `ott_compressor`

## Graph Plan

```text
ott_compressor
  FrequencySplit      template.freq_split3
    FrequencySplit_band1
      LowBand           template.dry_wet
        LowBand_wet_path
          LowPreGain      math.mul
          LowCompressor   dynamics.updown_comp
          LowPostGain     math.mul
    FrequencySplit_band2
      MidBand           template.dry_wet
        MidBand_wet_path
          MidPreGain      math.mul
          MidCompressor   dynamics.updown_comp
          MidPostGain     math.mul
    FrequencySplit_band3
      HighBand          template.dry_wet
        HighBand_wet_path
          HighPreGain     math.mul
          HighCompressor  dynamics.updown_comp
          HighPostGain    math.mul
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - None
- Channel/routing setup:
  - Required channels: fixed stereo only; this example must stay exactly two channels
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: [node is fixed stereo and should not be adapted to mono or wider layouts]

## Public Parameters

- Mix -> `LowBand.DryWet`, `MidBand.DryWet`, and `HighBand.DryWet` matched
- Target range: `[0, 1]`
- Macro range: `[0, 1]`
- Default: `1`

## Defaults To Omit

- `LowPreGain.Value` = `0.69`; `LowPostGain.Value` = `2.108`
- `MidPreGain.Value` = `1.834`; `MidPostGain.Value` = `1.8004609375`
- `HighPreGain.Value` = `1.81`; `HighPostGain.Value` = `3.27`
- `LowCompressor`: `LowThreshold=-40.8`, `LowRatio=3.941296815520002`, `HighThreshold=-33.8`, `HighRatio=65.06681640664662`, `Knee=0.1812000017549026`, `Attack=0`, `Release=305.4111685202056`, `RMS=1`
- `MidCompressor`: `LowThreshold=-42`, `LowRatio=5.351868752117148`, `HighThreshold=-30.3`, `HighRatio=65.06681640664667`, `Knee=0.3`, `Attack=0.664653791202388`, `Release=280.8672311435491`, `RMS=0`
- `HighCompressor`: `LowThreshold=-37.6321556848105`, `LowRatio=4.17`, `HighThreshold=-35.05200048966641`, `HighRatio=100`, `Knee=0.1175999981086471`, `Attack=2.095644181214617`, `Release=122.9679758241329`, `RMS=0`

## Locked Build Values

- `FrequencySplit.Band 1` = `88`
- `FrequencySplit.Band 2` = `2500`
- Every compressor parameter and every gain multiplier listed above is locked to its calibrated value. Do not normalize or round these values.

## Friction Comments To Weave In

- Before adding the band templates: use `template.freq_split3` for the two-crossover, three-band structure.
- Before the band mixers: each band needs its own `template.dry_wet` so its dry path shares the crossover filters with its processed path. A top-level dry/wet mixer would bypass the split on the dry path and introduce phase/group-delay mismatch.
- Before the stereo setup notes: keep this example strictly stereo, because the compressor is not intended for mono or wider multichannel layouts.

## Cosmetic Plan

- Main nodes: `LowCompressor`, `MidCompressor`, `HighCompressor`
- Accent colour: `0xFFE67E22`
- Supporting relevant nodes: [`FrequencySplit`, `LowBand`, `MidBand`, `HighBand`]
- Supporting colour: `0xFF8F7766`
- Folded nodes: [`LowPreGain`, `LowPostGain`, `MidPreGain`, `MidPostGain`, `HighPreGain`, `HighPostGain`]
- Nodes that must stay visible: [`FrequencySplit`, `LowBand`, `LowCompressor`, `MidBand`, `MidCompressor`, `HighBand`, `HighCompressor`]

## Open Questions

- Template child insertion behavior must be verified in HISE; the templates should remain composite nodes rather than being manually expanded.
