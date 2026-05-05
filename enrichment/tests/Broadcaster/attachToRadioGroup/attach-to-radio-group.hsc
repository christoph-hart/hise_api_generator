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
const var Btn1 = Content.addButton("Btn1", 0, 0);
Btn1.set("radioGroup", 1);
Btn1.set("saveInPreset", false);
const var Btn2 = Content.addButton("Btn2", 130, 0);
Btn2.set("radioGroup", 1);
Btn2.set("saveInPreset", false);
const var Btn3 = Content.addButton("Btn3", 260, 0);
Btn3.set("radioGroup", 1);
Btn3.set("saveInPreset", false);
Btn1.setValue(1);

const var bc = Engine.createBroadcaster({
    "id": "RadioGroup1",
    "args": ["selectedIndex"]
});

var selectedLog = [];

bc.addListener("logger", "radioLog", function(selectedIndex)
{
    selectedLog.push(selectedIndex);
});

bc.attachToRadioGroup(1, "radioSource");
// test
/compile

# Verify
/expect selectedLog.length is 1
/expect selectedLog[0] is 0
/exit
// end test
