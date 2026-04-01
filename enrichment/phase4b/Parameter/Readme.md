Parameter (object)
Obtain via: Node.getOrCreateParameter(indexOrId)

Scriptnode node parameter with value, range properties, and modulation connection
support. Holds a double value within a configurable range and can receive modulation
connections from other nodes or container macro parameters. Provides async (immediate
DSP, no undo) and sync (ValueTree with undo, deferred DSP) value-setting paths.

Constants:
  Range:
    MinValue = "MinValue"    Range minimum property ID
    MaxValue = "MaxValue"    Range maximum property ID
    MidPoint = "MidPoint"    Range skew midpoint property ID
    StepSize = "StepSize"    Step interval property ID

Common mistakes:
  - Calling addConnectionFrom() on an already-automated parameter -- silently
    returns undefined. Remove existing connection first with addConnectionFrom(0).
  - Using p.MidPoint with setRangeProperty() -- silently ignored because MidPoint
    is not a recognized range property ID. Only MinValue, MaxValue, StepSize, and
    SkewFactor are accepted.
  - Calling setValueAsync() before the node's DSP callback is initialized --
    silently ignored with no error.

Example:
  // Get a parameter from a node
  const var p = nd.getOrCreateParameter("Volume");

  // Read current value and range
  var val = p.getValue();
  var range = p.getRangeObject();

  // Set value (immediate DSP update, no undo)
  p.setValueAsync(0.5);

  // Set value (with undo, deferred DSP update)
  p.setValueSync(0.75);

  // Modify range
  p.setRangeProperty(p.MinValue, 0.0);
  p.setRangeProperty(p.MaxValue, 100.0);

Methods (8):
  addConnectionFrom      getId                getRangeObject
  getValue               setRangeFromObject   setRangeProperty
  setValueAsync          setValueSync
