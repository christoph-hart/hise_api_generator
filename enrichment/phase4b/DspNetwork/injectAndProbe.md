DspNetwork::injectAndProbe(JSON injectData, Function reportCallback) -> bool

Thread safety: UNSAFE -- allocates an InjectChecker helper, starts a timer, resolves a container by ID, and mutates injection state guarded by a lock.
Queues a one-shot test signal injection into a supported container and invokes the callback on the message thread when the probed buffer report is ready. Returns false if the container cannot be found or another injection is already pending.
Input object:
  parent: String -- ID of the supported container node that receives the probe request
  injectId: String -- child node ID to inject before; overrides injectIndex if present
  injectIndex: int -- child-node index to inject before; must be in the range 0..numChildren-1
  probeId: String -- child node ID to probe after; overrides probeIndex if present
  probeIndex: int -- child-node index to probe after; must be in the range 0..numChildren-1, -1 = container output after the last child
  signalType: String -- silence|dirac|noise|dc
  gain: double -- injected signal level
  seed: int -- random seed used for noise generation
  delayMs: double -- extra wait time before capturing the probe result
Callback signature: reportCallback(Object report)
Callback payload:
  ok: bool -- true when the report completed successfully
  error: String -- error message, empty on success
  parent: String -- ID of the container node that handled the probe
  delayMs: double -- remaining delay value after processing
  injectIndex: int -- resolved internal checkpoint index where the signal was injected
  probeIndex: int -- resolved internal checkpoint index where the signal was probed
  signalType: String -- injected signal type
  gain: double -- injected signal level
  seed: int -- random seed used for noise generation
  signal: Object -- nested probe report
Returned object shape:
  signal.sampleRate: double -- processing sample rate used for the report
  signal.numChannels: int -- number of processed channels
  signal.blockSize: int -- processed block size
  signal.polyphonic: bool -- true when the network was running with an enabled voice index
  signal.processMidi: bool -- true when the target container was in a MIDI-processing context
  signal.channels: Array -- per-channel measurement objects
  signal.channels[].channelIndex: int -- channel number
  signal.channels[].min: double -- minimum sample value in the probed block
  signal.channels[].max: double -- maximum sample value in the probed block
  signal.channels[].avg: double -- average sample value across the probed block
  signal.channels[].peakIndex: int -- sample index of the positive peak
  signal.channels[].silence: bool -- whether the probed block was silent
Required setup:
  const var nw = Engine.createDspNetwork("MyNetwork");
Dispatch/mechanics:
  creates InjectChecker -> resolves injectData.parent to NodeContainer
  -> injectId/probeId override injectIndex/probeIndex when present
  -> inject resolves before child N, probe resolves after child N, probeIndex -1 = container output
  -> injectNextBuffer() stores InjectData on the container's DynamicSerialProcessor
  -> audio processing injects/probes the next block -> timer polls until report is ready
Pair with:
  processBlock -- for manual processing workflows
  createTest -- for broader scriptnode testing infrastructure
  $SN.analyse.specs$ -- inspect the processing context at the probe location
Anti-patterns:
  - Do NOT assume the callback is synchronous -- the report is delivered later on the message thread.
  - Do NOT target arbitrary node IDs -- parent must resolve to a supported container implementation, and injectId/probeId must resolve to real child nodes.
  - Do NOT assume probeIndex means "before child N" -- the numeric probe index resolves after child N.
  - Do NOT pass equal or reversed inject/probe positions -- the resolved inject checkpoint must be before the resolved probe checkpoint.
  - Do NOT rely on this in exported plugins -- the probe processing path is backend-only.
Source:
  DspNetwork.cpp  injectAndProbe()
    -> creates NodeContainer::InjectChecker
    -> stores lastInjector to keep the async helper alive
  NodeContainer.h / NodeContainer.cpp
    -> DynamicSerialProcessor::injectNextBuffer(), process(), poll()
    -> InjectData::process(), reportReady(), poll()
