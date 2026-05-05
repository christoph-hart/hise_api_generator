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
Content.makeFrontInterface(600, 300);
Content.addKnob("SPKnob1", 10, 10);
Content.setPropertiesFromJSON("SPKnob1", {
  "text": "Volume",
  "width": 128,
  "height": 48,
  "min": 0.0,
  "max": 1.0
});
const var ref = Content.getComponent("SPKnob1");
// test
/compile

# Verify
/expect ref.get("width") is 128
/expect ref.get("text") is "Volume"
/exit
// end test
