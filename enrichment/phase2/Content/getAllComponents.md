## getAllComponents

**Examples:**


**Pitfalls:**
- The pattern uses wildcard matching, not full regex. `".*"` matches everything (optimized fast path), and `"Prefix.*"` matches names starting with "Prefix", but complex regex features may not work as expected.
