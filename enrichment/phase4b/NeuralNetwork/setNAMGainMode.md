NeuralNetwork::setNAMGainMode(JSON modeOrOptions) -> Integer

Thread safety: UNSAFE -- kills voices, runs on sample-loading thread, mutates NAM metadata and compiled JSON.
Sets NAM output gain compensation mode. Accepts either a mode string or object with mode and inputCalibrationLevelDbu.
Input object:
  mode: String -- raw|normalized|calibrated
  inputCalibrationLevelDbu: double -- optional calibration reference for calibrated mode
Required setup:
  const var nn = Engine.createNeuralNetwork("MyNAM");
  nn.loadNAMModel(namData);
Dispatch/mechanics:
  ScriptNeuralNetwork::setNAMGainMode() -> KillStateHandler::killVoicesAndCall(sample-loading thread)
    -> NeuralNetwork::setNAMGainMode(modeOrOptions)
    -> updates namMetadata preferred mode and compiled JSON metadata
Pair with:
  getNetworkInfo -- inspect namHasLoudness, namHasOutputLevel, and calculated namOutputGainDb
  loadNAMModel -- gain mode is only relevant to NAM models
Anti-patterns:
  - Do NOT assume normalized changes gain -- requires namHasLoudness.
  - Do NOT assume calibrated changes gain -- requires namHasOutputLevel.
  - Do NOT pass arbitrary mode strings -- only raw, normalized, calibrated are accepted.
Source:
  ScriptingApiObjects.cpp:6202  ScriptNeuralNetwork::setNAMGainMode()
    -> NeuralNetwork::setNAMGainMode(modeOrOptions)
  hi_neural.cpp:2040  NeuralNetwork::setNAMGainMode()
  hi_neural.cpp:2089  NeuralNetwork::getNAMInputGainDb()/getNAMOutputGainDb()
