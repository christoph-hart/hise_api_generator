# NeuralNetwork -- Method Documentation

## build

**Signature:** `undefined build(JSON modelJSON)`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Call Scope Note:** Acquires ScopedMultiWriteLock, allocates DynamicModel on heap.
**Minimal Example:** `{obj}.build(layerData);`

**Description:**
Builds a neural network from a JSON layer description. The JSON is an array of layer objects produced by `createModelJSONFromTextFile` or constructed manually. After building, call `loadWeights` to set the trained parameters. Supported layer types: Linear, Tanh, ReLU, Sigmoid. Requires `HISE_INCLUDE_RT_NEURAL`. Internally allocates input/output buffers matching the model's dimensions.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| modelJSON | JSON | no | Array of layer objects describing the network topology | Must be a valid layer array |

**Callback Properties:**

| Property | Type | Description |
|----------|------|-------------|
| type | String | Layer type: "Linear", "Tanh", "ReLU", or "Sigmoid" |
| name | String | Layer name used as prefix for weight loading |
| inputs | Integer | Number of input connections for this layer |
| outputs | Integer | Number of output connections for this layer |
| isActivation | Integer | 1 if activation function, 0 if learnable layer |

**Pitfalls:**
- Calling `build` replaces the current model entirely. Previously loaded weights are lost and `loadWeights` must be called again.
- [BUG] The scripting wrapper ignores the Result returned by the core `build`. If the JSON contains unsupported layer types, the error is silently discarded and the model remains in an undefined state.

**Cross References:**
- `$API.NeuralNetwork.loadWeights$`
- `$API.NeuralNetwork.createModelJSONFromTextFile$`
- `$API.NeuralNetwork.loadPytorchModel$`

**Example:**
```javascript:build-simple-network
// Title: Build a simple neural network from layer JSON
const var nn = Engine.createNeuralNetwork("MyNetwork");

var layers = [
    {"type": "Linear", "name": "l1", "inputs": 1, "outputs": 16, "isActivation": false},
    {"type": "ReLU", "name": "relu1", "inputs": 16, "outputs": 16, "isActivation": true},
    {"type": "Linear", "name": "l2", "inputs": 16, "outputs": 1, "isActivation": false}
];

nn.build(layers);
```

```json:testMetadata:build-simple-network
{
  "testable": false,
  "skipReason": "Requires HISE_INCLUDE_RT_NEURAL build flag"
}
```

## clearModel

**Signature:** `undefined clearModel()`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Call Scope Note:** Acquires ScopedMultiWriteLock, allocates EmptyModel on heap.
**Minimal Example:** `{obj}.clearModel();`

**Description:**
Replaces the current model with an empty no-op model. After calling this, `process` returns zeros. Useful for releasing model resources before loading a different model. Requires `HISE_INCLUDE_RT_NEURAL`.

**Parameters:**

(No parameters.)

**Cross References:**
- `$API.NeuralNetwork.build$`
- `$API.NeuralNetwork.loadPytorchModel$`
- `$API.NeuralNetwork.loadTensorFlowModel$`
- `$API.NeuralNetwork.loadNAMModel$`
- `$API.NeuralNetwork.loadOnnxModel$`

## connectToGlobalCables

**Signature:** `undefined connectToGlobalCables(String inputId, String outputId)`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Call Scope Note:** Accesses GlobalRoutingManager, creates CableTargetBase objects on heap.
**Minimal Example:** `{obj}.connectToGlobalCables("NNInput", "NNOutput");`

**Description:**
Connects the neural network to global routing cables for automatic input/output. When a value arrives on the input cable, it triggers inference via `process`. The first output value is sent to the output cable after processing. Pass an empty string for either parameter to skip that connection.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| inputId | String | no | Global cable ID for input values | Empty string to skip |
| outputId | String | no | Global cable ID for output values | Empty string to skip |

**Pitfalls:**
- [BUG] This method is implemented in C++ but not registered via `ADD_API_METHOD_2` in the constructor and has no `Wrapper` entry. It cannot be called from HISEScript.

**Cross References:**
- `$API.NeuralNetwork.process$`

## createModelJSONFromTextFile

