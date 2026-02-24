Sends arbitrary data (JSON objects, strings, arrays, buffers) through the cable's data channel to all registered data callbacks. The data channel is completely independent of the value channel -- sending data does not affect the cable's value, and value callbacks are not triggered. There is no data queue for the sender side -- if you register a target after data has been sent, it will not receive the previously sent value.

> Do not call this from the audio thread or from inside a synchronous value callback -- the serialisation step involves memory allocation.
