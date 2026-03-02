Controls which clock source - external (DAW) or internal (script-driven) - drives transport callbacks, grid timing, and BPM. Pass one of the sync mode constants available on any TransportHandler instance:

| Constant | Effect |
|----------|--------|
| `Inactive` | Disables all clock processing. No transport, beat, or grid callbacks fire. |
| `ExternalOnly` | Only the DAW drives transport. Internal clock calls are ignored. |
| `InternalOnly` | Only the internal clock (started with `startInternalClock()`) drives transport. DAW play/stop is ignored. |
| `PreferInternal` | Internal clock takes priority when playing. DAW events are accepted as fallback when the internal clock is idle. Use this as the default for plugins with their own transport controls. |
| `PreferExternal` | DAW takes priority when playing. When the DAW starts, it takes over from the internal clock and fires a grid resync. When the DAW stops, the internal clock resumes. Use this when a plugin should follow the DAW but maintain its own transport standalone. |
| `SyncInternal` | Internal clock controls start/stop, but its musical position syncs to the DAW's timeline while the DAW is playing. DAW stop commands are ignored - the internal clock keeps running. |

A common pattern is to default to `PreferInternal` and switch to `PreferExternal` via a host-sync toggle button, so the plugin works standalone but follows the DAW when requested.
