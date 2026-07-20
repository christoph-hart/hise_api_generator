UserPresetHandler::getStateManagersForTarget(String targetId) -> Array<String>

Call scope: INIT
Thread safety: UNSAFE -- iterates the registered weak state-manager list and
allocates a result array. Intended as a development-time diagnostic.

Purpose:
  Returns the IDs of every currently registered state manager matching one
  concrete persistence target. Call after setStateManagerProperties() to inspect
  the effective setup.

targetId:
  Case-sensitive String.
  Supported concrete queries:
    "External"
    "UserPreset"
    "PluginState"
  Unknown strings return an empty Array.

Return value:
  Array<String> of matching state-manager IDs.
  Includes internal and dynamically registered managers, not only the
  MidiAutomation, MPEData, and macro_controls entries accepted by SubStates.
  Registration order is an implementation detail; do not depend on exact length
  or ordering.

Default target behavior:
  Default combines PluginState and UserPreset. A manager configured as Default
  therefore appears in both concrete queries.

Example:
  const var uph = Engine.createUserPresetHandler();

  uph.setStateManagerProperties({
      SubStates:
      {
          MidiAutomation: "External",
          MPEData: "PluginState"
      }
  });

  Console.print(trace(uph.getStateManagersForTarget("External")));
  Console.print(trace(uph.getStateManagersForTarget("UserPreset")));
  Console.print(trace(uph.getStateManagersForTarget("PluginState")));

Pair with:
  UserPresetHandler.setStateManagerProperties -- defines the target assignments.

Source:
  ScriptExpansion.cpp  ScriptUserPresetHandler::getStateManagersForTarget()
    -> MainController::UserPresetHandler::getStateManagersForTarget()
