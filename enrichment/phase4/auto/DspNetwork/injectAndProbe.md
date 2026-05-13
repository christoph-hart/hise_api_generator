Queues a one-shot probe through a supported container node and reports the measured output block asynchronously. Use it to inject a simple test signal such as a dirac impulse, noise burst, or DC offset into a scriptnode container and inspect the resulting channel peaks, averages, silence state, and peak sample positions.

| `injectData` field | Type | Description |
|--------------------|------|-------------|
| `parent` | String | ID of the supported container node that should receive the probe request |
| `injectIndex` | int | Child-node index where the test signal is inserted. Defaults to `0` |
| `probeIndex` | int | Child-node index to inspect. Use `-1` to probe the container output after the last child node |
| `signalType` | String | Test signal to inject: `silence`, `dirac`, `noise`, or `dc` |
| `gain` | double | Signal level used for the injected test signal |
| `seed` | int | Random seed used when `signalType` is `noise` |
| `delayMs` | double | Extra time to wait before capturing the probe result |

The callback receives one report object with the queued request status and the measured probe data.

| Callback field | Type | Description |
|----------------|------|-------------|
| `ok` | bool | True when the report completed successfully |
| `error` | String | Error message. Empty on success |
| `injectIndex` | int | Index where the signal was injected |
| `probeIndex` | int | Index that was probed |
| `signalType` | String | The injected signal type |
| `signal` | Object | Captured probe report |

| `signal` field | Type | Description |
|----------------|------|-------------|
| `sampleRate` | double | Processing sample rate used for the report |
| `numChannels` | int | Number of processed channels |
| `blockSize` | int | Processed block size |
| `polyphonic` | bool | Whether the network was running with a voice index |
| `channels` | Array | Per-channel measurement objects |

Each entry in `signal.channels` contains `channelIndex`, `min`, `max`, `avg`, `peakIndex`, and `silence`, so you can inspect where the peak occurred and whether the probed block contained any audible data.

> [!Warning:Backend only] The signal injection and probing path is compiled behind `USE_BACKEND`. In exported plugins this method should be treated as unavailable because the queued probe never produces a completed report callback.

**See also:** $SN.analyse.specs$ -- Scriptnode debug node for inspecting processing context such as sample rate, block size, channel count, MIDI routing, and polyphony state
