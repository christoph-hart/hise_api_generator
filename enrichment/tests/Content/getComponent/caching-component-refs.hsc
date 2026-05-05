// setup

# Startup & health check
/hise
/expect status contains online or abort
playground open
/exit

/builder reset

# Setup: UI scaffold
/ui
add ScriptSlider "GainKnob" at 10 10 128 48
add ScriptSlider "MixKnob" at 150 10 128 48
add ScriptButton "BypassBtn" at 300 10 128 32
/exit

/script
/callback onInit
// end setup
for (i = 0; i < 4; i++)
{
    Content.addKnob("Volume" + (i + 1), 10, 60 + i * 50);
    Content.addKnob("Pan" + (i + 1), 150, 60 + i * 50);
}

// Context: getComponent performs a linear search. The standard practice is to
// cache all references as const var during onInit and use those variables
// everywhere else. This is the single most common API call in HiseScript.

Content.makeFrontInterface(900, 600);

// Cache references once at init
const var gainKnob = Content.getComponent("GainKnob");
const var mixKnob = Content.getComponent("MixKnob");
const var bypassBtn = Content.getComponent("BypassBtn");

// Build arrays of related components using a loop
const var NUM_CHANNELS = 4;
const var channelVolumes = [];
const var channelPans = [];

for (i = 0; i < NUM_CHANNELS; i++)
{
    channelVolumes.push(Content.getComponent("Volume" + (i + 1)));
    channelPans.push(Content.getComponent("Pan" + (i + 1)));
}

Console.print(channelVolumes.length); // 4
// test
/compile

# Verify
/expect gainKnob.get("id") is "GainKnob"
/expect channelVolumes.length is 4
/expect channelVolumes[2].get("id") is "Volume3"
/exit
// end test
