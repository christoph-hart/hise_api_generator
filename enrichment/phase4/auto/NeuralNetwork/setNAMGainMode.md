Sets how NAM metadata is used for output gain compensation. Pass either a simple mode string or the full options object when calibrated mode needs an explicit input reference level.

```javascript
{
    "mode": "calibrated",
    "inputCalibrationLevelDbu": -12.0
}
```

| Field | Type | Description |
|-------|------|-------------|
| `mode` | String | `raw`, `normalized`, or `calibrated`. |
| `inputCalibrationLevelDbu` | double | Optional input calibration reference used by calibrated mode. |

| Mode | Behaviour |
|------|-----------|
| `raw` | Leaves the NAM output level unchanged. |
| `normalized` | Uses loudness metadata, when available, to target -18 dB output loudness. |
| `calibrated` | Uses output-level metadata, when available, relative to `inputCalibrationLevelDbu`. |

> [!Warning:Metadata-dependent gain] `normalized` only changes gain when loudness metadata exists, and `calibrated` only changes gain when output-level metadata exists. Check `getNetworkInfo()` before relying on either mode.
