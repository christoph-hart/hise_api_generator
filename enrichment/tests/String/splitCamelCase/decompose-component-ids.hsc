// setup

# Startup & health check
/hise
/expect status contains online or abort
playground open
/exit

/builder reset

# Setup: UI scaffold
/ui
add ScriptSlider "FilterAttack" at 0 0 128 48
add ScriptSlider "FilterDecay" at 100 0 128 48
add ScriptSlider "PlayerAttack" at 200 0 128 48
add ScriptSlider "PlayerDecay" at 300 0 128 48
/exit

/script
/callback onInit
// end setup
// Context: Name components with a convention like "FilterAttack" where the
// first token is the envelope type and the second is the parameter. Then
// splitCamelCase lets a single callback handle all envelope controls.

const var envelopeControls = [Content.getComponent("FilterAttack"),
                              Content.getComponent("FilterDecay"),
                              Content.getComponent("PlayerAttack"),
                              Content.getComponent("PlayerDecay")];

inline function createSortedControls()
{
    local obj = {};
    
    for (e in envelopeControls)
    {
        local tokens = e.getId().splitCamelCase();
        local envelopeType = tokens[0]; // "Filter" or "Player"
        local parameter = tokens[1];    // "Attack" or "Decay"
        
        if (!isDefined(obj[envelopeType]))
            obj[envelopeType] = {};
        
        obj[envelopeType][parameter] = e;
    }
    
    return obj;
}

// Result: { "Filter": { "Attack": ..., "Decay": ... },
//           "Player": { "Attack": ..., "Decay": ... } }
const var sorted = createSortedControls();
// test
/compile

# Verify
/expect sorted.Filter.Attack.get("id") is "FilterAttack"
/expect sorted.Player.Decay.get("id") is "PlayerDecay"
/exit
// end test
