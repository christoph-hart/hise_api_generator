Engine::createDspNetwork(String id) -> ScriptObject

Thread safety: UNSAFE -- heap allocation, XML parsing in backend, ValueTree setup
Creates or retrieves a scriptnode DSP network with the given ID. The script processor
must be a DspNetwork::Holder (Script FX or Script Synth with scriptnode). If a network
with the same ID already exists, it is returned (no duplicate created).
Anti-patterns:
  - Do NOT call on a plain Script Processor -- only Script FX and Script Synth with
    scriptnode support can create DSP networks. Produces script error otherwise.
Pair with:
  getDspNetworkReference -- access a network from another processor
Source:
  ScriptingApi.cpp  Engine::createDspNetwork()
    -> DspNetwork::Holder::getOrCreate(id)
    -> checks for existing .xml in DspNetworks folder (backend)
