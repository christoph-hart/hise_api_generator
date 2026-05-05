## getCable

**Examples:**


```javascript:peak-meter-polling
// Title: Reading DSP network output via cable for UI visualization
// Context: A peak meter panel polls a GlobalCable value that a DSP
// network writes to, creating a script-side level display.

const var rm = Engine.getGlobalRoutingManager();
const var peakCable = rm.getCable("OutputPeakLevel");

const var MeterPanel = Content.addPanel("MeterPanel", 0, 0);
MeterPanel.data.level = 0.0;

MeterPanel.setTimerCallback(function()
{
    local currentValue = peakCable.getValue();

    // Simple ballistics: fast attack, slow release
    if (currentValue > this.data.level)
        this.data.level = currentValue;
    else
        this.data.level *= 0.8;

    this.repaint();
});

MeterPanel.startTimer(60);
```
```json:testMetadata:peak-meter-polling
{
  "testable": false,
  "skipReason": "Requires a DSP network writing to the cable; timer-based polling with ballistics produces non-deterministic results"
}
```

```javascript:modulation-matrix-cables
// Title: Connecting cables to global modulators for a modulation matrix
// Context: Each global modulator (envelope, LFO, etc.) is registered
// as a cable so the modulation matrix can route sources to targets.

const var rm = Engine.getGlobalRoutingManager();

const var MODULATORS = [
    ["FlexAHDSR", "AHDSR"],
    ["LFO", "LFO"],
    ["Velocity", "Velocity"],
    ["Random", "Random"]
];

for (m in MODULATORS)
{
    rm.getCable(m[1]).connectToGlobalModulator(m[1], true);
}
```
```json:testMetadata:modulation-matrix-cables
{
  "testable": false,
  "skipReason": "Requires a GlobalModulatorContainer with named modulators in the signal chain"
}
```
