Reads the file and computes its SHA-256 hash, returning the result as a lowercase hexadecimal string. Useful for verifying file integrity or detecting changes between versions.

> [!Warning:$WARNING_TO_BE_REPLACED$] Reads the entire file into memory for hashing. For very large files this may consume significant memory and block the calling thread.
