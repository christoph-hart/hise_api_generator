NeuralNetwork (object)
Obtain via: Engine.createNeuralNetwork(id)

Machine-learning inference engine for PyTorch, TensorFlow, NAM, and ONNX models.
Wraps RTNeural and ONNX runtime for running trained neural networks within HISE.
Two independent subsystems: RTNeural (requires HISE_INCLUDE_RT_NEURAL) for sample-level
inference, ONNX (DLL-based) for spectral classification. Compiled RTNeural models can
be exported as canonical JSON, inspected with getNetworkInfo, and switched between
registered quality configurations. NAM models expose metadata-driven gain modes.
Compiled export currently applies to TensorFlow and NAM source models. PyTorch remains
supported for dynamic loading but does not currently emit canonical compiled-model JSON.

Complexity tiers:
  1. Basic inference: loadPytorchModel or loadTensorFlowModel, process. Load a
     pre-trained model and run inference from script.
  2. Scriptnode integration: Same loading workflow, but the math.neural node in a
     DSP network references the script-created network by ID for audio-rate
     processing with automatic polyphonic channel cloning.
  3. Two-step PyTorch: createModelJSONFromTextFile + build + loadWeights. When
     topology and weights are stored separately.
  4. Production deployment: writeCompiledModelJSON, getNetworkInfo,
     setQualityConfiguration. Export canonical compiled JSON with quality metadata,
     compile/register variants, then switch quality at runtime.
  5. NAM gain metadata: setNAMGainMode, getNetworkInfo. Choose raw, normalized, or
     calibrated output compensation based on NAM metadata.

Practical defaults:
  - Use loadPytorchModel with combined JSON (layers + weights) as the default
    workflow. The two-step build + loadWeights path is only needed when topology
    and weights are managed separately.
  - Use loadTensorFlowModel for TensorFlow models. Weights are embedded in the
    model JSON -- no separate weight loading step.
  - For audio-rate processing, prefer the math.neural scriptnode node over calling
    process per-sample in a script callback.
  - NAM models (loadNAMModel) are fixed-topology wavenets (1-in, 1-out) designed
     for guitar amp modelling. Use them only for that purpose.
  - Use writeCompiledModelJSON({}) when no custom quality configurations are needed.
  - Use TensorFlow or NAM as the dynamic source model for writeCompiledModelJSON.
  - Use getNetworkInfo().qualityConfigurations before setQualityConfiguration().
  - Use mathProvider: "fastMath" only as an opt-in speed variant; default is the
    bit-exact reference choice.
  - Use getNetworkInfo().namHasLoudness / namHasOutputLevel before relying on
    normalized or calibrated NAM gain modes.

Common mistakes:
  - Calling process() without loading a model first -- the default EmptyModel
    produces zeros silently.
  - Calling loadWeights() after loadTensorFlowModel() -- TF models embed weights
    in the model JSON. Returns an error (silently discarded due to Result bug).
  - Calling processFFTSpectrum() without loadOnnxModel() first -- reports a script
    error.
  - Calling process() per-sample in a script callback for audio-rate use -- script
    callbacks run on the message thread. Use the math.neural scriptnode node instead.
  - Loading model JSON with manual string parsing -- use File.loadAsObject() to
     parse the exported JSON, then pass directly to the loader method.
  - Calling setQualityConfiguration on a dynamic model -- only compiled models have
    quality variants.
  - Assuming calibrated NAM gain always changes output -- requires output-level
    metadata in the NAM file.
  - Calling writeCompiledModelJSON after loadPytorchModel -- current PyTorch path
    clears compiledModelJSON and cannot export canonical compiled JSON.

Example:
  // Create a neural network and load a PyTorch model
  const var nn = Engine.createNeuralNetwork("myModel");

  // Load combined PyTorch model (layers + weights in one JSON)
  nn.loadPytorchModel(modelJSON);

  // Run inference
  var result = nn.process(0.5);

Compiled roundtrip:
  const var nn = Engine.createNeuralNetwork("MyModel");
  nn.loadTensorFlowModel(tensorFlowData); // or loadNAMModel(namData)
  nn.writeCompiledModelJSON({
      "default": {
          "mathProvider": "default",
          "sampleRateCorrection": "none"
      }
  });
  // Compile DSP Networks DLL in backend, then reload/create same ID.
  const var compiledNN = Engine.createNeuralNetwork("MyModel");
  Console.assertEqual(compiledNN.getNetworkState(), "compiled");

Methods (17):
  build                        clearModel
  createModelJSONFromTextFile  getModelJSON
  getNetworkInfo               getNetworkState
  loadNAMModel                 loadOnnxModel
  loadPytorchModel             loadTensorFlowModel
  loadWeights                  process
  processFFTSpectrum           reset
  setNAMGainMode               setQualityConfiguration
  writeCompiledModelJSON
