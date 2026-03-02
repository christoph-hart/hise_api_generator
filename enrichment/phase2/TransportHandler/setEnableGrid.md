## setEnableGrid

**Examples:**

```javascript
// Title: Enable grid for drum sequencer with MidiPlayer sync
// Context: A drum machine enables a 1/8 note grid (tempo factor 8) and syncs
// its MidiPlayers to the master clock. The grid provides the timing backbone --
// MidiPlayers follow it automatically via setSyncToMasterClock.
const var th = Engine.createTransportHandler();

// Enable 1/8 note grid for the sequencer
th.setEnableGrid(true, 8);
th.setSyncMode(th.PreferInternal);
th.stopInternalClockOnExternalStop(true);

// Sync all MidiPlayers to the master clock grid
for (i = 0; i < 12; i++)
{
    const var mp = Synth.getMidiPlayer("MIDIPlayer " + (i + 1));
    mp.setSyncToMasterClock(true);
}
```

**Cross References:**
- `MidiPlayer.setSyncToMasterClock` -- When MidiPlayers are synced to the master clock, they follow the grid enabled by `setEnableGrid`. This is how a multi-channel sequencer synchronizes independent channels to a single clock source.
