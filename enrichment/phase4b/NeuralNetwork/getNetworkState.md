NeuralNetwork::getNetworkState() -> String

Thread safety: WARNING -- returns String, atomic ref-count operations.
Returns coarse backend state: empty, dynamic, or compiled. Both linked and DLL compiled backends return compiled.
Returned object shape:
  empty: String -- no model active
  dynamic: String -- runtime-loaded model active
  compiled: String -- compiled linked or DLL-backed model active
Required setup:
  const var nn = Engine.createNeuralNetwork("MyNAM");
Pair with:
  getNetworkInfo -- use for exact backend subtype and quality metadata
  setQualityConfiguration -- only meaningful when state is compiled
Anti-patterns:
  - Do NOT branch on getNetworkState() when you need compiled-linked vs compiled-dll -- call getNetworkInfo().backend.
  - Do NOT expect a file-based state -- DspNetworks/NeuralNetworks files are compile inputs, not runtime assets.
Source:
  ScriptingApiObjects.cpp:6238  ScriptNeuralNetwork::getNetworkState()
    -> NeuralNetwork::getBackendStateName()
  hi_neural.cpp:1971  NeuralNetwork::getBackendStateName()
