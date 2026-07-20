UserPresetHandler::setStateManagerProperties(Object obj) -> undefined

Call scope: INIT
Thread safety: UNSAFE -- performs file I/O, allocates state trees, restores state
managers, and may dispatch MIDI, MPE, or macro updates.

Purpose:
  Selects the persistence target independently for MIDI CC assignments, MPE
  configuration, and macro connections. Call once during initialization with a
  static object.

obj fields:
  SubStates: Object, optional. Default: {}.
    Supported keys:
      MidiAutomation: MIDI CC-to-parameter assignments.
      MPEData: MPE mode and modulator connections.
      macro_controls: macro-to-parameter connections and macro values.
    Each value is either one target String or an Array of target Strings.

  ExternalFile: String, optional.
    Absolute XML file path.
    Default: ExternalPresetData.xml in the product app-data directory.
    Production recommendation: omit this field and use the default app-data
    location. Desktop paths are for temporary development inspection only.

  ExternalFileDefault: Object, optional.
    Used only when ExternalFile is missing or cannot be parsed.
    Only entries whose manager targets External are applied.
    Supported default payloads:
      MidiAutomation: Array in the exact format returned by
      MidiAutomationHandler.getAutomationDataObject() and setUpdateCallback().
      macro_controls: Array in the exact format returned by
      MacroHandler.getMacroDataObject() and setUpdateCallback().
    After applying at least one default payload, the XML file is created.
    Existing valid XML always takes precedence.

ExternalFileDefault.MidiAutomation element fields:
  Controller: Integer. MIDI CC number, 0 through 127.
  Channel: Integer. One-based MIDI channel, 1 through 16, or -1 for omni.
  Processor: String. Target processor ID.
  Attribute: String. Target parameter ID or custom automation ID.
  MacroIndex: Integer. Macro slot index, or -1 for direct mapping.
  Start: Double. Active range start.
  End: Double. Active range end.
  FullStart: Double. Complete range start.
  FullEnd: Double. Complete range end.
  Skew: Double. Range skew factor.
  Interval: Double. Range step size.
  Inverted: Boolean. Reverses the mapping direction when true.
  Converter: String. Encoded value-to-text converter.

ExternalFileDefault.macro_controls element fields:
  MacroIndex: Integer. Zero-based macro slot index.
  Processor: String. Target processor ID.
  Attribute: String or Integer. Parameter ID, custom automation ID, or index.
  CustomAutomation: Boolean. Attribute identifies custom automation when true.
  Start: Double. Active range start.
  End: Double. Active range end.
  FullStart: Double. Complete parameter range start.
  FullEnd: Double. Complete parameter range end.
  Skew: Double. Range skew factor.
  Interval: Double. Range step size.
  Inverted: Boolean. Reverses the mapping direction when true.
  converter: String, optional. Value-to-text converter used while restoring.

Target Strings, case-sensitive:
  Default:
    Bit combination of PluginState and UserPreset. Existing HISE behavior.
  PluginState:
    Saved in DAW plugin state only. Per-instance mappings survive session recall
    and are not changed by user-preset browsing.
  UserPreset:
    Saved in user presets only. Treats assignments as patch data.
  External:
    Omitted from user presets and DAW state. Loaded from one XML file during
    initialization and automatically rewritten after relevant changes.
  None:
    Excluded from automatic persistence.

Target combination rules:
  ["PluginState", "UserPreset"] is equivalent to "Default".
  "External" cannot be combined with PluginState, UserPreset, or Default.
  Unknown SubStates keys or target names report a script error.
  Unspecified managers retain Default.

Persistence scenarios:
  Default      -> mappings follow both presets and DAW sessions.
  PluginState  -> mappings are independent per plugin instance.
  External     -> mappings are shared by instances using the same file.
  UserPreset   -> mappings follow sounds only.
  None         -> scripts own all persistence.

External sharing semantics:
  Instances are not live-synchronized. Each reads the file during initialization
  and writes its complete external state after a relevant change. Latest write
  wins.

Development example:
  const var uph = Engine.createUserPresetHandler();
  const var EXTERNAL_FILE = FileSystem.getFolder(FileSystem.Desktop)
                                      .getChildFile("Mappings.xml")
                                      .toString(0);

  // Desktop override is for development inspection only.
  uph.setStateManagerProperties({
      SubStates:
      {
          MidiAutomation: "External",
          MPEData: "PluginState"
      },
      ExternalFile: EXTERNAL_FILE
  });

  Console.print(trace(uph.getStateManagersForTarget("External")));
  Console.print(trace(uph.getStateManagersForTarget("UserPreset")));
  Console.print(trace(uph.getStateManagersForTarget("PluginState")));

Pair with:
  UserPresetHandler.getStateManagersForTarget -- inspect effective targets.
  MidiAutomationHandler.getAutomationDataObject -- capture MIDI default arrays.
  MidiAutomationHandler.setUpdateCallback -- receives the same MIDI array format.
  MacroHandler.getMacroDataObject -- capture macro default arrays.
  MacroHandler.setUpdateCallback -- receives the same macro array format.

Source:
  ScriptExpansion.cpp  ScriptUserPresetHandler::setStateManagerProperties()
    -> MainController::UserPresetHandler::setStateManagerProperties()
    -> loadExternalPresetData(ExternalFileDefault)
