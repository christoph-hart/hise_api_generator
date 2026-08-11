#!/usr/bin/env python3

import argparse
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path


DEFAULT_URL = "http://localhost:1900/api/status/preprocessors?verbose=true"


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Regenerate preprocessor.json from the running HISE REST server"
    )
    parser.add_argument(
        "--url",
        default=DEFAULT_URL,
        help=f"REST endpoint URL (default: {DEFAULT_URL})",
    )
    args = parser.parse_args()

    output_path = Path(__file__).resolve().parent / "preprocessor.json"
    temporary_path = output_path.with_suffix(".json.tmp")
    curl = shutil.which("curl")

    if curl is None:
        print("ERROR: curl was not found on PATH", file=sys.stderr)
        return 1

    try:
        result = subprocess.run(
            [
                curl,
                "--fail",
                "--silent",
                "--show-error",
                "--output",
                str(temporary_path),
                args.url,
            ],
            check=False,
        )

        if result.returncode != 0:
            print(f"ERROR: curl failed with exit code {result.returncode}", file=sys.stderr)
            return result.returncode

        with temporary_path.open("r", encoding="utf-8") as stream:
            response = json.load(stream)

        if response.get("success") is not True:
            raise ValueError("REST response did not report success")

        errors = response.get("errors")
        if not isinstance(errors, list) or errors:
            raise ValueError(f"REST response contains errors: {errors!r}")

        preprocessors = response.get("preprocessors")
        if not isinstance(preprocessors, dict) or not preprocessors:
            raise ValueError("REST response does not contain a preprocessor catalogue")

        with temporary_path.open("w", encoding="utf-8", newline="\n") as stream:
            json.dump(response, stream, indent=2, ensure_ascii=False)
            stream.write("\n")

        os.replace(temporary_path, output_path)
        print(f"Wrote {len(preprocessors)} preprocessors to {output_path}")
        return 0
    except (OSError, ValueError) as error:
        print(f"ERROR: {error}", file=sys.stderr)
        return 1
    finally:
        if temporary_path.exists():
            temporary_path.unlink()


if __name__ == "__main__":
    sys.exit(main())
