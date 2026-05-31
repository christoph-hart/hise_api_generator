# NeuralNetwork -- Class Analysis

## Brief
Machine-learning inference engine for PyTorch, TensorFlow, NAM, and ONNX models in real-time audio.

## Purpose
NeuralNetwork provides a scripting API wrapper around the RTNeural framework and ONNX runtime for running trained neural network models within HISE. It supports multiple model formats (PyTorch, TensorFlow, NAM wavenet, ONNX) through a unified interface, handling model loading, weight initialization, and inference. The class manages thread-safe model swapping via lock-free audio-thread patterns and integrates with scriptnode's global cable routing for bidirectional data flow between DSP networks and script-level inference.

## Details

### Architecture

NeuralNetwork operates as a scripting wrapper (`ScriptNeuralNetwork`) around a shared core `NeuralNetwork` object stored in `MainController::NeuralNetwork::Holder`. Multiple script references using the same ID share the same underlying network instance. The core object is also accessible from scriptnode via the `math.neural` node through the `runtime_target::source_base` interface.

### Two Independent Subsystems

The class contains two completely independent inference engines:

1. **RTNeural subsystem** (`HISE_INCLUDE_RT_NEURAL`) -- Handles PyTorch, TensorFlow, and NAM models. Uses the RTNeural C++ library for real-time inference. Most methods require this flag.
2. **ONNX subsystem** -- Handles ONNX models via a dynamically loaded DLL (`onnx_lib`). Designed for image-based spectral classification rather than sample-level audio processing. Does not require `HISE_INCLUDE_RT_NEURAL`.

### Model Type Hierarchy

All models implement the internal `ModelBase` interface (`process`, `reset`, `clone`, `loadWeights`):

| Model Type | Created By | Topology |
|------------|-----------|----------|
| EmptyModel | Default / `clearModel()` | No-op placeholder |
| DynamicModel | `build()` | User-defined layer JSON (Linear, Tanh, ReLU, Sigmoid) |
| TensorFlowModel | `loadTensorFlowModel()` | Parsed from TF JSON (weights embedded) |
| NAMModel | `loadNAMModel()` | Fixed wavenet topology, always 1-in/1-out |
| CompiledModel | Compiled JSON + registered factory | Compile-time optimized model with optional quality configurations |

### Model Loading Workflows

See individual method entries for full details: `createModelJSONFromTextFile`, `build`, `loadWeights` (two-step PyTorch), `loadPytorchModel`, `loadTensorFlowModel`, `loadNAMModel` (combined loaders), and `loadOnnxModel` / `processFFTSpectrum` (ONNX path).

### Supported Pytorch Layer Types

- `Linear` (Dense)
- `Tanh` (activation)
- `ReLU` (activation)
- `Sigmoid` (activation)
- `Sequential` (container -- parsed but removed from layer list)

### Input/Output Dispatch

See `process` for full input/output dispatch details. Accepts a single number, Array, or Buffer; returns a float (single output) or Buffer reference (multiple outputs).

### Thread Safety

Model swaps use `ScopedMultiWriteLock` (blocks audio briefly). Processing uses `ScopedTryReadLock` -- if a model swap is in progress, inference is silently skipped rather than blocking. This ensures the audio thread never stalls.

### Compiled Model Workflow

Compiled model deployment uses a canonical JSON file written to `DspNetworks/NeuralNetworks/{id}.json` by `writeCompiledModelJSON`. The JSON can contain a `hise.qualityConfigurations` object. Each quality ID must be a valid identifier, and each configuration currently accepts `mathProvider` (`"default"` or `"fastMath"`) and `sampleRateCorrection` (`"none"` or `"linear"`). Runtime code can inspect available quality IDs with `getNetworkInfo` and switch compiled model variants with `setQualityConfiguration`.

The development diary identifies the purpose of this pipeline: keep scripting dynamic for authoring/import, but use `DspNetworks/NeuralNetworks/*.json` and supported `.nam` files as compile inputs for audio-rate `math.neural` use. A reported LSTM preamp test measured roughly 50% CPU reduction for the canonical one-input LSTM + Dense topology when routed through generated templated RTNeural code instead of the dynamic path. The `fastMath` quality option is a speed-oriented generated variant and should be presented as opt-in because it is not strictly bit-exact to the default maths provider.

Roundtrip workflow:

1. Create a network with the final ID and load exactly one compile-exportable dynamic source model: TensorFlow (`loadTensorFlowModel`) or NAM (`loadNAMModel`). PyTorch (`loadPytorchModel`) is supported for dynamic loading, but currently clears `compiledModelJSON` and does not emit canonical compiled-model JSON.
2. Call `writeCompiledModelJSON` to write `DspNetworks/NeuralNetworks/{id}.json`.
3. Compile the DSP Networks DLL in the HISE backend.
4. Create or reload a network with the same ID.
5. Assert that `getNetworkState()` returns `"compiled"`.

