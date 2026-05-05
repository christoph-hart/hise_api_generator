## connectToModuleParameter

**Examples:**


```javascript:clearing-all-module-parameter
// Title: Clearing all module parameter connections
// Context: Before reconfiguring cable routing (e.g., when switching
// between plugin modes), remove all existing module connections.

const var rm = Engine.getGlobalRoutingManager();
const var cable = rm.getCable("RoutingCable");

// Remove all module parameter connections from this cable
cable.connectToModuleParameter("", -1, {});

// Remove connections for a specific processor only
cable.connectToModuleParameter("SimpleGain1", -1, {});

```
```json:testMetadata:clearing-all-module-parameter
{
  "testable": false
}
```


**Pitfalls:**
- The `processorId` must match the module's ID exactly. If the module is not found, a script error is reported. The `parameterIndexOrId` can be either a string name or integer index -- prefer the string form for readability and resilience to parameter reordering.
