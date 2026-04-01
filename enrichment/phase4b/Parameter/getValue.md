Parameter::getValue() -> Double

Thread safety: SAFE
Returns the current parameter value. If the parameter has an active DSP callback,
returns the last value set through that callback. Otherwise falls back to the Value
property in the parameter's ValueTree.

Source:
  NodeBase.cpp:1063  Parameter::getValue()
    -> dynamicParameter->getDisplayValue() if dynamicParameter != nullptr
    -> fallback: data[PropertyIds::Value]
