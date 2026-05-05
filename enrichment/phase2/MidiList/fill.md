## fill

**Examples:**


Note the distinction: `fill(0)` sets all slots to zero (useful for counters and flags), while `clear()` sets all slots to `-1` (the "unset" sentinel). Choose based on whether 0 or -1 is the meaningful default for your use case.
