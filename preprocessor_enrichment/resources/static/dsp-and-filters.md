---
description: Module-specific DSP switches — delay buffer size, Curve EQ topology, filter modulation curve, async convolution damping, and neural network warmup.
---

Preprocessors in this category change the behaviour of specific DSP modules and scriptnode nodes. They set the maximum delay line size, swap the Curve EQ implementation between biquad and state-variable filters, shape how filter frequency modulation is applied, decide whether convolution damping updates run asynchronously, and configure the neural network warmup length. Each flag ties to a single module or node pair rather than being a project-wide knob, so its consequences are local and predictable. Expect a bit-exact sound shift on any patch that uses the affected processor when you change these.
