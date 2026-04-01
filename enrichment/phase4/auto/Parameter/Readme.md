# Parameter

Parameter represents a single named parameter on a scriptnode node. Each parameter holds a double value within a configurable range and can receive modulation connections from other nodes or container macro parameters.

![Scriptnode Class Hierarchy](topology_scriptnode-hierarchy.svg)

`Parameter` belongs to a `Node` and can be wired to other parameters via `Connection` objects.

Parameter provides two distinct value-setting paths:

| Path | Method | DSP update | Undo | Use case |
|------|--------|------------|------|----------|
| Async | `setValueAsync()` | Immediate | No | Runtime automation, modulation |
| Sync | `setValueSync()` | Deferred (via ValueTree) | Yes | UI interaction, preset recall |

`setValueSync()` stores the value to the ValueTree, which triggers an internal listener that calls `setValueAsync()` - so both paths eventually reach the DSP callback.

You can read and configure the parameter's range properties (minimum, maximum, skew, step size) and create or remove modulation connections from other nodes.

```js
const var p = nd.getOrCreateParameter("Volume");
```

The range system uses four constant identifiers defined on the Parameter object:

| Constant | Value | Description |
|----------|-------|-------------|
| `p.MinValue` | `"MinValue"` | Range minimum property ID |
| `p.MaxValue` | `"MaxValue"` | Range maximum property ID |
| `p.MidPoint` | `"MidPoint"` | Range skew midpoint property ID |
| `p.StepSize` | `"StepSize"` | Step interval property ID |

Use these constants with `setRangeProperty()` to modify individual range properties.

> Parameter objects are obtained from a [Node]($API.Node$) via `Node.getOrCreateParameter()`. If the node's DSP callback is not yet initialised, value-setting calls are silently ignored until the node is fully connected.

## Common Mistakes

- **Remove existing connection before adding a new one**
  **Wrong:** `p.addConnectionFrom(connectionData)` on an already-automated parameter
  **Right:** Remove existing connection first with `p.addConnectionFrom(0)`, then add the new one
  *If the parameter's Automated flag is already true, `addConnectionFrom()` returns empty without creating a connection. No error is raised.*
