TransportHandler::setSyncMode(Integer syncMode) -> undefined

Thread safety: SAFE
Sets the global MasterClock sync mode. Controls which clock source drives transport callbacks, grid, BPM.
Dispatch/mechanics:
  getMasterClock().setSyncMode((MasterClock::SyncModes)syncMode) -- direct delegation, no validation
  The sync mode controls 4 key decision functions:
    shouldPreferInternal() -> true for: InternalOnly, PreferInternal, SyncInternal
    shouldCreateInternalInfo() -> true for: InternalOnly, PreferInternal, SyncInternal (+ PreferExternal when DAW not playing)
    allowExternalSync() -> true for all except InternalOnly
    changeState() -> drops events from the non-preferred clock source
  Per-mode behavior:
    Inactive(0): changeState() returns false, processAndCheckGrid() returns empty, getPPQPos() returns 0
    ExternalOnly(1): internal playhead never created; DAW drives grid via updateFromExternalPlayHead()
    InternalOnly(2): allowExternalSync()=false, DAW events never processed; uptime-based grid
    PreferInternal(3): internal wins conflicts; external accepted when internal idle
    PreferExternal(4): DAW wins conflicts; handoff fires grid resync; internal resumes on DAW stop (unless stopInternalOnExternalStop)
    SyncInternal(5): internal controls start/stop; external stop ignored; uptime overridden by external PPQ in processAndCheckGrid()
  BPM selection (getBpmToUse with linkBpmToSync=true):
    shouldPreferInternal() modes -> internal BPM; others -> host BPM
  External clock source varies by build target:
    Standalone (IS_STANDALONE_APP): BackendProcessor owns ExternalClockSimulator (juce::AudioPlayHead subclass)
      BackendProcessor::processBlock() calls setPlayHead(&externalClockSim) + externalClockSim.process(numSamples)
      Controlled by DAWClockController UI (IDE transport bar)
    Plugin: real DAW AudioPlayHead used directly, ExternalClockSimulator unused
Pair with:
  startInternalClock/stopInternalClock -- internal clock control
  setLinkBpmToSyncMode -- links BPM source to sync mode
  stopInternalClockOnExternalStop -- affects PreferExternal handoff
Source:
  ScriptingApi.cpp:8699  setSyncMode() -> MasterClock::setSyncMode()
  MiscToolClasses.cpp:2219  setSyncMode() stores currentSyncMode
  MiscToolClasses.cpp:2224  changeState() -- sync mode routing logic
  MiscToolClasses.cpp:2516  shouldCreateInternalInfo() -- per-mode playhead decision
  MiscToolClasses.cpp:2592  shouldPreferInternal() -> InternalOnly|PreferInternal|SyncInternal
  MiscToolClasses.cpp:3539  getBpmToUse() -- BPM source selection
  BackendProcessor.cpp:757  setPlayHead(&externalClockSim) -- standalone external clock install
  BackendPanelTypes.h:116  ExternalClockSimulator -- juce::AudioPlayHead subclass for standalone
