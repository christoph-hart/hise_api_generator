Copies all elements into a target container. Accepts three target types: an Array (cleared and filled), a Buffer (float mode only; must be strictly larger than the current element count), or another UnorderedStack (same mode; uses a fast path that skips duplicate checking). Returns true on success.

> [!Warning:$WARNING_TO_BE_REPLACED$] When copying to an Array in event mode, each event becomes a new independent MessageHolder. Modifying the copies does not affect the stack's contents.
