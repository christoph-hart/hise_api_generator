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
Engine.setHostBpm(120);

const var th = Engine.createTransportHandler();

var tempoLog = [];

inline function onTempoChanged(newTempo)
{
    tempoLog.push(newTempo);
}

th.setOnTempoChange(SyncNotification, onTempoChanged);
// test
Engine.setHostBpm(140);
/compile

# Verify
/expect tempoLog.length is 2
/expect tempoLog[0] is 120
/expect tempoLog[1] is 140
/exit
// end test
