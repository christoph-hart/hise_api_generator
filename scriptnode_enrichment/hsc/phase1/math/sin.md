# math.sin - HSC Scenario

## Node

- Factory path: `math.sin`
- Source page: `scriptnode_enrichment/output/math/sin.md`

## Scenario

- Title: Ramp-to-sine converter
- Project context: A slow `core.ramp` is scaled into radians with `math.pi`, reshaped by `math.sin`, and then converted to a 0..1 display signal for the final peak view. The result is a visual demonstration of how a phasor-like ramp becomes a sine-shaped curve.
- Teaching goal: Demonstrate how `math.sin` turns a ramp-shaped phase signal into a sine wave when the input is first scaled correctly.

## Support Nodes

- Required: [`core.ramp`, `math.pi`, `math.sig2mod`, `core.peak`]
- Optional: [`math.clear`]
- Rationale: `core.ramp` provides the slow phase driver, `math.pi` converts 0..1 into a full radian cycle, `math.sig2mod` makes the bipolar sine output display-friendly, and `core.peak` shows the final shape.

## Assumptions

- Channels: default stereo
- Public control needed: no
- Raw node values acceptable: yes

## User Input Needed

- Required: false
- Questions:
  - None

## Notes For Phase 2

- Use a slow ramp such as 1000 ms so the sine shape is readable in the peak display.
- Keep `math.pi` at the full-cycle setting so one ramp cycle becomes one sine cycle.
- Convert the sine output with `math.sig2mod` before the peak display so the view matches the expected modulation curve.
