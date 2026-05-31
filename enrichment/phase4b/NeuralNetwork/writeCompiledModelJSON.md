NeuralNetwork::writeCompiledModelJSON(JSON qualityConfigurations) -> Integer

Thread safety: UNSAFE -- backend-only file I/O, directory creation, JSON serialization, file write.
Writes current TensorFlow or NAM model as compiled model JSON to DspNetworks/NeuralNetworks/{id}.json with optional HISE quality configuration metadata.
Input object:
  <qualityId>: Object -- valid Identifier key, eg. low/high/default
  <qualityId>.mathProvider: String -- optional default|fastMath
  <qualityId>.sampleRateCorrection: String -- optional none|linear
Required setup:
  const var nn = Engine.createNeuralNetwork("MyNAM");
  nn.loadTensorFlowModel(tensorFlowData); // or loadNAMModel(namData)
  nn.writeCompiledModelJSON({"high": {"mathProvider": "default", "sampleRateCorrection": "none"}});
Dispatch/mechanics:
  ScriptNeuralNetwork::writeCompiledModelJSON() -> current FileHandler DspNetworks/NeuralNetworks
    -> NeuralNetwork::writeCompiledModelJSON(targetDirectory, qualityConfigurations)
    -> NeuralJsonHelpers::withQualityConfigurations() -> replaceWithText(JSON)
Pair with:
  setQualityConfiguration -- switch to the quality IDs after compiled registration
  getNetworkInfo -- inspect hasCompiledModelJSON and qualityConfigurations
Anti-patterns:
  - Do NOT call in exported plugins -- backend-only, returns false with script error outside USE_BACKEND.
  - Do NOT pass an array -- qualityConfigurations must be an object or empty object.
  - Do NOT use quality IDs that are not valid Identifiers.
  - Do NOT use mathProvider values other than default or fastMath.
  - Do NOT use sampleRateCorrection values other than none or linear.
  - Do NOT call after loadPytorchModel -- current PyTorch path is dynamic-only for this export workflow.
  - Do NOT treat DspNetworks/NeuralNetworks as runtime assets -- it is a compile-source folder.
Source:
  ScriptingApiObjects.cpp:6135  ScriptNeuralNetwork::writeCompiledModelJSON()
    -> NeuralNetwork::writeCompiledModelJSON(neuralFolder, qualityConfigurations)
  hi_neural.cpp:1945  NeuralNetwork::writeCompiledModelJSON()
  hi_neural.cpp:95  NeuralJsonHelpers::validateQualityConfigurations()
