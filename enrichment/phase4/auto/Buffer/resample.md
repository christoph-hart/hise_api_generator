Returns a new buffer resampled by `ratio`, with output length `round(inputLength / ratio)`. Choose interpolation with `"WindowedSinc"`, `"Lagrange"`, `"CatmullRom"`, `"Linear"`, or `"ZeroOrderHold"` depending on quality and speed needs.

> [!Warning:$WARNING_TO_BE_REPLACED$] Unknown interpolation names throw a runtime error. Keep mode strings exact.
