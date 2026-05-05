## isOnline

**Examples:**


**Pitfalls:**
- Do not call `isOnline()` as a routine pre-check before every server request. The request callback already receives `status == 0` on timeout, which is a non-blocking alternative for detecting connectivity issues. Reserve `isOnline()` for situations where you need a definitive answer before proceeding, such as showing an error panel or triggering a retry flow.
