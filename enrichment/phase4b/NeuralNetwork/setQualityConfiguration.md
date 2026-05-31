NeuralNetwork::setQualityConfiguration(String qualityId) -> Integer

Thread safety: UNSAFE -- validates Identifier, kills voices, allocates compiled model clones, resets them, swaps model array under ScopedMultiWriteLock.
Switches a compiled neural network to a named quality configuration and resets the model. Returns false with script error for empty, dynamic, or unknown quality IDs. Unknown IDs report the available configurations.
Required setup:
  const var nn = Engine.createNeuralNetwork("MyNAM");
  var info = nn.getNetworkInfo();
  if (info.qualityConfigurations.contains("high"))
      nn.setQualityConfiguration("high");
Dispatch/mechanics:
  ScriptNeuralNetwork::setQualityConfiguration() -> KillStateHandler::killVoicesAndCall(sample-loading thread)
    -> NeuralNetwork::setQualityConfiguration(Identifier)
    -> factory->create(id, qualityId), clone/reset models, ScopedMultiWriteLock swap
Pair with:
  writeCompiledModelJSON -- writes quality configuration metadata before compile/register workflow
  getNetworkInfo -- list available quality IDs before switching
Anti-patterns:
  - Do NOT call on dynamic models -- quality configurations only apply to compiled models.
  - Do NOT call from high-frequency UI/audio paths -- voice killing and model swap are heavyweight.
  - Do NOT pass display labels with spaces -- qualityId must be a valid Identifier.
  - Do NOT switch to a quality ID that is not listed by getNetworkInfo().qualityConfigurations.
Source:
  ScriptingApiObjects.cpp:6160  ScriptNeuralNetwork::setQualityConfiguration()
    -> NeuralNetwork::setQualityConfiguration(Identifier)
  hi_neural.cpp:1998  NeuralNetwork::setQualityConfiguration()
