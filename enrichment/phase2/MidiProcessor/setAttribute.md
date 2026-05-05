## setAttribute

**Examples:**

```javascript:arpeggiator-ui-control
// Title: Controlling a built-in Arpeggiator from a UI callback
// Context: MidiProcessor handles to built-in modules expose dynamic constants
// for each parameter. Use these instead of raw indices.

const var arp = Synth.getMidiProcessor("Arpeggiator1");

// Dynamic constants like NumStepSlider and SequenceComboBox are
// registered at construction time from the module's parameter list
inline function onStepCountChanged(component, value)
{
    arp.setAttribute(arp.NumStepSlider, value);
}

inline function onDirectionChanged(component, value)
{
    // 1 = Up, 2 = Down, 3 = Up+Down, 5 = Random
    arp.setAttribute(arp.SequenceComboBox, parseInt(value));
}

Content.getComponent("StepCount").setControlCallback(onStepCountChanged);
Content.getComponent("Direction").setControlCallback(onDirectionChanged);
```
```json:testMetadata:arpeggiator-ui-control
{
  "testable": false,
  "skipReason": "Callback-driven pattern requiring an Arpeggiator module and UI components"
}
```

```javascript:articulation-switching-muters
// Title: Controlling another script processor's parameters
// Context: When one script processor controls another, use dynamic constants
// from the target module. For articulation switching, muters use an
// ignoreButton parameter to gate MIDI to specific sample groups.

const var sustainMuter = Synth.getMidiProcessor("SustainMuter");
const var staccatoMuter = Synth.getMidiProcessor("StaccatoMuter");
const var legatoScript = Synth.getMidiProcessor("LegatoHandler");

inline function setArticulation(index)
{
    // Each muter's ignoreButton constant maps to its mute toggle parameter
    sustainMuter.setAttribute(sustainMuter.ignoreButton, index != 0);
    staccatoMuter.setAttribute(staccatoMuter.ignoreButton, index != 1);

    // Script processors also expose their parameters as dynamic constants
    legatoScript.setAttribute(legatoScript.btnMute, index != 2);
}
```
```json:testMetadata:articulation-switching-muters
{
  "testable": false,
  "skipReason": "Requires multiple named MIDI processor modules with specific parameter layouts"
}
```


