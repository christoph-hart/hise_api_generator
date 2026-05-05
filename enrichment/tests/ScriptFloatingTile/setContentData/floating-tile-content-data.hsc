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
// Title: Configure a floating tile as a preset browser with custom colours
const var ft = Content.addFloatingTile("FloatingTile1", 0, 0);
ft.set("width", 600);
ft.set("height", 400);
ft.setContentData({
    "Type": "PresetBrowser",
    "Font": "Oxygen Bold",
    "FontSize": 16.0,
    "ColourData": {
        "bgColour": "0xFF222222",
        "textColour": "0xFFFFFFFF",
        "itemColour1": "0xFF444444",
        "itemColour2": "0xFF666666"
    }
});
// test
/compile

# Verify
/expect ft.get("ContentType") is "PresetBrowser"
/exit
// end test
