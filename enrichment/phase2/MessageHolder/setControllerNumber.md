## setControllerNumber

**Examples:**


Note that `setControllerNumber(128)` changes the event type to PitchBend as a side effect. If you already set the type to Controller before calling `setControllerNumber(128)`, the type will be silently overwritten to PitchBend. The reverse direction is consistent: `getControllerNumber()` returns 128 for PitchBend events and 129 for Aftertouch events.
