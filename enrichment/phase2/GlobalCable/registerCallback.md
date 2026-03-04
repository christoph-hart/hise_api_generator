## registerCallback

**Examples:**

```javascript:async-cable-callback-driving
// Title: Async cable callback driving a UI repaint
// Context: A DSP network writes its output level to a global cable.
// The script registers an async callback to trigger a panel repaint
// whenever the value changes, keeping the visual in sync.

const var rm = Engine.getGlobalRoutingManager();
const var levelCable = rm.getCable("OutputLevel");

reg currentLevel = 0.0;

inline function onLevelChanged(value)
{
    currentLevel = value;
    MeterPanel.repaint();
};

levelCable.registerCallback(onLevelChanged, AsyncNotification);

```
```json:testMetadata:async-cable-callback-driving
{
  "testable": false
}
```


```javascript:multiple-cables-with-a
// Title: Multiple cables with a shared callback pattern
// Context: An envelope editor uses one cable per parameter stage.
// A shared control callback forwards each slider's value through
// its corresponding cable into the DSP network.

const var rm = Engine.getGlobalRoutingManager();

const var attackCable = rm.getCable("EnvAttack");
const var decayCable = rm.getCable("EnvDecay");
const var sustainCable = rm.getCable("EnvSustain");

const var allCables = [attackCable, decayCable, sustainCable];

const var attackKnob = Content.addKnob("Attack", 0, 0);
const var decayKnob = Content.addKnob("Decay", 150, 0);
const var sustainKnob = Content.addKnob("Sustain", 300, 0);

const var allKnobs = [attackKnob, decayKnob, sustainKnob];

// One callback handles all knobs by index lookup
inline function onEnvKnobChanged(component, value)
{
    local idx = allKnobs.indexOf(component);
    allCables[idx].setValueNormalised(value);
};

attackKnob.setControlCallback(onEnvKnobChanged);
decayKnob.setControlCallback(onEnvKnobChanged);
sustainKnob.setControlCallback(onEnvKnobChanged);

```
```json:testMetadata:multiple-cables-with-a
{
  "testable": false
}
```


**Pitfalls:**
- When using `AsyncNotification`, the callback fires on the UI thread at the display refresh rate. If the cable value changes faster than the refresh rate (e.g., from an audio-rate DSP source), intermediate values are silently dropped. This is by design -- you only get the most recent value.
