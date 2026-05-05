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
// Context: Step sequencer workflows treat the callback value as the edited step index.

const var stepPack = Content.addSliderPack("StepPack", 10, 10);
stepPack.set("sliderAmount", 8);
stepPack.setAllValues([1.0, 0.5, 0.0, 0.75, 0.25, 0.0, 1.0, 0.5]);

const var currentStepValues = [];
for (v in stepPack.getDataAsBuffer())
    currentStepValues.push(v);

reg lastEditedStep = -1;

inline function onStepPackControl(component, value)
{
    local stepIndex = parseInt(value);
    local stepValue = component.getSliderValueAt(stepIndex);

    currentStepValues[stepIndex] = stepValue;
    lastEditedStep = stepIndex;
}

stepPack.setControlCallback(onStepPackControl);
// test
/compile

# Verify
/expect stepPack.setSliderAtIndex(3, 0.9) || true is true
/expect Math.round(stepPack.getSliderValueAt(3) * 10) is 9
/exit
// end test
