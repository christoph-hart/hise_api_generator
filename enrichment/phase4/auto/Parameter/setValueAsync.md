Sets the parameter value immediately by calling the DSP callback directly. The value is applied to all voices in polyphonic networks. Does not update the ValueTree and does not support undo - use `setValueSync()` when undo is needed.

> [!Warning:Silently ignored before node initialisation] If the node's DSP callback is not yet initialised (the node has not been fully connected in the network), the call is silently ignored without error.
