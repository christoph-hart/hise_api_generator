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
// Context: A DSP network writes peak levels to a cable. The script
// smooths the value for visually stable meter decay.

const var rm = Engine.getGlobalRoutingManager();
const var peakCable = rm.getCable("PeakLevel");

const var MeterPanel = Content.addPanel("PeakMeter", 0, 0);
MeterPanel.data.value = 0.0;

MeterPanel.setTimerCallback(function()
{
    local currentValue = peakCable.getValue();

    // Attack: jump to new peaks immediately
    // Decay: smooth falloff for visual stability
    if (currentValue > this.data.value)
        this.data.value = currentValue;
    else
        this.data.value *= 0.8;

    this.repaint();
});

MeterPanel.startTimer(60);
// test
peakCable.setValue(0.75);
/compile

# Verify
/expect peakCable.getValue() is 0.75
/exit
// end test