```javascript
const var nn = Engine.createNeuralNetwork("MyModel");

// Load one compile-exportable dynamic source model.
nn.loadTensorFlowModel(tensorFlowData);
// nn.loadNAMModel(namData);

// PyTorch can be loaded dynamically, but is not currently exportable
// through writeCompiledModelJSON.

nn.writeCompiledModelJSON({
    "default": {
        "mathProvider": "default",
        "sampleRateCorrection": "none"
    }
});

// Compile the DSP Networks DLL in the HISE backend, then reload/create the same ID.
const var compiledNN = Engine.createNeuralNetwork("MyModel");
Console.assertEqual(compiledNN.getNetworkState(), "compiled");
```

The network ID links the dynamic source model, the generated JSON file, and the compiled model registered by the DLL.

`DspNetworks/NeuralNetworks` is a compile-source folder. It is not an import folder and not a runtime asset folder. Compile inputs are canonical HISE compiled-model `.json` files for RTNeural / NAM and raw `.nam` files for the supported plain WaveNet subset. Raw PyTorch import files and raw TensorFlow import files are not compile inputs; TensorFlow must first be converted through `writeCompiledModelJSON`.

There is intentionally no `file-based` runtime state. If no compiled model is registered and the script does not manually load model data, the network remains `"empty"`.

### Backend State Inspection

`getNetworkState` returns a coarse state string: `"empty"`, `"dynamic"`, or `"compiled"`. `getNetworkInfo` returns a richer diagnostic object with dimensions, backend subtype (`"compiled-linked"`, `"compiled-dll"`, `"dynamic"`, `"empty"`), active quality configuration, available quality configurations, compiled JSON status, and backend-only source path fields.

### NAM Gain Compensation

NAM models can carry metadata for loudness and input/output calibration. `setNAMGainMode` chooses how that metadata affects output gain: `"raw"` applies no compensation, `"normalized"` targets -18 dB loudness when loudness metadata exists, and `"calibrated"` compensates against `inputCalibrationLevelDbu` when output-level metadata exists. The active gain mode and calculated gain values are exposed through `getNetworkInfo`.

## obtainedVia
`Engine.createNeuralNetwork(id)`

## minimalObjectToken
nn

## Constants
None.

## Dynamic Constants
None.

## Common Mistakes

| Wrong | Right | Explanation |
|-------|-------|-------------|
| `nn.process(input)` without calling `build()` or a load method first | Call `nn.build(modelJSON)` or `nn.loadPytorchModel(json)` before `nn.process()` | The default EmptyModel produces no output. A model must be loaded before inference. |
| `nn.loadWeights(weightsJSON)` after `loadTensorFlowModel()` | Use `loadTensorFlowModel()` alone (weights are embedded) | TensorFlow models include weights in the model JSON. Calling `loadWeights()` on a TensorFlowModel returns an error. |
| `nn.processFFTSpectrum(fft, w, h)` without `loadOnnxModel()` | Call `nn.loadOnnxModel(base64Data, numOutputs)` first | The ONNX model must be loaded before spectral inference. Reports a script error otherwise. |
| `nn.setQualityConfiguration("high")` before exporting/registering a compiled model | Call `writeCompiledModelJSON` in the backend, compile/register the generated model, then switch to a listed quality ID | Quality configurations only apply to compiled models. Dynamic and empty networks report an error. |
| `nn.setNAMGainMode("calibrated")` without calibration metadata | Use `getNetworkInfo()` to check `namHasOutputLevel` and related fields first | Calibrated mode only changes output gain when NAM output-level metadata is available. |
| `nn.writeCompiledModelJSON(...)` after `loadPytorchModel(...)` | Use TensorFlow or NAM for the compiled export path, or keep PyTorch as a script-managed dynamic model | The current PyTorch import path does not retain canonical compiled-model JSON. |

## codeExample
```javascript
// Create a neural network and load a PyTorch model
const var nn = Engine.createNeuralNetwork("myModel");

// Load combined PyTorch model (layers + weights in one JSON)
nn.loadPytorchModel(modelJSON);

// Run inference
var result = nn.process(0.5);
```

## Alternatives
- `FFT` -- Use for standard spectral analysis; NeuralNetwork is for learned audio transformations via neural network inference.
- `LorisManager` -- Use for deterministic partial-tracking resynthesis; NeuralNetwork is for data-driven inference using trained models.

## Related Preprocessors
`HISE_INCLUDE_RT_NEURAL` -- Required for all RTNeural-based methods (PyTorch, TensorFlow, NAM). The ONNX subsystem operates independently.

## Diagnostic Ideas
Reviewed: Yes
Count: 4
- NeuralNetwork.processFFTSpectrum -- timeline dependency (logged)
- NeuralNetwork.loadWeights -- timeline dependency (logged)
- NeuralNetwork.setNAMGainMode -- value-check (logged)
- NeuralNetwork.setQualityConfiguration -- state-validation (logged)
