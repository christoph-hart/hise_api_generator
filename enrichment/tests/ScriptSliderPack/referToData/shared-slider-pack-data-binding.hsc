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
// Title: Bind multiple slider packs to one shared data handle
// Context: A lane editor and a compact overview stay in sync by sharing one SliderPackData object.

const var NUM_STEPS = 16;

const var laneData = Engine.createAndRegisterSliderPackData(0);
laneData.setNumSliders(NUM_STEPS);
laneData.setAllValues(0.0);

const var laneEditor = Content.addSliderPack("LaneEditor", 10, 10);
laneEditor.set("sliderAmount", NUM_STEPS);
laneEditor.referToData(laneData);

const var laneOverview = Content.addSliderPack("LaneOverview", 10, 70);
laneOverview.set("sliderAmount", NUM_STEPS);
laneOverview.referToData(laneData);
// test
/compile

# Verify
/expect laneEditor.setSliderAtIndex(5, 0.75) || true is true
/expect laneEditor.getSliderValueAt(5) is 0.75
/expect laneOverview.getSliderValueAt(5) is 0.75
/exit
// end test
