Returns the current backend state as a short string. Use it for simple branches where you only need to know whether the network is empty, dynamic, or compiled.

| Value | Meaning |
|-------|---------|
| `empty` | No dynamic or compiled model is active. |
| `dynamic` | A model loaded at runtime is active. |
| `compiled` | A compiled linked or DLL-backed model is active. |

Use `getNetworkInfo` when you need the exact compiled backend subtype or quality configuration data.

There is no file-based runtime state. Files in `DspNetworks/NeuralNetworks` are compile inputs; if no compiled model is registered and the script does not load model data manually, the network remains `empty`.