**Signature:** `JSON createModelJSONFromTextFile(ScriptObject fileObject)`
**Return Type:** `JSON`
**Call Scope:** unsafe
**Call Scope Note:** File I/O (reads file content from disk).
**Minimal Example:** `var layers = {obj}.createModelJSONFromTextFile(modelFile);`

**Description:**
Parses a Pytorch model text file (output of Python's `print(model)`) and returns a JSON array describing the network layers. The returned JSON can be passed directly to `build`. Supports Sequential containers with Linear, Tanh, ReLU, and Sigmoid layers. Requires `HISE_INCLUDE_RT_NEURAL`.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| fileObject | ScriptObject | no | A File object pointing to the .txt model file | Must be a valid ScriptFile |

**Pitfalls:**
- [BUG] Returns an empty object silently if the argument is not a valid ScriptFile. No error message is shown.

**Cross References:**
- `$API.NeuralNetwork.build$`
- `$API.NeuralNetwork.loadWeights$`

## getModelJSON

**Signature:** `JSON getModelJSON()`
**Return Type:** `JSON`
**Call Scope:** unsafe
**Call Scope Note:** Acquires ScopedReadLock, constructs JSON objects on heap.
**Minimal Example:** `var json = {obj}.getModelJSON();`

**Description:**
Returns the JSON layer description of the currently loaded model. Only works with DynamicModel (from `build`) and TensorFlowModel (from `loadTensorFlowModel`). Returns an empty object for NAM models, EmptyModel, or compiled models. Requires `HISE_INCLUDE_RT_NEURAL`.

**Parameters:**

(No parameters.)

**Pitfalls:**
- Returns an empty object silently for NAM models. Only DynamicModel and TensorFlowModel support JSON export.

**Cross References:**
- `$API.NeuralNetwork.build$`
- `$API.NeuralNetwork.loadTensorFlowModel$`

## getNetworkInfo

**Signature:** `JSON getNetworkInfo()`
**Return Type:** `JSON`
**Call Scope:** unsafe
**Call Scope Note:** Constructs a DynamicObject and Array on the heap, queries compiled backend metadata, and may construct backend-only File paths.
**Minimal Example:** `var info = {obj}.getNetworkInfo();`

**Description:**
Returns a diagnostic object describing the active neural backend, model dimensions, compiled model status, quality configurations, and NAM gain metadata. Requires `HISE_INCLUDE_RT_NEURAL`. In backend builds, the object also includes the expected source path and whether the `.json` or `.nam` source file exists.

**Parameters:**

(No parameters.)

**Callback Properties:**

| Property | Type | Description |
|----------|------|-------------|
| id | String | Neural network ID passed to `Engine.createNeuralNetwork` |
| state | String | Coarse backend state: `"empty"`, `"dynamic"`, or `"compiled"` |
| backend | String | Backend subtype: `"empty"`, `"dynamic"`, `"compiled-linked"`, or `"compiled-dll"` |
| numInputs | Integer | Number of model input values |
| numOutputs | Integer | Number of model output values |
| numNetworks | Integer | Number of cloned internal model instances |
| hasCompiledModelJSON | Integer | 1 if canonical compiled model JSON is available on the current network |
| activeQualityConfiguration | String | Currently active quality ID, usually `"default"` when no custom quality is selected |
| qualityConfigurations | Array | Available compiled quality IDs, or `["default"]` when no quality metadata is declared |
| namGainMode | String | Active NAM gain mode: `"raw"`, `"normalized"`, or `"calibrated"` |
| namInputCalibrationLevelDbu | Double | Input calibration level used by calibrated NAM gain compensation |
| namInputGainDb | Double | Calculated NAM input gain in dB. Currently 0.0 |
| namOutputGainDb | Double | Calculated NAM output gain in dB after the active compensation mode |
| namIsModel | Integer | 1 if the active model metadata identifies a NAM model |
| namHasLoudness | Integer | 1 if NAM loudness metadata is available |
| namLoudnessDb | Double | NAM loudness metadata in dB |
| namHasInputLevel | Integer | 1 if NAM input-level metadata is available |
| namInputLevelDbu | Double | NAM input-level metadata in dBu |
| namHasOutputLevel | Integer | 1 if NAM output-level metadata is available |
| namOutputLevelDbu | Double | NAM output-level metadata in dBu |
| source | String | Backend-only path to `DspNetworks/NeuralNetworks/{id}.json` or `{id}.nam` |
| sourceExists | Integer | Backend-only flag indicating whether the source file exists |

**Cross References:**
- `$API.NeuralNetwork.getNetworkState$`
- `$API.NeuralNetwork.writeCompiledModelJSON$`
- `$API.NeuralNetwork.setQualityConfiguration$`
- `$API.NeuralNetwork.setNAMGainMode$`

**Example:**
```javascript:get-network-info-schema
// Title: Inspect neural backend and NAM gain metadata
const var nn = Engine.createNeuralNetwork("MyNAM");

const var info = nn.getNetworkInfo();

/*
info = {
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
};
*/

Console.print("Backend: " + info.backend);
Console.print("NAM gain mode: " + info.namGainMode);
```

```json:testMetadata:get-network-info-schema
{
  "testable": false,
  "skipReason": "Requires HISE_INCLUDE_RT_NEURAL build flag and compiled/NAM model metadata for meaningful output"
}
```

## getNetworkState

**Signature:** `String getNetworkState()`
**Return Type:** `String`
**Call Scope:** warning
**Call Scope Note:** Returns a String, which involves atomic ref-count operations.
**Minimal Example:** `var state = {obj}.getNetworkState();`

**Description:**
Returns the active neural backend state as a coarse string. Possible values are `"empty"`, `"dynamic"`, and `"compiled"`. The two compiled backend implementations (`CompiledLinked` and `CompiledDll`) both return `"compiled"`; use `getNetworkInfo` when you need the exact backend subtype. There is intentionally no `"file-based"` state: files in `DspNetworks/NeuralNetworks` are compile inputs, not runtime assets.

**Parameters:**

(No parameters.)

**Value Descriptions:**

| Value | Description |
|-------|-------------|
| `"empty"` | No dynamic or compiled model is active. |
| `"dynamic"` | A runtime-loaded model is active. |
| `"compiled"` | A compiled linked or DLL-backed model is active. |

**Cross References:**
- `$API.NeuralNetwork.getNetworkInfo$`
- `$API.NeuralNetwork.setQualityConfiguration$`

**Example:**
```javascript:get-network-state
// Title: Check whether the compiled backend is active
const var nn = Engine.createNeuralNetwork("MyNAM");

if (nn.getNetworkState() == "compiled")
    Console.print("Using compiled neural backend");
```

```json:testMetadata:get-network-state
{
  "testable": false,
  "skipReason": "Requires HISE_INCLUDE_RT_NEURAL build flag and backend state setup"
}
```

## loadNAMModel

**Signature:** `undefined loadNAMModel(JSON modelJSON)`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Call Scope Note:** Acquires ScopedMultiWriteLock, allocates NAMModel on heap.
**Minimal Example:** `{obj}.loadNAMModel(namData);`

**Description:**
Loads a Neural Amp Modeler (NAM) wavenet model from JSON data. NAM models use a fixed wavenet topology and are always mono (1 input, 1 output), designed for guitar amp simulation. The JSON contains the wavenet weights directly -- no separate `build` or `loadWeights` step is needed. Requires `HISE_INCLUDE_RT_NEURAL`.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| modelJSON | JSON | no | NAM wavenet model data with weights | Must be valid NAM JSON |

**Pitfalls:**
- [BUG] The scripting wrapper ignores the Result returned by the core method. If weight loading fails (e.g., malformed JSON), the error is silently discarded.

**Cross References:**
- `$API.NeuralNetwork.loadPytorchModel$`
- `$API.NeuralNetwork.loadTensorFlowModel$`
- `$API.NeuralNetwork.loadOnnxModel$`

## loadOnnxModel

**Signature:** `Integer loadOnnxModel(String base64Data, Integer numOutputs)`
**Return Type:** `Integer`
**Call Scope:** unsafe
**Call Scope Note:** DLL loading, heap allocations, base64 decoding.
**Minimal Example:** `{obj}.loadOnnxModel(encodedData, 10);`

**Description:**
Loads an ONNX model from base64-encoded binary data. This is a separate subsystem from RTNeural and does NOT require `HISE_INCLUDE_RT_NEURAL`. ONNX models are used for spectral classification via `processFFTSpectrum`, not real-time sample processing. The ONNX runtime DLL is loaded from `HISE_PATH/tools/onnx_lib` (backend) or the app data directory (frontend). Returns 1 on success, throws a script error on failure.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| base64Data | String | no | Base64-encoded ONNX model binary | Must be valid base64 |
| numOutputs | Integer | no | Number of output values the model produces | Must be positive |

**Cross References:**
- `$API.NeuralNetwork.processFFTSpectrum$`
- `$API.NeuralNetwork.loadPytorchModel$`
- `$API.NeuralNetwork.loadTensorFlowModel$`
- `$API.NeuralNetwork.loadNAMModel$`

## loadPytorchModel

**Signature:** `undefined loadPytorchModel(JSON modelJSON)`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Call Scope Note:** Acquires ScopedMultiWriteLock, allocates DynamicModel on heap, loads weights.
**Minimal Example:** `{obj}.loadPytorchModel(fullModel);`

**Description:**
Loads a complete Pytorch model with both layer topology and trained weights in a single call. The JSON must have two keys: `"layers"` containing the text output of Python's `print(model)`, and `"weights"` containing the trained parameters exported via PyTorch's `state_dict()`. Internally calls `build` followed by `loadWeights`. Requires `HISE_INCLUDE_RT_NEURAL`.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| modelJSON | JSON | no | Combined model with "layers" and "weights" keys | Must contain both keys |

**Callback Properties:**

| Property | Type | Description |
|----------|------|-------------|
| layers | String | Text output of Python's `print(model)` describing the network topology |
| weights | JSON | Trained model parameters from PyTorch's `state_dict()` |

**Pitfalls:**
- [BUG] The scripting wrapper ignores the Result returned by the core method. If layer parsing or weight loading fails, the error is silently discarded.

**Cross References:**
- `$API.NeuralNetwork.build$`
- `$API.NeuralNetwork.loadWeights$`
- `$API.NeuralNetwork.createModelJSONFromTextFile$`
- `$API.NeuralNetwork.loadTensorFlowModel$`
- `$API.NeuralNetwork.loadNAMModel$`
- `$API.NeuralNetwork.loadOnnxModel$`

**Example:**
```javascript:load-pytorch-combined
// Title: Load a Pytorch model with layers and weights
const var nn = Engine.createNeuralNetwork("MyNetwork");

// fullModel is a JSON object with "layers" (model.txt content)
// and "weights" (state_dict JSON)
var fullModel = {
    "layers": "(l1): Linear(in_features=1, out_features=16)\n(relu1): ReLU()\n(l2): Linear(in_features=16, out_features=1)",
    "weights": {}
};

nn.loadPytorchModel(fullModel);
```

```json:testMetadata:load-pytorch-combined
{
  "testable": false,
  "skipReason": "Requires HISE_INCLUDE_RT_NEURAL build flag"
}
```

## loadTensorFlowModel

**Signature:** `undefined loadTensorFlowModel(JSON modelJSON)`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Call Scope Note:** Acquires ScopedMultiWriteLock, allocates TensorFlowModel on heap.
**Minimal Example:** `{obj}.loadTensorFlowModel(tfData);`

**Description:**
Loads a TensorFlow model from JSON data. The JSON must contain the full model definition including weights (RTNeural's TensorFlow JSON format). Unlike the Pytorch two-step workflow, no separate `build` or `loadWeights` step is needed. Requires `HISE_INCLUDE_RT_NEURAL`.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| modelJSON | JSON | no | Full TensorFlow model JSON with embedded weights | Must be valid RTNeural TF format |

**Pitfalls:**
- Calling `loadWeights` after loading a TensorFlow model fails with "Tensor Flow models will initialise their weights with the model JSON".
- [BUG] The scripting wrapper ignores the Result returned by the core method. Additionally, the core method has no try-catch around the TensorFlowModel constructor (unlike `build` and `loadNAMModel`), so malformed JSON may cause an unhandled exception.

**Cross References:**
- `$API.NeuralNetwork.loadPytorchModel$`
- `$API.NeuralNetwork.loadNAMModel$`
- `$API.NeuralNetwork.loadOnnxModel$`
- `$API.NeuralNetwork.loadWeights$`

## loadWeights

**Signature:** `undefined loadWeights(JSON weightData)`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Call Scope Note:** Acquires ScopedMultiWriteLock, JSON serialization to string.
**Minimal Example:** `{obj}.loadWeights(weights);`

**Description:**
Loads trained weights into the current model. Must be called after `build` for Pytorch-style two-step workflows. The weight data is a JSON object matching the format exported by PyTorch's `state_dict()` with the `EncodeTensor` helper class. After loading, the model is automatically reset. Requires `HISE_INCLUDE_RT_NEURAL`.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| weightData | JSON | no | Trained model parameters as JSON | Must match current model topology |

**Pitfalls:**
- [BUG] The scripting wrapper ignores the Result returned by the core `loadWeights`. Calling this on an EmptyModel (before `build`) silently fails -- the core returns "network is not initialised" but the error never reaches the user.
- Calling `loadWeights` on a TensorFlow model fails with "Tensor Flow models will initialise their weights with the model JSON", but this error is also silently discarded by the wrapper.

**Cross References:**
- `$API.NeuralNetwork.build$`
- `$API.NeuralNetwork.createModelJSONFromTextFile$`

## process

**Signature:** `var process(var input)`
**Return Type:** `var`
**Call Scope:** warning
**Call Scope Note:** Uses ScopedTryReadLock (non-blocking, skips if write lock held). No allocations on the processing path. Inference computation is O(model_size) per call.
**Minimal Example:** `var result = {obj}.process(0.5);`

**Description:**
Runs inference on the loaded model. Accepts a single float, an array of floats, or a Buffer as input. Returns a single float when the model has one output, or a Buffer reference when it has multiple outputs. If an output cable is connected, the first output value is automatically sent to it. Silently returns zero if a model swap is in progress (write lock held). Requires `HISE_INCLUDE_RT_NEURAL`.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| input | NotUndefined | no | Input value(s) for inference | Number, Array, or Buffer matching model input size |

**Pitfalls:**
- [BUG] The input size validation for Array and Buffer inputs uses `isPositiveAndBelow(expectedSize, inputSize)` which requires `inputSize > expectedSize` (strict greater-than). Passing an array or buffer with exactly the model's input count causes the check to fail silently -- no processing occurs and 0.0 is returned. Arrays must have at least one extra element beyond the model's input count.
- Returns 0.0 silently when a write lock is held during model swap. No error or indication that processing was skipped.

**Cross References:**
- `$API.NeuralNetwork.build$`
- `$API.NeuralNetwork.reset$`
- `$API.NeuralNetwork.processFFTSpectrum$`

**Example:**
```javascript:process-inference
// Title: Run inference with different input types
const var nn = Engine.createNeuralNetwork("MyNetwork");

// Single input, single output model
var result = nn.process(0.5);

// Multi-input model: pass array (must have MORE elements than model inputs due to size check)
var multiResult = nn.process([0.1, 0.2, 0.3, 0.0]);
```

```json:testMetadata:process-inference
{
  "testable": false,
  "skipReason": "Requires HISE_INCLUDE_RT_NEURAL build flag and loaded model"
}
```

## processFFTSpectrum

**Signature:** `Array processFFTSpectrum(ScriptObject fftObject, Integer numFreqPixels, Integer numTimePixels)`
**Return Type:** `Array`
**Call Scope:** unsafe
**Call Scope Note:** Image rescaling, DLL inference call, Array construction on heap.
**Minimal Example:** `var classes = {obj}.processFFTSpectrum(fft, 128, 64);`

**Description:**
Runs ONNX inference on an FFT spectrum for spectral classification. Takes an FFT object and rescales its spectrum to the specified dimensions as an image, then passes it through the loaded ONNX model. Returns an array of float output values (e.g., classification probabilities). Requires `loadOnnxModel` to be called first. Does NOT require `HISE_INCLUDE_RT_NEURAL` -- uses the separate ONNX subsystem.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| fftObject | ScriptObject | no | An FFT object with spectrum data | Must be a valid ScriptFFT |
| numFreqPixels | Integer | no | Height of the rescaled spectrum image | Must be positive |
| numTimePixels | Integer | no | Width of the rescaled spectrum image | Must be positive |

**Cross References:**
- `$API.NeuralNetwork.loadOnnxModel$`
- `$API.NeuralNetwork.process$`

## reset

**Signature:** `undefined reset()`
**Return Type:** `undefined`
**Call Scope:** unsafe
**Call Scope Note:** Acquires blocking ScopedReadLock. NAM models run warmup inference (prewarm) during reset.
**Minimal Example:** `{obj}.reset();`

**Description:**
Resets the internal state of the neural network model. For DynamicModel and TensorFlowModel, this zeros the internal layer states. For NAM models, this calls `prewarm()` which runs warmup inference with zero input. Automatically called after `loadWeights`. Requires `HISE_INCLUDE_RT_NEURAL`.

**Parameters:**

(No parameters.)

**Cross References:**
- `$API.NeuralNetwork.loadWeights$`
- `$API.NeuralNetwork.process$`

## setNAMGainMode

**Signature:** `Integer setNAMGainMode(JSON modeOrOptions)`
**Return Type:** `Integer`
**Call Scope:** unsafe
**Call Scope Note:** Kills voices and executes on the sample-loading thread before mutating NAM gain metadata and compiled JSON.
**Minimal Example:** `{obj}.setNAMGainMode({"mode": "calibrated", "inputCalibrationLevelDbu": -12.0});`

**Description:**
Sets NAM output gain compensation. Pass either a mode string (`"raw"`, `"normalized"`, or `"calibrated"`) or an object with `mode` and optional `inputCalibrationLevelDbu`. The method stores the preferred gain mode in the network metadata, updates the compiled model JSON if present, and returns 1 on success. Requires `HISE_INCLUDE_RT_NEURAL`.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| modeOrOptions | JSON | no | Mode string or options object for NAM gain compensation | String: `"raw"`, `"normalized"`, `"calibrated"`; Object keys: `mode`, `inputCalibrationLevelDbu` |

**Callback Properties:**

| Property | Type | Description |
|----------|------|-------------|
| mode | String | NAM gain mode: `"raw"`, `"normalized"`, or `"calibrated"` |
| inputCalibrationLevelDbu | Double | Calibration reference level used by calibrated mode. Optional; defaults to the previous calibration value |

**Value Descriptions:**

| Value | Description |
|-------|-------------|
| `"raw"` | Applies no NAM gain compensation. Model output is used as-is. |
| `"normalized"` | Uses NAM loudness metadata, when available, to target -18 dB output loudness. |
| `"calibrated"` | Uses NAM output-level metadata, when available, relative to `inputCalibrationLevelDbu`. |

**Pitfalls:**
- Calibrated mode only changes output gain when NAM output-level metadata exists. Check `getNetworkInfo().namHasOutputLevel` before relying on it.
- Normalized mode only changes output gain when NAM loudness metadata exists. Check `getNetworkInfo().namHasLoudness` before relying on it.

**Cross References:**
- `$API.NeuralNetwork.loadNAMModel$`
- `$API.NeuralNetwork.getNetworkInfo$`

**Example:**
```javascript:set-nam-gain-mode-calibrated
// Title: Set NAM gain compensation with full options object
const var nn = Engine.createNeuralNetwork("MyNAM");

const var gainOptions = {
    "mode": "calibrated",
    "inputCalibrationLevelDbu": -12.0
};

nn.setNAMGainMode(gainOptions);
```

```json:testMetadata:set-nam-gain-mode-calibrated
{
  "testable": false,
  "skipReason": "Requires HISE_INCLUDE_RT_NEURAL build flag and NAM model metadata"
}
```

## setQualityConfiguration

**Signature:** `Integer setQualityConfiguration(String qualityId)`
**Return Type:** `Integer`
**Call Scope:** unsafe
**Call Scope Note:** Validates Identifier, kills voices, runs on the sample-loading thread, allocates compiled model clones, resets them, and swaps model arrays under ScopedMultiWriteLock.
**Minimal Example:** `{obj}.setQualityConfiguration("high");`

**Description:**
Switches a compiled neural network to a named quality configuration and resets the model. The quality ID must be a valid HISE identifier and must exist in the compiled model factory for this network. Returns 1 on success and reports a script error if the network is empty, dynamic, or the quality ID is unknown. Requires `HISE_INCLUDE_RT_NEURAL`.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| qualityId | String | no | Quality configuration ID to activate | Must be a valid Identifier and listed in `getNetworkInfo().qualityConfigurations` |

**Pitfalls:**
- This only applies to compiled models. Calling it on an empty or dynamic network reports a script error.
- Unknown quality IDs fail and report the available configurations.
- The method kills active voices before switching. Do not call it from a high-frequency path.

**Cross References:**
- `$API.NeuralNetwork.writeCompiledModelJSON$`
- `$API.NeuralNetwork.getNetworkInfo$`
- `$API.NeuralNetwork.getNetworkState$`

**Example:**
```javascript:set-quality-configuration
// Title: Safely switch to an exported quality configuration
const var nn = Engine.createNeuralNetwork("MyNAM");

const var info = nn.getNetworkInfo();

if (info.qualityConfigurations.contains("high"))
    nn.setQualityConfiguration("high");
```

```json:testMetadata:set-quality-configuration
{
  "testable": false,
  "skipReason": "Requires HISE_INCLUDE_RT_NEURAL build flag and registered compiled quality configurations"
}
```

## writeCompiledModelJSON

**Signature:** `Integer writeCompiledModelJSON(JSON qualityConfigurations)`
**Return Type:** `Integer`
**Call Scope:** unsafe
**Call Scope Note:** Backend-only file system access, directory creation, JSON serialization, and file write.
**Minimal Example:** `{obj}.writeCompiledModelJSON({"high": {"sampleRateCorrection": "none"}});`

**Description:**
Writes the current TensorFlow or NAM model as canonical compiled neural JSON to the project's `DspNetworks/NeuralNetworks` folder. The optional `qualityConfigurations` object is written into the HISE metadata section and later controls available compiled quality IDs. Passing `{}` omits `hise.qualityConfigurations` and creates one implicit default variant during generation. Returns 1 on success, reports a script error on validation or file I/O failure, and is only available in the HISE backend. Requires `HISE_INCLUDE_RT_NEURAL`.

**Parameters:**

| Name | Type | Forced | Description | Constraints |
|------|------|--------|-------------|-------------|
| qualityConfigurations | JSON | no | Object keyed by quality ID, or `{}` to write no custom quality configurations | Each key must be a valid Identifier; `mathProvider` must be `"default"` or `"fastMath"`; `sampleRateCorrection` must be `"none"` or `"linear"` |

**Callback Properties:**

| Property | Type | Description |
|----------|------|-------------|
| qualityId | JSON | Replace `qualityId` with each quality configuration name, eg. `"low"` or `"high"` |
| mathProvider | String | Optional maths provider: `"default"` for bit-exact standard maths or `"fastMath"` for a speed-oriented generated variant |
| sampleRateCorrection | String | Optional correction mode for that quality: `"none"` or `"linear"` |

**Value Descriptions:**

| Value | Description |
|-------|-------------|
| `"default"` | Uses RTNeural's default maths provider. |
| `"fastMath"` | Uses HISE's fast maths provider for generated compiled variants. Faster, but not strictly bit-exact to the default provider. |
| `"none"` | No sample-rate correction metadata is requested for this quality. |
| `"linear"` | Requests linear sample-rate correction metadata for this quality. |

**Pitfalls:**
- This method is backend-only. In an exported plugin or frontend build, it reports `writeCompiledModelJSON() is only available in the HISE backend` and returns 0.
- It can only write models that have compiled model JSON available. TensorFlow and NAM loaders currently provide this; the PyTorch loader currently does not.
- `DspNetworks/NeuralNetworks` is a compile-source folder, not a runtime asset folder.

**Cross References:**
- `$API.NeuralNetwork.setQualityConfiguration$`
- `$API.NeuralNetwork.getNetworkInfo$`

**Example:**
```javascript:write-compiled-model-json-quality-configurations
// Title: Export compiled neural JSON with quality configurations
const var nn = Engine.createNeuralNetwork("MyNAM");

const var qualityConfigurations = {
    "hi": {
        "mathProvider": "default",
        "sampleRateCorrection": "linear"
    },
    "low": {
        "mathProvider": "fastMath",
        "sampleRateCorrection": "none"
    }
};

nn.writeCompiledModelJSON(qualityConfigurations);

// Pass an empty object to write the compiled JSON without custom quality IDs.
// nn.writeCompiledModelJSON({});
```

```json:testMetadata:write-compiled-model-json-quality-configurations
{
  "testable": false,
  "skipReason": "Requires HISE backend, HISE_INCLUDE_RT_NEURAL build flag, and compiled model JSON source data"
}
```
