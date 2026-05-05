// setup

# Startup & health check
/hise
/expect status contains online or abort
playground open
/exit

/builder reset

# Setup: module tree
/builder
add MidiPlayer as "MidiPlayer1"
/exit

/script
/callback onInit
// end setup
const var mp = Synth.getMidiPlayer("MidiPlayer1");
mp.setUseTimestampInTicks(true);
mp.create(1, 4, 1);
var setupNotes = [];
var on = Engine.createMessageHolder();
var off = Engine.createMessageHolder();
on.setType(on.NoteOn);
off.setType(on.NoteOff);
on.setNoteNumber(64);
off.setNoteNumber(64);
on.setVelocity(100);
off.setVelocity(0);
on.setChannel(1);
off.setChannel(1);
on.setTimestamp(0);
off.setTimestamp(480);
setupNotes.push(on);
setupNotes.push(off);
mp.flushMessageList(setupNotes);

// Context: Use getNoteRectangleList() inside setPaintRoutine() to render
// all notes from the current sequence, scaled to the panel bounds

const var mp = Synth.getMidiPlayer("MidiPlayer1");
const var PianoRoll = Content.addPanel("PianoRoll", 0, 0);

mp.connectToPanel(PianoRoll);

PianoRoll.setPaintRoutine(function(g)
{
    g.fillAll(0xFF222222);

    var notes = mp.getNoteRectangleList([0, 0, this.getWidth(), this.getHeight()]);

    // Store for verification
    this.data.noteCount = notes.length;

    if (notes.length == 0)
        return;

    g.setColour(0xFFAADDFF);

    for (r in notes)
        g.fillRect(r);

    // Draw playback cursor
    var x = mp.getPlaybackPosition() * this.getWidth();
    g.setColour(Colours.white);
    g.fillRect([x, 0, 2, this.getHeight()]);
});
// test
/compile

# Verify
/expect PianoRoll.data.noteCount > 0 is true
/exit
// end test
