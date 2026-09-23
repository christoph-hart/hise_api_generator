# container.split - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/container/split.md`
- Reference: `scriptnode_enrichment/output/container/split.md`

## Status

- Built in HISE: true
- User approved: true

## Naming

- Module ID: `PhaseCancellationSilencer`
- Network ID: `phase_cancellation_silencer`

## Builder Setup Applied

- Host context: `Script FX`

## Final Topology

```text
phase_cancellation_silencer
  CancellationPaths
    PositivePath
    InvertedPath
```

## Verified Configuration

- `CancellationPaths` has exactly two children.
- `PositivePath.Value` = default `1`
- `InvertedPath.Value` = `-1`, range `-1..1`, step size `0`
- Neither path contains smoothing or latency-producing processing.

## Trace Validation

Seeded stereo noise at gain `0.25` verified:

- Both children received independent copies of the same aligned input.
- `PositivePath` reached approximately `-0.2497..0.2497`.
- `InvertedPath` produced the exact opposite values.
- The summed output was silent on both channels.

## Optimized Public Shell Commands

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id PhaseCancellationSilencer --agent
hise-cli builder set --module PhaseCancellationSilencer --network phase_cancellation_silencer --agent

# split copies the untouched input to every child and sums their aligned outputs.
hise-cli dsp add --module PhaseCancellationSilencer --type container.split --id CancellationPaths --agent
hise-cli dsp add --module PhaseCancellationSilencer --type math.mul --id PositivePath --parent CancellationPaths --agent
hise-cli dsp add --module PhaseCancellationSilencer --type math.mul --id InvertedPath --parent CancellationPaths --agent
# Widen the multiplier before setting the locked negative value.
hise-cli dsp set --module PhaseCancellationSilencer --node InvertedPath --param Value --range "-1,1" --stepSize 0 --agent
hise-cli dsp set --module PhaseCancellationSilencer --node InvertedPath --param Value --value -1 --agent

hise-cli dsp set --module PhaseCancellationSilencer --node CancellationPaths --param NodeColour --value 0xFF2F80ED --agent
hise-cli dsp set --module PhaseCancellationSilencer --node CancellationPaths --param Comment --value '"split copies the same aligned stereo input to both children, then sums their outputs."' --agent
hise-cli dsp set --module PhaseCancellationSilencer --node PositivePath --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module PhaseCancellationSilencer --node PositivePath --param Comment --value '"Passes the copied input unchanged at gain +1."' --agent
hise-cli dsp set --module PhaseCancellationSilencer --node InvertedPath --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module PhaseCancellationSilencer --node InvertedPath --param Comment --value '"Multiplies the second aligned copy by -1, producing exact cancellation without compensation gain."' --agent
```

## Pipeline-Only Commands

```bash
hise-cli dsp status --module PhaseCancellationSilencer --agent
hise-cli dsp trace --module PhaseCancellationSilencer --container phase_cancellation_silencer --inject noise --gain 0.25 --seed 1234 --probe-recursive --trace-compact --agent
hise-cli dsp save --module PhaseCancellationSilencer --agent
hise-cli dsp screenshot --module PhaseCancellationSilencer --scale 200% --output "scriptnode_enrichment/hsc/output/container/split.png" --agent
```

## Open Issues

- None.
