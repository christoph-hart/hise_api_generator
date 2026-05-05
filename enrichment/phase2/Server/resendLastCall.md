## resendLastCall

**Examples:**


**Pitfalls:**
- `resendLastCall()` only tracks the single most recent GET or POST call. If your workflow makes multiple sequential requests, only the last one can be retried. For multi-step flows, consider tracking the step and re-invoking the appropriate function directly rather than relying on `resendLastCall()`.
