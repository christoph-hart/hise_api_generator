# container.oversample4x - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/container/oversample4x.md`
- Reference: `scriptnode_enrichment/output/container/oversample4x.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: Approved as a fixed 4x hard-clipping production example.

## Naming

- Module ID: `ProductionHardClipper`
- Network ID: `production_hard_clipper`

## Builder Setup Applied

- Host context: `Script FX`

## Final Topology

```text
production_hard_clipper
  QuadRateClipper        container.oversample4x
    PreGain              math.mul
    HardClip             math.clip
    OutputTrim           math.mul
  OutputSpectrum         analyse.fft
```

## Verified Parameters

- `QuadRateClipper.FilterType` = default `Polyphase`
- `PreGain.Value` range = `1..8`, value `4`
- `HardClip.Value` = `0.35`
- `OutputTrim.Value` = `0.5`
- Root `Drive` range = `1..8`, default `4`

## Verified Connections

- Root `Drive` -> `PreGain.Value`, matched

## Trace Validation

- Command: `hise-cli dsp trace --module ProductionHardClipper --container production_hard_clipper --inject dc --gain 0.5 --probe-recursive --probe-param PreGain.Value --trace-compact --agent`
- `QuadRateClipper` reported `192000 Hz`, block size `2048`, stereo, from a `48000 Hz` / `512` host context.
- The oversampled child trace reached `0.35` after HardClip and `0.175` after the `0.5` trim.
- `PreGain.Value` reported `4` through the public Drive mapping.
- Runtime status passed.

## Optimized Public Shell Commands

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id ProductionHardClipper --agent
hise-cli builder set --module ProductionHardClipper --network production_hard_clipper --agent
# All distortion stages share 4x processing; analysis remains outside at the host rate.
hise-cli dsp add --module ProductionHardClipper --type container.oversample4x --id QuadRateClipper --agent
hise-cli dsp add --module ProductionHardClipper --type math.mul --id PreGain --parent QuadRateClipper --agent
hise-cli dsp add --module ProductionHardClipper --type math.clip --id HardClip --parent QuadRateClipper --agent
hise-cli dsp add --module ProductionHardClipper --type math.mul --id OutputTrim --parent QuadRateClipper --agent
hise-cli dsp add --module ProductionHardClipper --type analyse.fft --id OutputSpectrum --agent
hise-cli dsp set --module ProductionHardClipper --node PreGain --param Value --range "1,8" --agent
hise-cli dsp set --module ProductionHardClipper --node PreGain --param Value --value 4 --agent
hise-cli dsp set --module ProductionHardClipper --node HardClip --param Value --value 0.35 --agent
hise-cli dsp set --module ProductionHardClipper --node OutputTrim --param Value --value 0.5 --agent
hise-cli dsp create_parameter --module ProductionHardClipper --container production_hard_clipper --id Drive --range "1,8" --default 4 --agent
hise-cli dsp connect --module ProductionHardClipper --source production_hard_clipper --source-param Drive --target PreGain --param Value --matched --agent
# Keep math.clip in block processing because its frame implementation has different transfer behaviour.
hise-cli dsp set --module ProductionHardClipper --node production_hard_clipper --param Comment --value '"**Block processing** - Keep math.clip out of frame containers because its single-sample implementation differs."' --agent
hise-cli dsp set --module ProductionHardClipper --node QuadRateClipper --param NodeColour --value 0xFFE67E22 --agent
hise-cli dsp set --module ProductionHardClipper --node QuadRateClipper --param Comment --value '"**Practical 4x stage** - Drive, hard clipping, and trim are oversampled while analysis remains at the host rate."' --agent
hise-cli dsp set --module ProductionHardClipper --node PreGain --param NodeColour --value 0xFF8C6D55 --agent
hise-cli dsp set --module ProductionHardClipper --node HardClip --param NodeColour --value 0xFF8C6D55 --agent
hise-cli dsp set --module ProductionHardClipper --node OutputTrim --param NodeColour --value 0xFF8C6D55 --agent
hise-cli dsp set --module ProductionHardClipper --node OutputSpectrum --param NodeColour --value 0xFF8C6D55 --agent
hise-cli dsp set --module ProductionHardClipper --node OutputSpectrum --param Folded --value true --agent
```

## Pipeline-Only Commands

```bash
hise-cli dsp save --module ProductionHardClipper --agent
hise-cli dsp screenshot --module ProductionHardClipper --scale 200% --output "scriptnode_enrichment/hsc/output/container/oversample4x.png" --agent
```

## Comments To Preserve In HSC

- Keep all distortion stages inside the 4x context.
- Keep the analyser outside.
- Do not wrap `math.clip` in a frame container.
- Bypass retains the distortion chain at 1x.

## Documentation Feedback

- The clipping threshold parameter is `HardClip.Value`, not `HardClip.Limit`; Phase 2 was corrected.

## Open Issues

- None.
