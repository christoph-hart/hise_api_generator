## addListener

**Examples:**


**Pitfalls:**
- When using the `object` parameter as `this` inside the callback, remember that arrays and objects are passed by reference. If the array is modified after `addListener` is called, the callback sees the modified version. Use `.clone()` if you need a snapshot.
