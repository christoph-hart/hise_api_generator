Returns a diagnostic object for the current neural backend. Use this when scripts need to check whether a model is dynamic or compiled, list available quality configurations, inspect NAM gain metadata, or show backend status in a developer tool.

| Field | Type | Description |
|-------|------|-------------|
| `id` | String | Network ID. |
| `state` | String | `empty`, `dynamic`, or `compiled`. |
| `backend` | String | `empty`, `dynamic`, `compiled-linked`, or `compiled-dll`. |
| `numInputs` / `numOutputs` | int | Model dimensions. |
| `numNetworks` | int | Number of internal model clones. |
| `hasCompiledModelJSON` | bool | True when canonical compiled JSON is available. |
| `activeQualityConfiguration` | String | Current quality ID. |
| `qualityConfigurations` | Array | Available quality IDs. If the compiled JSON has no quality metadata, this reports the implicit `default` variant. |
| `namGainMode` | String | `raw`, `normalized`, or `calibrated`. |
| `namOutputGainDb` | double | Current NAM output compensation in dB. |
| `namHasLoudness` / `namHasOutputLevel` | bool | Whether the NAM metadata can drive normalised or calibrated gain. |
| `source` / `sourceExists` | String / bool | Backend-only source file path and existence flag. |

Typical returned shape:

```javascript
{
    "id": "MyNAM",
    "state": "compiled",
    "backend": "compiled-linked",
    "numInputs": 1,
    "numOutputs": 1,
    "numNetworks": 1,
    "hasCompiledModelJSON": true,
    "activeQualityConfiguration": "high",
    "qualityConfigurations": ["low", "high"],
    "namGainMode": "calibrated",
    "namInputCalibrationLevelDbu": -12.0,
    "namInputGainDb": 0.0,
    "namOutputGainDb": -3.5,
    "namIsModel": true,
    "namHasLoudness": true,
    "namLoudnessDb": -14.5,
    "namHasInputLevel": true,
    "namInputLevelDbu": -12.0,
    "namHasOutputLevel": true,
    "namOutputLevelDbu": -15.5,
    "source": "/path/to/DspNetworks/NeuralNetworks/MyNAM.nam",
    "sourceExists": true
}
```
