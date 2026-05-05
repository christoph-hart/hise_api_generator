// setup

# Startup & health check
/hise
/expect status contains online or abort
playground open
/exit

/builder reset

/script
/callback onInit
// end setup
// Title: Undo/redo a slider value change
const var knob = Content.addKnob("UndoKnob", 0, 0);
knob.set("saveInPreset", false);

var previousValue = 0.5;

inline function onUndoAction(isUndo)
{
    if (isUndo)
        knob.setValue(previousValue);
    else
        knob.setValue(1.0);
};

Engine.performUndoAction({}, onUndoAction);
// test
/compile

# Verify
/expect knob.getValue() is 1.0
/exit
// end test
