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
const var dc = Content.addDynamicContainer("DC2", 0, 0);
const var cc = dc.setData({"id": "Parent", "type": "Container"});

reg childLog = "";

inline function onChildChange(childId, wasAdded)
{
    childLog = childId + ":" + wasAdded;
}

cc.setChildCallback(onChildChange);
cc.addChildComponent({"id": "NewChild", "type": "Button"});
// childLog is updated asynchronously after onInit
// test
/compile

# Verify
/wait 300ms
/expect childLog is "NewChild:1"
/exit
// end test
