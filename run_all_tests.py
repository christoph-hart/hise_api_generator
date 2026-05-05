"""Run all .hsc tests in enrichment/tests/, tally pass/fail, write report."""

import json
import subprocess
import sys
from pathlib import Path
from collections import Counter


TESTS_DIR = Path(__file__).parent / "enrichment" / "tests"
REPORT_PATH = Path(__file__).parent / "enrichment" / "output" / "hsc_test_results.json"


def run_one(hsc_path: Path) -> dict:
	"""Run one .hsc file, return result dict."""
	rel_path = "./" + str(hsc_path.relative_to(Path(__file__).parent)).replace("\\", "/")
	try:
		proc = subprocess.run(
			f'hise-cli --run "{rel_path}" --json',
			capture_output=True, text=True, timeout=60,
			cwd=Path(__file__).parent, shell=True,
		)
	except subprocess.TimeoutExpired:
		return {"path": str(hsc_path), "status": "timeout", "ok": False}

	try:
		data = json.loads(proc.stdout)
	except json.JSONDecodeError:
		return {
			"path": str(hsc_path),
			"status": "non_json",
			"ok": False,
			"stdout": proc.stdout[-500:],
			"stderr": proc.stderr[-500:],
		}

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


def relaunch_hise():
	"""Relaunch HISE after a crash, wait for it to come online."""
	subprocess.run("hise-cli -hise launch", shell=True, capture_output=True, timeout=60)


def is_offline_failure(r: dict) -> bool:
	err = r.get("error") or {}
	msg = err.get("message", "") if isinstance(err, dict) else ""
	return "HISE offline" in msg


def main():
	hsc_files = sorted(TESTS_DIR.rglob("*.hsc"))
	print(f"Running {len(hsc_files)} tests...")

	results = []
	pass_n = 0
	fail_n = 0
	relaunches = 0
	consecutive_offline = 0

	for i, p in enumerate(hsc_files, 1):
		r = run_one(p)

		# Auto-relaunch on consecutive offline failures (HISE crashed)
		if is_offline_failure(r):
			consecutive_offline += 1
			if consecutive_offline >= 2:
				print(f"\n[!] HISE offline x{consecutive_offline} - relaunching...")
				relaunch_hise()
				relaunches += 1
				consecutive_offline = 0
				# Retry the test that just failed
				r = run_one(p)
				if is_offline_failure(r):
					print(f"[!] Still offline after relaunch, skipping {p.name}")
		else:
			consecutive_offline = 0

		results.append(r)
		if r.get("ok"):
			pass_n += 1
			marker = "."
		else:
			fail_n += 1
			marker = "F"
		sys.stdout.write(marker)
		if i % 50 == 0:
			sys.stdout.write(f" {i}/{len(hsc_files)}\n")
		sys.stdout.flush()

	if len(hsc_files) % 50 != 0:
		print(f" {len(hsc_files)}/{len(hsc_files)}")

	print()
	print(f"Passed: {pass_n}/{len(hsc_files)} ({pass_n/max(len(hsc_files),1)*100:.1f}%)")
	print(f"Failed: {fail_n}")
	print(f"HISE relaunches: {relaunches}")

	# Bucket failures by error type
	error_buckets = Counter()
	for r in results:
		if r.get("ok"): continue
		err = r.get("error") or {}
		msg = err.get("message", "") if isinstance(err, dict) else str(err)
		# Strip variable parts
		import re
		key = re.sub(r'\d+', 'N', msg[:80]) if msg else r.get("status", "unknown")
		error_buckets[key] += 1

	if error_buckets:
		print()
		print("Top failure modes:")
		for k, v in error_buckets.most_common(15):
			print(f"  [{v:3d}] {k}")

	REPORT_PATH.parent.mkdir(parents=True, exist_ok=True)
	REPORT_PATH.write_text(json.dumps({
		"summary": {
			"total": len(hsc_files),
			"passed": pass_n,
			"failed": fail_n,
		},
		"results": results,
	}, indent=2), encoding="utf-8")
	print(f"\nFull report: {REPORT_PATH}")


if __name__ == "__main__":
	main()
