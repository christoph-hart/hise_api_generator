Returns a handle to the effect currently loaded in the slot. Use this to control the loaded effect's parameters or bypass state after loading.

> [!Warning:$WARNING_TO_BE_REPLACED$] The return type depends on the slot mode: an `Effect` handle for classic SlotFX modules, or a `DspNetwork` object for scriptnode-based slots. Code that assumes one type will fail on the other.
