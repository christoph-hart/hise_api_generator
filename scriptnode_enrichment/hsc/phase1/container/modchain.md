# container.modchain - HSC Scenario

## Node

- Factory path: `container.modchain`
- Source page: `scriptnode_enrichment/output/container/modchain.md`

## Scenario

- Title: Control-Rate Oscillator Vibrato
- Project context: A sine-shaped control signal runs in a modulation chain without entering the parent audio path. Its normalised output moves a saw oscillator's frequency ratio between 0.98 and 1.02, creating subtle vibrato while the oscillator remains responsible for the audible signal.
- Teaching goal: Demonstrate that `container.modchain` processes a separate mono control buffer and leaves parent audio unchanged while a child node exports modulation to an audio-path target.

## Support Nodes

- Required: [`container.fix32_block`, `core.ramp`, `math.pi`, `math.sin`, `math.sig2mod`, `core.peak`, `core.oscillator`]
- Optional: []
- Rationale: `core.ramp` establishes the LFO period; `math.pi` converts its 0 to 1 cycle into radians; `math.sin` creates bipolar sine motion; `math.sig2mod` maps that motion to 0 to 1; `core.peak` exports the resulting block value as modulation; and `core.oscillator` generates the MIDI-pitched saw whose frequency ratio reveals the vibrato.

## Assumptions

- Channels: default stereo
- Public control needed: yes
- Raw node values acceptable: no

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Put `container.modchain` before `core.oscillator` inside `container.fix32_block`. The modchain passes parent audio unchanged, so the oscillator remains the only audible generator.
- Build the internal control path as `core.ramp -> math.pi -> math.sin -> math.sig2mod -> core.peak`, then connect the peak modulation output to `core.oscillator.Freq Ratio`.
- Override the target range to a continuous 0.98 to 1.02 interval despite the oscillator reference page's stock integer 1 to 16 range. Verify in HISE that the changed range preserves fractional modulation before Phase 2 is approved.
- Lock `math.pi.Value` to the full-cycle multiplier and keep the conversion before `core.peak`; using the normal peak directly on a bipolar sine would fold its negative half-cycle.
- Expose the ramp period as Rate and retain a conservative fixed ratio span so the result is vibrato rather than octave switching.
- This is control-rate modulation, not sample-accurate modulation. The verified Script FX modchain runs at one eighth of audio rate. Wrapping both source and target in `container.fix32_block` reduces each modulation update window to 32 audio samples, with four control samples per fixed block.
- Ensure source and target ranges are explicitly configured on both ends of the modulation connection, and check for orphan connections if the source is replaced during construction.
