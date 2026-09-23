# hise-cli bug report: DSP rename field mapping

## Summary

`hise-cli dsp rename` sends the wrong field names to `/api/dsp/apply`.

## Reproduction

Build a network containing a node named `clone_child`, then run:

```bash
hise-cli dsp rename --module CloneRenameProbe --node clone_child --id RenamedChild --agent
```

## Actual result

The command reaches the DSP `set_id` operation but fails with:

```text
set_id requires 'target'
```

The network remains loaded and unchanged.

## Expected request

The CLI should translate the command to this operation:

```json
{
  "op": "set_id",
  "target": "clone_child",
  "name": "RenamedChild"
}
```

## Suspected mapping

The CLI currently appears to send the source node as `nodeId` and the new ID as `id`. The DSP API contract uses `target` and `name` for `set_id`.

## Suggested fix

Update the CLI DSP rename command mapper to emit `target` and `name`. Keep the operation atomic and preserve the existing error handling.
