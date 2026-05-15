Queues a one-shot probe through a supported container node and reports the measured output block asynchronously. Use it to inject a simple test signal such as a dirac impulse, noise burst, or DC offset into a scriptnode container and inspect the resulting channel peaks, averages, silence state, and peak sample positions. Injection targets are resolved before a child node, while probe targets are resolved after a child node. Set `recursive` to probe every child container below the selected parent in one request.

| `injectData` field | Type | Description |
|--------------------|------|-------------|
| `parent` | String | ID of the supported container node that should receive the probe request |
| `injectId` | String | Child node ID to inject before. Overrides `injectIndex` if present |
| `injectIndex` | int | Child-node index to inject before. Must be in the range `0..numChildren-1` |
| `probeId` | String | Child node ID to probe after. Overrides `probeIndex` if present |
| `probeIndex` | int | Child-node index to probe after. Must be in the range `0..numChildren-1`. Use `-1` or omit it to probe after the last child node |
| `recursive` | bool | If true, probe the selected container and every child container recursively |
| `signalType` | String | Test signal to inject: `silence`, `dirac`, `noise`, or `dc` |
| `gain` | double | Signal level used for the injected test signal |
| `seed` | int | Random seed used when `signalType` is `noise` |
| `delayMs` | double | Extra time to wait before capturing the probe result |
| `filter` | Object | Optional response filter. See below |

Use `injectId` / `probeId` when you want to target named children. Use the numeric index form when you want a positional checkpoint. If both forms are present, the ID form wins. `injectIndex == probeIndex` is valid: it injects before child N and probes after child N.

| `filter` field | Type | Default | Description |
|----------------|------|---------|-------------|
| `specs` | bool | true | Include processing specs in each report |
| `signal` | bool | true | Include per-channel signal measurements |
| `compact` | bool | false | Collapse channel objects to peak-value arrays and omit default top-level fields |
| `tree` | bool | false | Include a dense topology tree for recursive reports |
| `wildcard` | String | `*` | Reserved. Leave at `*` to use the built-in filter modes |

The callback receives one report object with the queued request status and the measured probe data.

| Callback field | Type | Description |
|----------------|------|-------------|
| `ok` | bool | True when the report completed successfully |
| `error` | String | Error message. Empty on success |
| `parent` | String | ID of the container node that handled the probe |
| `factoryPath` | String | Factory path of the container that handled the probe |
| `injectIndex` | int | Resolved internal checkpoint index where the signal was injected |
| `probeIndex` | int | Resolved internal checkpoint index where the signal was probed |
| `signalType` | String | The injected signal type |
| `gain` | double | Injected signal level |
| `seed` | int | Random seed used for noise generation |
| `delayMs` | double | Remaining delay value after processing |
| `recursive` | bool | True when recursive container probing was used |
| `specs` | Object | Processing specs for a non-recursive report |
| `signal` | Array | Per-channel measurements for a non-recursive report |
| `containers` | Object | Recursive report object keyed by container ID |
| `tree` | Object | Dense topology tree when requested by `filter.tree` |

| `specs` field | Type | Description |
|----------------|------|-------------|
| `sampleRate` | double | Processing sample rate used for the report |
| `numChannels` | int | Number of processed channels |
| `blockSize` | int | Processed block size |
| `polyphonic` | bool | Whether the network was running with an enabled voice index |
| `processMidi` | bool | Whether the target container was in a MIDI-processing context |

Each entry in a full `signal` array contains `channelIndex`, `min`, `max`, `avg`, `peakIndex`, and `silence`, so you can inspect where the peak occurred and whether the probed block contained any audible data. In compact mode, each entry is replaced by one peak value per channel, using `0.0` for silent channels.

Recursive reports move per-container data into `containers`. Each container entry contains `factoryPath`, `numChildren`, optional `specs`, and `children`. Each child entry contains `id`, `factoryPath`, and optional `signal`.

> [!Warning:Backend only] The signal injection and probing path is compiled behind `USE_BACKEND`. In exported plugins this method should be treated as unavailable because the queued probe never produces a completed report callback.

> [!Warning:Order matters] The resolved inject position must not be after the resolved probe position. Unknown child IDs and out-of-range numeric indices fail immediately instead of falling back to another checkpoint.

**See also:** $SN.analyse.specs$ -- Scriptnode debug node for inspecting processing context such as sample rate, block size, channel count, MIDI routing, and polyphony state
