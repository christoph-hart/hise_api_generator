NeuralNetwork::getNetworkInfo() -> JSON

Thread safety: UNSAFE -- constructs DynamicObject and Array on heap; backend builds also construct File paths.
Returns diagnostic data for backend state, dimensions, quality configurations, compiled JSON status, and NAM gain metadata.
Returned object shape:
  id: String -- network ID
  state: String -- empty|dynamic|compiled
  backend: String -- empty|dynamic|compiled-linked|compiled-dll
  numInputs: int -- model input count
  numOutputs: int -- model output count
  numNetworks: int -- number of internal model clones
  hasCompiledModelJSON: bool -- true when canonical compiled JSON exists on the network
  activeQualityConfiguration: String -- current quality ID
  qualityConfigurations: Array -- available quality IDs, defaults to ["default"] when no quality metadata exists
  namGainMode: String -- raw|normalized|calibrated
  namInputCalibrationLevelDbu: double -- calibrated mode input reference
  namInputGainDb: double -- current NAM input gain, currently 0.0
  namOutputGainDb: double -- calculated NAM output compensation
  namIsModel: bool -- true if NAM metadata identifies this as a NAM model
  namHasLoudness: bool -- loudness metadata available for normalized mode
  namLoudnessDb: double -- NAM loudness metadata
  namHasInputLevel: bool -- input-level metadata available
  namInputLevelDbu: double -- NAM input-level metadata
  namHasOutputLevel: bool -- output-level metadata available for calibrated mode
  namOutputLevelDbu: double -- NAM output-level metadata
  source: String -- backend-only path to .json or .nam source file
  sourceExists: bool -- backend-only source file existence flag
Required setup:
  const var nn = Engine.createNeuralNetwork("MyNAM");
Dispatch/mechanics:
  ScriptNeuralNetwork::getNetworkInfo() -> nn getters -> DynamicObject fields
    -> backend switch maps exact BackendState to backend string
    -> USE_BACKEND probes DspNetworks/NeuralNetworks/{id}.json, then .nam
Pair with:
  getNetworkState -- coarse state check
  setQualityConfiguration -- use qualityConfigurations before switching
  setNAMGainMode -- inspect NAM metadata and calculated gain
Anti-patterns:
  - Do NOT assume source/sourceExists are available in exported plugins -- they are backend-only fields.
  - Do NOT use state when you need compiled-linked vs compiled-dll -- use backend.
  - Do NOT assume explicit quality metadata exists -- missing hise.qualityConfigurations reports the implicit default variant.
Source:
  ScriptingApiObjects.cpp:6248  ScriptNeuralNetwork::getNetworkInfo()
    -> NeuralNetwork::getBackendStateName(), getQualityConfigurations(), getNAMMetadata()
