## clear

**Examples:**


The `clear` + rebuild pattern is preferred over creating `Content.createPath()` inside callbacks because it reuses the existing object allocation. The path variable should be declared at init scope as `const var`, then cleared and rebuilt as needed.
