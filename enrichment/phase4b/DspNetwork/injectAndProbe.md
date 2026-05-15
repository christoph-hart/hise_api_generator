DspNetwork::injectAndProbe(JSON injectData, Function reportCallback) -> bool

Thread safety: UNSAFE -- allocates an InjectChecker helper, starts a timer, resolves a container by ID, and mutates injection state guarded by a lock.
Queues a one-shot test signal injection into a supported container and invokes the callback on the message thread when the probed buffer report is ready. Can probe one checkpoint or every child container recursively. Returns false if the container cannot be found, the resolved positions are invalid, or another injection is already pending.
Input object:
  parent: String -- ID of the supported container node that receives the probe request
  injectId: String -- child node ID to inject before; overrides injectIndex if present
  injectIndex: int -- child-node index to inject before; must be in the range 0..numChildren-1
  probeId: String -- child node ID to probe after; overrides probeIndex if present
  probeIndex: int -- child-node index to probe after; must be in the range 0..numChildren-1, -1 = after the last child
  recursive: bool -- true to probe the selected container and all child containers recursively
  signalType: String -- silence|dirac|noise|dc
  gain: double -- injected signal level
  seed: int -- random seed used for noise generation
  delayMs: double -- extra wait time before capturing the probe result
  filter: Object -- optional response filter
  filter.specs: bool -- include specs objects, default true
  filter.signal: bool -- include signal arrays, default true
  filter.compact: bool -- collapse channel reports to peak-value arrays and remove default top-level fields, default false
  filter.tree: bool -- include dense topology tree for recursive reports, default false
  filter.wildcard: String -- reserved, leave at "*" for built-in filter modes
Callback signature: reportCallback(Object report)
Callback payload:
  ok: bool -- true when the report completed successfully
  error: String -- error message, empty on success
  parent: String -- ID of the container node that handled the probe
  factoryPath: String -- factory path of the container that handled the probe
  delayMs: double -- remaining delay value after processing
  injectIndex: int -- resolved internal checkpoint index where the signal was injected
  probeIndex: int -- resolved internal checkpoint index where the signal was probed
  signalType: String -- injected signal type
  gain: double -- injected signal level
  seed: int -- random seed used for noise generation
  recursive: bool -- true when recursive container probing was used
Non-recursive returned object shape:
  specs: Object -- processing specs
  specs.sampleRate: double -- processing sample rate used for the report
  specs.numChannels: int -- number of processed channels
  specs.blockSize: int -- processed block size
  specs.polyphonic: bool -- true when the network was running with an enabled voice index
  specs.processMidi: bool -- true when the target container was in a MIDI-processing context
  signal: Array -- per-channel measurement objects, omitted if filter.signal is false
  signal[].channelIndex: int -- channel number
  signal[].min: double -- minimum sample value in the probed block
  signal[].max: double -- maximum sample value in the probed block
  signal[].avg: double -- average sample value across the probed block
  signal[].peakIndex: int -- sample index of the positive peak
  signal[].silence: bool -- whether the probed block was silent
Recursive returned object shape:
  containers: Object -- container reports keyed by container ID
  containers.<id>.factoryPath: String -- container factory path
  containers.<id>.numChildren: int -- number of direct child nodes
  containers.<id>.specs: Object -- specs for this container, omitted if filter.specs is false
  containers.<id>.children: Array -- direct child reports, omitted if filter.signal is false
  containers.<id>.children[].id: String -- child node ID
  containers.<id>.children[].factoryPath: String -- child node factory path
  containers.<id>.children[].signal: Array -- per-channel measurement objects, or peak-value numbers in compact mode
  tree: Object -- dense topology tree, present only when filter.tree is true
Required setup:
  const var nw = Engine.createDspNetwork("MyNetwork");
Dispatch/mechanics:
  creates InjectChecker -> resolves injectData.parent to NodeContainer
  -> injectId/probeId override injectIndex/probeIndex when present
  -> inject resolves before child N, probe resolves after child N, probeIndex -1 = last child
  -> injectIndex == probeIndex is valid and captures the child output
  -> injectNextBuffer() stores InjectData on each targeted container
  -> audio processing injects/probes the next block -> timer polls until report is ready
Pair with:
  processBlock -- for manual processing workflows
  createTest -- for broader scriptnode testing infrastructure
  $SN.analyse.specs$ -- inspect the processing context at the probe location
Anti-patterns:
  - Do NOT assume the callback is synchronous -- the report is delivered later on the message thread.
  - Do NOT target arbitrary node IDs -- parent must resolve to a supported container implementation, and injectId/probeId must resolve to real child nodes.
  - Do NOT assume probeIndex means "before child N" -- the numeric probe index resolves after child N.
  - Do NOT pass reversed inject/probe positions -- equal positions are valid, but injectIndex must not be greater than probeIndex.
  - Do NOT set filter.wildcard to a custom value unless you want to bypass the built-in specs/signal/compact/tree filtering.
  - Do NOT rely on this in exported plugins -- the probe processing path is backend-only.
Source:
  DspNetwork.cpp  injectAndProbe()
    -> creates NodeContainer::InjectChecker
    -> stores lastInjector to keep the async helper alive
  NodeContainer.h / NodeContainer.cpp
    -> NodeContainer::injectNextBuffer(), ContainerInjector::ScopedProcessor, pollInjectedBuffer()
    -> InjectData::processInject(), processProbe(), reportReady(), poll()
