Controls which clock source -- external (DAW) or internal (script-driven) -- drives transport callbacks, grid timing, and BPM. This is a global setting that affects all TransportHandler instances. Pass one of the sync mode constants available on the TransportHandler instance:

| Constant | Effect |
|----------|--------|
| `Inactive` | Disables all clock processing. No transport, beat, or grid callbacks fire. |
| `ExternalOnly` | Only the DAW drives transport. Internal clock calls are ignored. Grid timing follows the DAW's musical position. |
| `InternalOnly` | Only the internal clock (started with `startInternalClock()`) drives transport. DAW play/stop is completely ignored. |
| `PreferInternal` | Internal clock takes priority when playing. DAW events are accepted as fallback when the internal clock is idle. |
| `PreferExternal` | DAW takes priority when playing. When the DAW starts, it takes over from the internal clock and fires a grid resync. When the DAW stops, the internal clock resumes automatically. Use this when your plugin should follow the DAW when hosted but maintain its own transport standalone. |
| `SyncInternal` | Internal clock controls start/stop, but its musical position continuously syncs to the DAW's timeline while the DAW is playing. DAW stop commands are ignored -- the internal clock keeps running. Use this when you need script-controlled transport but want the grid to stay locked to the DAW's beat. |
