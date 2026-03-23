Sets non-uniform slider widths using normalised cumulative breakpoints.

The array should describe segment boundaries from `0.0` to `1.0` and have length `getNumSliders() + 1`.

> **Warning:** If the array length does not match `numSliders + 1`, an error is logged and layout falls back to equal widths.

> **Warning:** Update `sliderAmount` and width array together in one code path to keep drawing and hit-testing aligned.
