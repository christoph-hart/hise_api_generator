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
// Context: When a multi-dimensional data structure must have consistent
// sizes, assertEqual catches mismatches before they cause index errors.

const var NUM_CHANNELS = 4;
const var NUM_MODES = 3;
const var NUM_BANKS = 2;

const var dataPackList = [];
for (i = 0; i < NUM_BANKS * NUM_CHANNELS * NUM_MODES; i++)
    dataPackList.push(i);

Console.assertEqual(NUM_BANKS * NUM_CHANNELS * NUM_MODES, dataPackList.length);
// test
/compile

# Verify
/expect dataPackList.length is 24
/exit
// end test
