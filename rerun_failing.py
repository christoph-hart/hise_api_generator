"""Re-run only the tests that failed in the last hsc_test_results.json.

Updates only those entries in the report. Pass paths as args to filter
to a subset, or run with no args to retry all prior failures.
"""

import json
import os
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).parent
TESTS_DIR = ROOT / "enrichment" / "tests"
REPORT_PATH = ROOT / "enrichment" / "output" / "hsc_test_results.json"


def run_one(hsc_path: Path) -> dict:
	rel = "./" + str(hsc_path.relative_to(ROOT)).replace(os.sep, "/")
	try:
		proc = subprocess.run(
			f'hise-cli --run "{rel}" --json',
			capture_output=True, text=True, timeout=60,
			cwd=ROOT, shell=True,
		)
	except subprocess.TimeoutExpired:
		return {"path": str(hsc_path.relative_to(TESTS_DIR)),
		        "status": "timeout", "ok": False}

	try:
		data = json.loads(proc.stdout)
	except json.JSONDecodeError:
		return {"path": str(hsc_path.relative_to(TESTS_DIR)),
		        "status": "non_json", "ok": False,
		        "stdout": proc.stdout[-500:], "stderr": proc.stderr[-500:]}

	value = data.get("value", {}) or {}
	expects = value.get("expects", {}) or {}
	return {
		"path": str(hsc_path.relative_to(TESTS_DIR)),
		"ok": data.get("ok", False),
		"linesExecuted": value.get("linesExecuted"),
		"expects_passed": expects.get("passed", 0),
		"expects_total": expects.get("total", 0),
		"error": value.get("error"),
		"failures": value.get("failures", []),
	}


def main():
	report = json.loads(REPORT_PATH.read_text(encoding="utf-8"))
	results = report["results"]

	# Index by path
	by_path = {r["path"]: r for r in results}

	# Filter
	if len(sys.argv) > 1:
		# Args are partial path matches
		filters = sys.argv[1:]
		targets = [r["path"] for r in results
		           if any(f in r["path"] for f in filters)]
	else:
		targets = [r["path"] for r in results if not r.get("ok")]

	print(f"Re-running {len(targets)} test(s)...\n")

	new_pass = 0
	new_fail = 0
	flips_to_pass = []
	flips_to_fail = []

	for path in targets:
		hsc_path = TESTS_DIR / Path(path)
		old = by_path.get(path, {})
		old_ok = old.get("ok", False)

		new = run_one(hsc_path)
		by_path[path] = new

		ok = new.get("ok")
		if ok and not old_ok:
			flips_to_pass.append(path)
		elif not ok and old_ok:
			flips_to_fail.append(path)

		marker = "[PASS]" if ok else "[FAIL]"
		summary = ""
		if not ok:
			err = new.get("error") or {}
			msg = err.get("message", "") if isinstance(err, dict) else ""
			if msg:
				summary = msg.split("\n")[0][:80]
			else:
				fails = new.get("failures", [])
				if fails:
					f = fails[0]
					actual = str(f.get("actual", ""))[:60].replace("\n", "\\n")
					summary = f"actual={actual!r}"

		print(f"  {marker} {path}")
		if summary:
			print(f"      {summary}")

		if ok:
			new_pass += 1
		else:
			new_fail += 1

	# Save updated report
	report["results"] = list(by_path.values())
	REPORT_PATH.write_text(json.dumps(report, indent=2), encoding="utf-8")

	print()
	print(f"This run: pass {new_pass}, fail {new_fail}")
	print(f"Flips to PASS: {len(flips_to_pass)}")
	print(f"Flips to FAIL: {len(flips_to_fail)}")

	if flips_to_fail:
		print("\nNEW REGRESSIONS:")
		for p in flips_to_fail:
			print(f"  {p}")

	# Overall totals
	total_pass = sum(1 for r in by_path.values() if r.get("ok"))
	total = len(by_path)
	print(f"\nOVERALL: {total_pass}/{total} ({total_pass/total*100:.1f}%)")


if __name__ == "__main__":
	main()
