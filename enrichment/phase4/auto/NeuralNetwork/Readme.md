<!-- Diagram triage:
  - No diagram specifications exist for this class or its methods.
-->

# NeuralNetwork

NeuralNetwork runs trained neural network models for real-time audio inference. It supports four model formats through a unified interface:

1. **PyTorch** - custom layer topologies with separate or combined weight loading.
2. **TensorFlow** - RTNeural JSON format with embedded weights.
3. **NAM** (Neural Amp Modeler) - fixed wavenet topology for guitar amp modelling (mono only).
4. **ONNX** - spectral classification via a separate runtime (not sample-level audio).

The typical workflow is to create a network in script, load a pre-trained model, and either call `process` for offline inference or connect the network to a `math.neural` scriptnode node for audio-rate processing. Multiple script references using the same ID share the same underlying network instance.

```js
const var nn = Engine.createNeuralNetwork("myModel");
nn.loadPytorchModel(modelJSON);
```

The PyTorch path offers two loading workflows: a single-call `loadPytorchModel` for combined JSON files (layers + weights), or a two-step `build` + `loadWeights` path when topology and weights are managed separately. TensorFlow and NAM models each load in a single call with weights embedded.

For production builds, the compiled RTNeural workflow writes a canonical model JSON into `DspNetworks/NeuralNetworks`. That JSON can include named quality configurations, which are later exposed by `getNetworkInfo` and selected with `setQualityConfiguration`. NAM models can also use metadata-driven gain compensation through `setNAMGainMode`, so scripted tools can choose between raw, loudness-normalised, and calibrated output behaviour.

Compiling neural networks is most useful when a model is used at audio rate through the `math.neural` scriptnode node. In reported LSTM preamp tests, replacing the dynamic RTNeural path with statically generated `ModelT` code roughly halved CPU usage for small one-input LSTM + Dense models. The `fastMath` quality option exists for projects that want another speed-oriented variant, at the cost of not being strictly bit-exact to the default maths provider.

A full compiled roundtrip looks like this:

1. Create a network with the final ID and load a compile-exportable dynamic source model: TensorFlow or NAM.
2. Call `writeCompiledModelJSON` to write `DspNetworks/NeuralNetworks/{id}.json`.
3. Compile the DSP Networks DLL in the HISE backend.
4. Create or reload a network with the same ID.
5. Check that `getNetworkState()` returns `compiled`.

```js
const var nn = Engine.createNeuralNetwork("MyModel");

// 1. Load one compile-exportable dynamic source model.
// TensorFlow:
nn.loadTensorFlowModel(tensorFlowData);

// NAM:
// nn.loadNAMModel(namData);

// PyTorch can be loaded dynamically, but is not currently exportable
// through writeCompiledModelJSON.

// 2. Export canonical compiled neural JSON.
// This writes DspNetworks/NeuralNetworks/MyModel.json.
nn.writeCompiledModelJSON({
    "default": {
        "mathProvider": "default",
        "sampleRateCorrection": "none"
    }
});

// 3. Compile the DSP Networks DLL in the HISE backend.
//
// 4. After compiling/reloading, create a network with the same ID.
const var compiledNN = Engine.createNeuralNetwork("MyModel");

// 5. Confirm that the compiled backend is active.
Console.assertEqual(compiledNN.getNetworkState(), "compiled");
```

`writeCompiledModelJSON` uses the currently loaded source model, so call exactly one compile-exportable loader before exporting. The ID links the dynamic source model, the generated JSON file, and the compiled model registered by the DLL. `DspNetworks/NeuralNetworks` is a compile-source folder, not an import folder and not a runtime asset folder.

> The RTNeural subsystem (PyTorch, TensorFlow, NAM) requires the `HISE_INCLUDE_RT_NEURAL` build flag. The ONNX subsystem is independent and does not require this flag. Model swaps briefly block the audio thread; if a swap is in progress during processing, inference is silently skipped rather than stalling. For audio-rate per-sample processing, use the `math.neural` scriptnode node rather than calling `process` in a script callback - the scriptnode node runs on the audio thread with proper polyphonic voice management.

## Common Mistakes

- **Load a model before calling process**
  **Wrong:** `nn.process(input)` without calling `build()` or a load method first
  **Right:** Call `nn.build(modelJSON)` or `nn.loadPytorchModel(json)` before `nn.process()`
  *The default empty model produces no output. A model must be loaded before inference returns meaningful values.*

- **Do not call loadWeights after loadTensorFlowModel**
  **Wrong:** `nn.loadWeights(weightsJSON)` after `loadTensorFlowModel()`
  **Right:** Use `loadTensorFlowModel()` alone - weights are embedded in the model JSON
  *TensorFlow models include weights in the model JSON. Calling `loadWeights()` on a TensorFlow model returns an error.*

- **Load ONNX model before spectral inference**
  **Wrong:** `nn.processFFTSpectrum(fft, w, h)` without `loadOnnxModel()`
  **Right:** Call `nn.loadOnnxModel(base64Data, numOutputs)` before spectral inference
  *The ONNX model must be loaded before calling `processFFTSpectrum`. Reports a script error otherwise.*

- **Use scriptnode for audio-rate processing**
  **Wrong:** Calling `nn.process(x)` per-sample inside `onTimer` or a script callback
  **Right:** Create the network in script, use the `math.neural` scriptnode node for audio-rate processing
  *Script callbacks cannot sustain per-sample processing at audio rate. The scriptnode node runs on the audio thread with proper buffer handling and voice management.*

- **Switch quality only on compiled networks**
  **Wrong:** `nn.setQualityConfiguration("high")` on a dynamic model loaded from script
  **Right:** Export/register a compiled model first, then switch to an ID listed in `getNetworkInfo().qualityConfigurations`
  *Quality configurations are compiled model variants. Empty and dynamic networks report an error when you try to switch quality.*

- **Check NAM metadata before calibrated gain**
  **Wrong:** Assuming `nn.setNAMGainMode("calibrated")` always changes gain
  **Right:** Check `nn.getNetworkInfo().namHasOutputLevel` before relying on calibrated compensation
  *Calibrated mode only has an effect when the NAM file provides output-level metadata.*

- **Use File.loadAsObject for model JSON**
  **Wrong:** Loading model JSON with `Engine.loadFromJSON()` or manual string parsing
  **Right:** Use `File.loadAsObject()` to parse the exported JSON file, then pass the result directly to `loadPytorchModel`
  *The exported model JSON from the Python exporter is a standard JSON object. `File.loadAsObject()` handles parsing directly.*
