Writes values in bulk to the currently bound slider pack.

You can pass a number (fill all sliders), an array, or a buffer.

> [!Warning:$WARNING_TO_BE_REPLACED$] If the array or buffer is shorter than `getNumSliders()`, only the available indices are updated and the rest keep their previous values.
