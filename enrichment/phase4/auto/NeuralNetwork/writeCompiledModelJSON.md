Writes the current TensorFlow or NAM model as canonical compiled neural JSON into the project's `DspNetworks/NeuralNetworks` folder. In backend tools, use this after loading or preparing a model that can be exported for compiled deployment. PyTorch models can be loaded dynamically, but the current PyTorch import path does not emit canonical compiled-model JSON yet.

The argument is an object keyed by quality ID. Pass `{}` when you do not want custom quality configurations; this omits `hise.qualityConfigurations` and creates one implicit `default` variant during generation.

```javascript
{
    "hi": {
        "mathProvider": "default",
        "sampleRateCorrection": "linear"
    },
    "low": {
        "mathProvider": "fastMath",
        "sampleRateCorrection": "none"
    }
}
```

| Field | Type | Description |
|-------|------|-------------|
| quality ID | Object | A valid HISE identifier such as `hi`, `low`, or `default`. |
| `mathProvider` | String | Optional: `default` for bit-exact standard maths or `fastMath` for a speed-oriented generated variant. |
| `sampleRateCorrection` | String | Optional: `none` or `linear`. |

Raw `.nam` files can also be placed directly in `DspNetworks/NeuralNetworks` as compile inputs if the filename stem is a valid HISE identifier and the NAM architecture is in the supported subset.

> [!Warning:Backend-only export] This method only works in the HISE backend. Exported plugins and frontend builds report an error and return false.
