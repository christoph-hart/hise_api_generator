UserPresetHandler (object)
Obtain via: Engine.createUserPresetHandler()

Manages user preset load/save lifecycle, custom automation slots, and host
parameter integration. Supports two data models: default (automatic component
serialization) and custom (script-driven JSON save/load). Custom automation
slots expose named parameters to DAW hosts and MIDI controllers with
connections to processors, meta-parameters, and global cables.

Complexity tiers:
  1. Basic lifecycle: setPostCallback, setPreCallback. React to preset changes
     with UI updates. Default saveInPreset component serialization handles
     everything.
  2. Preset migration: + setEnableUserPresetPreprocessing, isOldVersion. Inspect
     and modify preset data before loading for version migration.
  3. Custom data model with automation: + setUseCustomUserPresetModel,
     setCustomAutomation, attachAutomationCallback, setAutomationValue,
     getAutomationIndex, updateAutomationValues, createObjectForAutomationValues,
     createObjectForSaveInPresetComponents, updateSaveInPresetComponents. Full
     control over preset serialization with DAW-visible automation slots.
   4. Host integration polish: + setParameterGestureCallback,
      sendParameterGesture, setPluginParameterGroupNames,
      setPluginParameterSortFunction, setUseUndoForPresetLoading. Parameter
      gesture tracking, grouping, sort order, and undo support.
   5. Persistence routing: + setStateManagerProperties,
      getStateManagersForTarget. Place MIDI, MPE, and macro state in user
      presets, DAW plugin state, or one external XML file.

Practical defaults:
  - Use setPostCallback as the first entry point for preset-aware logic. It runs
    asynchronously on the message thread after the full load completes.
  - Use setEnableUserPresetPreprocessing(true, false) for version migration.
    Only pass true for shouldUnpackComplexData when you need to inspect
    Base64-encoded data inside the preset.
  - Use SyncNotification for attachAutomationCallback when the callback drives
    audio-thread state (reg variables). Use AsyncNotification when it updates UI.
  - Call setUseCustomUserPresetModel before setCustomAutomation -- the custom
    data model is a prerequisite.
  - Set allowHostAutomation: false on internal/per-layer automation slots.
    Reserve allowHostAutomation: true for user-facing parameters.
   - Pass a Broadcaster to setPostCallback/setPreCallback when multiple systems
     need to react to preset changes independently.
   - Call setStateManagerProperties once during initialization with a static
     object. Omit ExternalFile in production to use the product app-data folder.
   - Use getStateManagersForTarget only as a development-time configuration
     check; results include internal and dynamically registered managers.

Common mistakes:
  - Calling setCustomAutomation without enabling the custom data model first --
    throws "you need to enable setUseCustomDataModel() before calling this
    method".
  - Checking isInternalPresetLoad() outside of pre/post callbacks -- the flag
    retains its stale value from the most recent load.
  - Passing a single object to updateAutomationValues instead of an array --
    throws a script error. Always wrap in an array.
  - Setting allowHostAutomation: true on every slot in a large instrument --
    creates an unusable DAW automation list.
   - Passing non-function callbacks to setUseCustomUserPresetModel -- silently
     does nothing, then setCustomAutomation fails with a confusing error.
   - Shipping a desktop ExternalFile path -- not portable or appropriate for an
     installed product. The default app-data path is the production choice.

Example:
  const var uph = Engine.createUserPresetHandler();

  uph.setPreCallback(function(presetFile)
  {
      // Called synchronously before preset load
      Console.print("Loading: " + presetFile.toString(""));
  });

  uph.setPostCallback(function(presetFile)
  {
      // Called asynchronously after preset load completes
      Console.print("Loaded: " + presetFile.toString(""));
  });

Methods (28):
  attachAutomationCallback             clearAttachedCallbacks
  createObjectForAutomationValues      createObjectForSaveInPresetComponents
  getAutomationIndex                   getSecondsSinceLastPresetLoad
  getStateManagersForTarget            isCurrentlyLoadingPreset
  isInternalPresetLoad                 isOldVersion
  resetToDefaultUserPreset             runTest
  sendParameterGesture                 setAutomationValue
  setCustomAutomation                  setEnableUserPresetPreprocessing
  setParameterGestureCallback          setPluginParameterGroupNames
  setPluginParameterSortFunction       setPostCallback
  setPostSaveCallback                  setPreCallback
  setStateManagerProperties            setUseCustomUserPresetModel
  setUseUndoForPresetLoading           updateAutomationValues
  updateConnectedComponentsFromModuleState  updateSaveInPresetComponents
