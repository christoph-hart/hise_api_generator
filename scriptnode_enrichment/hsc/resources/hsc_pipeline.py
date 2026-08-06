#!/usr/bin/env python3
"""Automation helpers for the scriptnode HSC example pipeline."""

from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import struct
import subprocess
import sys
import time
from dataclasses import dataclass
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
HSC_ROOT = ROOT / "scriptnode_enrichment" / "hsc"
OUTPUT_ROOT = ROOT / "scriptnode_enrichment" / "output"
PUBLISH_OUTPUT = HSC_ROOT / "output"
PHASE4 = HSC_ROOT / "phase4"
PHASE5 = HSC_ROOT / "phase5"
MODULE_RE = re.compile(
    r'^\s*add\s+(?:ScriptFX|ScriptSynth|ScriptModulator|ScriptEnvelopeModulator)\s+as\s+"([^"]+)"',
    re.MULTILINE,
)
MODULE_DECL_RE = re.compile(
    r'^\s*add\s+(ScriptFX|ScriptSynth|ScriptModulator|ScriptEnvelopeModulator)\s+as\s+"([^"]+)"',
    re.MULTILINE,
)
HSC_PARAMETER_RE = re.compile(r'^\s*create_parameter\s+\S+\.([\w]+)\s+', re.MULTILINE)
SHELL_PARAMETER_RE = re.compile(r'\bdsp create_parameter\b[^\n]*?--id\s+(\S+)')
NETWORK_RE = re.compile(r'^\s*set\s+\S+\.network\s+"([^"]+)"', re.MULTILINE)
EXECUTABLE_SIDE_EFFECT_RE = re.compile(r'^\s*(?:save|screenshot)\b', re.MULTILINE)
HSC_PLAYGROUND_OPEN = "/hise playground open"
SHELL_PLAYGROUND_OPEN = 'hise-cli -hise "playground open" --agent'
PHASES = {
    "phase1": ".md",
    "phase2": ".md",
    "phase3": ".md",
    "phase4": ".hsc",
    "phase5": ".llm.md",
}


@dataclass(frozen=True)
class ScreenshotJob:
    factory: str
    node: str
    script: Path
    output: Path
    module_id: str

    @property
    def label(self) -> str:
        return f"{self.factory}.{self.node}"


@dataclass(frozen=True)
class PublishJob:
    factory: str
    node: str
    source_doc: Path
    phase1: Path
    phase2: Path
    phase3: Path
    hsc: Path
    phase5_ref: Path | None = None

    @property
    def label(self) -> str:
        return f"{self.factory}.{self.node}"

    @property
    def output_dir(self) -> Path:
        return PUBLISH_OUTPUT / self.factory


def run_hise(args: list[str], *, retries: int = 0, retry_delay: float = 1.0) -> dict:
    executable = shutil.which("hise-cli")
    if not executable:
        raise RuntimeError("hise-cli was not found on PATH")

    if os.name == "nt" and Path(executable).suffix.lower() in {".bat", ".cmd"}:
        command = [os.environ.get("COMSPEC", "cmd.exe"), "/d", "/c", executable, *args, "--agent"]
    else:
        command = [executable, *args, "--agent"]
    last_error = ""

    for attempt in range(retries + 1):
        proc = subprocess.run(command, cwd=ROOT, text=True, capture_output=True)
        payload = parse_agent_payload(proc.stdout)

        if proc.returncode == 0 and payload.get("ok", False):
            return payload

        last_error = format_failure(command, proc, payload)
        if attempt < retries:
            time.sleep(retry_delay)

    raise RuntimeError(last_error)


def parse_agent_payload(stdout: str) -> dict:
    # hise-cli can emit one JSON object per line. The last object is the command result.
    for line in reversed(stdout.splitlines()):
        line = line.strip()
        if not line:
            continue
        try:
            return json.loads(line)
        except json.JSONDecodeError:
            continue
    return {"ok": False, "error": stdout.strip() or "No JSON response from hise-cli"}


def format_failure(command: list[str], proc: subprocess.CompletedProcess[str], payload: dict) -> str:
    message = payload.get("error") or proc.stderr.strip() or proc.stdout.strip() or "unknown error"
    return f"{' '.join(command)} failed with exit {proc.returncode}: {message}"


def find_jobs(*, force: bool) -> list[ScreenshotJob]:
    jobs: list[ScreenshotJob] = []

    for script in sorted(PHASE4.glob("*/*.hsc")):
        rel = script.relative_to(PHASE4)
        output = PUBLISH_OUTPUT / rel.with_suffix(".png")
        if output.exists() and not force:
            continue

        module_id = read_module_id(script)
        jobs.append(ScreenshotJob(rel.parts[0], rel.stem, script, output, module_id))

    return jobs


def read_module_id(script: Path) -> str:
    text = script.read_text(encoding="utf-8")
    match = MODULE_RE.search(text)
    if not match:
        raise ValueError(
            f"Could not find ScriptFX/ScriptSynth/ScriptModulator/ScriptEnvelopeModulator module id in {script}"
        )
    return match.group(1)


def png_dimensions(path: Path) -> tuple[int, int]:
    with path.open("rb") as handle:
        signature = handle.read(24)
    if len(signature) < 24 or signature[:8] != b"\x89PNG\r\n\x1a\n":
        raise ValueError(f"Not a valid PNG: {path}")
    return struct.unpack(">II", signature[16:24])


def screenshot_jobs(jobs: list[ScreenshotJob], args: argparse.Namespace) -> int:
    if not jobs:
        print("No missing Phase 5 screenshots.")
        return 0

    failures = 0
    print("factory.node | screenshot path | dimensions | success | loopback needed")

    for job in jobs:
        try:
            job.output.parent.mkdir(parents=True, exist_ok=True)
            run_hise(["run", str(job.script)])
            time.sleep(args.ui_delay)
            run_hise(
                [
                    "dsp",
                    "screenshot",
                    "--module",
                    job.module_id,
                    "--scale",
                    args.scale,
                    "--output",
                    str(job.output),
                ],
                retries=args.retries,
                retry_delay=args.retry_delay,
            )
            width, height = png_dimensions(job.output)
            print(f"{job.label} | {job.output.relative_to(ROOT)} | {width}x{height} | yes | no")
        except Exception as exc:  # noqa: BLE001 - batch should continue and report all failures.
            failures += 1
            print(f"{job.label} | {job.output.relative_to(ROOT)} | n/a | no | unknown")
            print(f"  error: {exc}", file=sys.stderr)

    return 1 if failures else 0


def inventory(args: argparse.Namespace) -> int:
    targets = collect_targets(include_readmes=args.include_readmes)
    target_count = len(targets)

    print("HSC pipeline inventory")
    print(f"Target docs: {target_count} files in {OUTPUT_ROOT.relative_to(ROOT)}")
    print("")
    print("phase | processed | coverage | remaining | extras")

    phase_sets = {phase: collect_phase_nodes(phase, suffix) for phase, suffix in PHASES.items()}
    for phase, nodes in phase_sets.items():
        processed = len(nodes & targets)
        remaining = target_count - processed
        extras = len(nodes - targets)
        coverage = percentage(processed, target_count)
        print(f"{phase} | {processed} | {coverage} | {remaining} | {extras}")

    published = collect_published_nodes()
    published_processed = len(published & targets)
    print(
        f"published | {published_processed} | {percentage(published_processed, target_count)} | "
        f"{target_count - published_processed} | {len(published - targets)}"
    )

    print("")
    print("latest phase | nodes")
    latest_counts = count_latest_phases(targets, phase_sets)
    for label in ["unstarted", *PHASES.keys()]:
        print(f"{label} | {latest_counts[label]}")

    if args.by_factory:
        print("")
        print("factory | target | phase1 | phase2 | phase3 | phase4 | phase5 | published")
        for factory in sorted({node.split("/", 1)[0] for node in targets}):
            factory_targets = {node for node in targets if node.startswith(f"{factory}/")}
            counts = [len(phase_sets[phase] & factory_targets) for phase in PHASES]
            counts.append(len(published & factory_targets))
            print(f"{factory} | {len(factory_targets)} | " + " | ".join(str(count) for count in counts))

    return 0


def collect_targets(*, include_readmes: bool) -> set[str]:
    targets: set[str] = set()
    for path in OUTPUT_ROOT.rglob("*.md"):
        if not include_readmes and path.name.lower() == "readme.md":
            continue
        targets.add(node_key(path, OUTPUT_ROOT))
    return targets


def collect_phase_nodes(phase: str, suffix: str) -> set[str]:
    phase_root = HSC_ROOT / phase
    if not phase_root.exists():
        return set()
    return {node_key(path, phase_root) for path in phase_root.rglob(f"*{suffix}")}


def collect_published_nodes() -> set[str]:
    if not PUBLISH_OUTPUT.exists():
        return set()
    nodes = set()
    for json_path in PUBLISH_OUTPUT.glob("*/*.json"):
        png_path = json_path.with_suffix(".png")
        key = node_key(json_path, PUBLISH_OUTPUT)
        llm_path = json_path.with_suffix(".llm.md")
        if png_path.exists() and llm_path.exists():
            nodes.add(key)
    return nodes


def node_key(path: Path, root: Path) -> str:
    rel = path.relative_to(root)
    if rel.name.endswith(".llm.md"):
        return rel.with_name(rel.name[: -len(".llm.md")]).as_posix()
    return rel.with_suffix("").as_posix()


def percentage(value: int, total: int) -> str:
    if total == 0:
        return "0.0%"
    return f"{(value / total) * 100:.1f}%"


def count_latest_phases(targets: set[str], phase_sets: dict[str, set[str]]) -> dict[str, int]:
    counts = {"unstarted": 0, **{phase: 0 for phase in PHASES}}
    ordered_phases = list(PHASES.keys())

    for target in targets:
        latest = "unstarted"
        for phase in ordered_phases:
            if target in phase_sets[phase]:
                latest = phase
        counts[latest] += 1

    return counts


def publish(args: argparse.Namespace) -> int:
    try:
        jobs = find_publish_jobs(node_filter=args.node)
    except FileNotFoundError as exc:
        print(str(exc), file=sys.stderr)
        return 1
    if not jobs:
        if args.node:
            print(f"No publishable authored Phase 5 example found for {args.node}.", file=sys.stderr)
            return 1
        print("No authored Phase 5 examples to publish.")
        return 0

    issues = validate_jobs(jobs, check_duplicate_ids=True)
    if issues:
        print_validation_issues(issues)
        print("Publish aborted before running HISE.", file=sys.stderr)
        return 1

    failures = 0
    print("factory.node | json | llmRef | screenshot | success")

    for job in jobs:
        try:
            payload = build_publish_payload(job)
            job.output_dir.mkdir(parents=True, exist_ok=True)

            json_path = job.output_dir / f"{job.node}.json"
            llm_path = job.output_dir / f"{job.node}.llm.md"
            screenshot_path = job.output_dir / f"{job.node}.png"

            run_hise(["run", str(job.hsc)])
            time.sleep(args.ui_delay)
            run_hise(
                [
                    "dsp",
                    "screenshot",
                    "--module",
                    read_module_id(job.hsc),
                    "--scale",
                    args.scale,
                    "--output",
                    str(screenshot_path),
                ],
                retries=args.retries,
                retry_delay=args.retry_delay,
            )

            png_dimensions(screenshot_path)

            json_path.write_text(json.dumps(payload, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
            shutil.copyfile(job.phase5_ref, llm_path)

            print(
                f"{job.label} | {json_path.relative_to(ROOT)} | {llm_path.relative_to(ROOT)} | "
                f"{screenshot_path.relative_to(ROOT)} | yes"
            )
        except Exception as exc:  # noqa: BLE001 - publish should report every failing artifact.
            failures += 1
            print(f"{job.label} | n/a | n/a | n/a | no")
            print(f"  error: {exc}", file=sys.stderr)

    return 1 if failures else 0


def find_publish_jobs(*, node_filter: str | None) -> list[PublishJob]:
    jobs: list[PublishJob] = []

    scripts = sorted(PHASE4.glob("*/*.hsc"))
    for script in scripts:
        rel = script.relative_to(PHASE4)
        factory = rel.parts[0]
        node = rel.stem
        label = f"{factory}.{node}"
        if node_filter and node_filter != label:
            continue

        paths = {
            "source_doc": OUTPUT_ROOT / rel.with_suffix(".md"),
            "phase1": HSC_ROOT / "phase1" / rel.with_suffix(".md"),
            "phase2": HSC_ROOT / "phase2" / rel.with_suffix(".md"),
            "phase3": HSC_ROOT / "phase3" / rel.with_suffix(".md"),
            "hsc": script,
            "phase5_ref": PHASE5 / rel.with_suffix(".llm.md"),
        }
        missing = [name for name, path in paths.items() if not path.exists()]
        if missing:
            message = f"Skipping {label}: missing {', '.join(missing)}"
            if node_filter:
                raise FileNotFoundError(message)
            print(message, file=sys.stderr)
            continue

        jobs.append(PublishJob(factory, node, **paths))

    return jobs


def draft_llmref(args: argparse.Namespace) -> int:
    job = find_example_job(args.node)
    print(build_llm_ref(build_draft_payload(job)))
    return 0


def find_example_job(label: str) -> PublishJob:
    if "." not in label:
        raise ValueError("--node must be a factory path like dynamics.gate")
    factory, node = label.split(".", 1)
    rel = Path(factory) / f"{node}.hsc"
    paths = {
        "source_doc": OUTPUT_ROOT / factory / f"{node}.md",
        "phase1": HSC_ROOT / "phase1" / factory / f"{node}.md",
        "phase2": HSC_ROOT / "phase2" / factory / f"{node}.md",
        "phase3": HSC_ROOT / "phase3" / factory / f"{node}.md",
        "hsc": PHASE4 / rel,
    }
    missing = [name for name, path in paths.items() if not path.exists()]
    if missing:
        raise FileNotFoundError(f"Cannot build draft for {label}: missing {', '.join(missing)}")
    return PublishJob(factory, node, **paths)


def build_publish_payload(job: PublishJob) -> dict:
    payload = build_draft_payload(job)
    meta, body = parse_authored_ref(read_text(job.phase5_ref))
    payload.update(meta)
    payload["body"] = body
    payload["llmRef"] = body
    payload["text"] = build_semantic_text(meta)
    return payload


def build_draft_payload(job: PublishJob) -> dict:
    source_text = read_text(job.source_doc)
    phase1_text = read_text(job.phase1)
    phase2_text = read_text(job.phase2)
    phase3_text = read_text(job.phase3)
    hsc_script = read_text(job.hsc)

    source_meta = parse_frontmatter(source_text)
    scenario = parse_keyed_section(markdown_section(phase1_text, "Scenario"))
    support_nodes = parse_support_nodes(markdown_section(phase1_text, "Support Nodes"))
    assumptions = parse_keyed_section(markdown_section(phase1_text, "Assumptions"))
    naming = parse_keyed_section(markdown_section(phase3_text, "Naming"))
    builder_setup = parse_keyed_section(markdown_section(phase3_text, "Builder Setup Applied"))

    command_list = first_fenced_block(markdown_section(phase3_text, "Optimized Public Shell Commands"))
    graph_plan = first_fenced_block(markdown_section(phase2_text, "Graph Plan"))
    public_parameters = list_items(markdown_section(phase2_text, "Public Parameters"))
    locked_values = list_items(markdown_section(phase3_text, "Locked Build Values Applied"))
    verified_parameters = list_items(markdown_section(phase3_text, "Verified Parameters"))
    verified_connections = list_items(markdown_section(phase3_text, "Verified Connections"))
    comments_to_preserve = list_items(markdown_section(phase3_text, "Comments To Preserve In HSC"))
    defaults_omitted = list_items(markdown_section(phase3_text, "Defaults Omitted"))
    open_issues = list_items(markdown_section(phase3_text, "Open Issues"))
    trace_validation = parse_trace_validation(markdown_section(phase3_text, "Trace Validation"))

    description = source_meta.get("description") or scenario.get("Project context") or ""
    payload = {
        "schemaVersion": 1,
        "id": job.label,
        "factory": job.factory,
        "node": job.label,
        "slug": job.node,
        "name": source_meta.get("title") or title_from_node(job.node),
        "description": description,
        "scenario": {
            "title": scenario.get("Title", ""),
            "projectContext": scenario.get("Project context", ""),
            "teachingGoal": scenario.get("Teaching goal", ""),
        },
        "supportNodes": support_nodes,
        "assumptions": assumptions,
        "builderSetup": {
            "moduleId": naming.get("Module ID", ""),
            "networkId": naming.get("Network ID", ""),
            "details": builder_setup,
        },
        "graphPlan": graph_plan,
        "publicParameters": public_parameters,
        "gotchas": source_meta.get("commonMistakes", []),
        "lockedBuildValues": locked_values,
        "verifiedParameters": verified_parameters,
        "verifiedConnections": verified_connections,
        "traceValidation": trace_validation,
        "commentsToPreserve": comments_to_preserve,
        "defaultsOmitted": defaults_omitted,
        "openIssues": open_issues,
        "commandList": command_list,
        "hscScript": hsc_script,
        "screenshot": f"{job.node}.png",
        "screenshotUrl": f"/data/v2/scriptnode-examples/{job.factory}/{job.node}.png",
    }
    return payload


def parse_authored_ref(text: str) -> tuple[dict, str]:
    if not text.startswith("---\n"):
        raise ValueError("Authored Phase 5 reference must start with YAML frontmatter")
    end = text.find("\n---", 4)
    if end == -1:
        raise ValueError("Authored Phase 5 reference is missing closing frontmatter marker")

    frontmatter = text[4:end].splitlines()
    body = text[end + 4 :].strip()
    meta = parse_simple_yaml(frontmatter)
    required = [
        "id",
        "node",
        "domain",
        "category",
        "title",
        "summary",
        "useCase",
        "difficulty",
        "networkName",
        "moduleType",
        "moduleId",
        "tags",
        "aliases",
        "relatedNodes",
    ]
    missing = [key for key in required if not meta.get(key)]
    if missing:
        raise ValueError(f"Authored Phase 5 reference is missing required frontmatter: {', '.join(missing)}")
    return meta, body


def parse_simple_yaml(lines: list[str]) -> dict:
    data: dict[str, object] = {}
    current_key = ""
    for line in lines:
        if not line.strip():
            continue
        if not line.startswith(" ") and ":" in line:
            key, value = line.split(":", 1)
            current_key = key.strip()
            value = value.strip()
            if value:
                data[current_key] = unquote_yaml(value)
            else:
                data[current_key] = {} if current_key == "parameters" else []
        elif line.startswith("  - ") and current_key:
            current = data.setdefault(current_key, [])
            if not isinstance(current, list):
                raise ValueError(f"YAML key {current_key} cannot mix list and mapping values")
            current.append(unquote_yaml(line.strip()[2:].strip()))
        elif line.startswith("  ") and current_key:
            current = data.setdefault(current_key, {})
            if not isinstance(current, dict):
                raise ValueError(f"YAML key {current_key} cannot mix mapping and list values")
            key, value = line.strip().split(":", 1)
            current[key.strip()] = unquote_yaml(value.strip())
    return data


def build_semantic_text(meta: dict) -> str:
    parameters = meta.get("parameters", {})
    parameter_names = ", ".join(parameters.keys()) if isinstance(parameters, dict) else ""
    parts = [
        str(meta.get("title", "")),
        f"Primary node: {meta.get('node', '')}.",
        str(meta.get("summary", "")),
        str(meta.get("useCase", "")),
        "Related nodes: " + ", ".join(meta.get("relatedNodes", [])) + ".",
        "Tags: " + ", ".join(meta.get("tags", [])) + ".",
        "Aliases: " + ", ".join(meta.get("aliases", [])) + ".",
    ]
    if parameter_names:
        parts.append("Key parameters: " + parameter_names + ".")
    return "\n".join(part for part in parts if part.strip())


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def parse_frontmatter(text: str) -> dict:
    if not text.startswith("---\n"):
        return {}
    end = text.find("\n---", 4)
    if end == -1:
        return {}

    lines = text[4:end].splitlines()
    data: dict = {}
    index = 0
    while index < len(lines):
        line = lines[index]
        if line.startswith("title:"):
            data["title"] = unquote_yaml(line.split(":", 1)[1].strip())
        elif line.startswith("description:"):
            data["description"] = unquote_yaml(line.split(":", 1)[1].strip())
        elif line.startswith("factoryPath:"):
            data["factoryPath"] = unquote_yaml(line.split(":", 1)[1].strip())
        elif line.startswith("commonMistakes:"):
            mistakes, index = parse_common_mistakes(lines, index + 1)
            data["commonMistakes"] = mistakes
            continue
        index += 1
    return data


def parse_common_mistakes(lines: list[str], start: int) -> tuple[list[dict], int]:
    mistakes: list[dict] = []
    current: dict | None = None
    index = start

    while index < len(lines):
        line = lines[index]
        if line and not line.startswith(" "):
            break
        stripped = line.strip()
        if stripped.startswith("- title:"):
            current = {"title": unquote_yaml(stripped.split(":", 1)[1].strip())}
            mistakes.append(current)
        elif current is not None and ":" in stripped:
            key, value = stripped.split(":", 1)
            current[key] = unquote_yaml(value.strip())
        index += 1

    return mistakes, index


def unquote_yaml(value: str) -> str:
    if len(value) >= 2 and value[0] == value[-1] and value[0] in {'"', "'"}:
        return value[1:-1]
    return value


def markdown_section(text: str, heading: str) -> str:
    pattern = re.compile(rf"^## {re.escape(heading)}\s*$", re.MULTILINE)
    match = pattern.search(text)
    if not match:
        return ""
    start = match.end()
    next_match = re.search(r"^## ", text[start:], re.MULTILINE)
    end = start + next_match.start() if next_match else len(text)
    return text[start:end].strip()


def parse_keyed_section(section: str) -> dict[str, object]:
    data: dict[str, object] = {}
    current_key = ""
    for line in section.splitlines():
        stripped = line.strip()
        if stripped.startswith("- ") and ":" in stripped:
            key, value = stripped[2:].split(":", 1)
            current_key = key.strip()
            data[current_key] = parse_scalar(value.strip())
        elif stripped.startswith("- ") and current_key and stripped != "-":
            existing = data.setdefault(current_key, [])
            if not isinstance(existing, list):
                existing = [] if existing == "" else [existing]
                data[current_key] = existing
            value = parse_scalar(stripped[2:].strip())
            if value is not None:
                existing.append(value)
    return {key: clean_empty_values(value) for key, value in data.items()}


def parse_support_nodes(section: str) -> dict[str, object]:
    data = parse_keyed_section(section)
    for key in ("Required", "Optional"):
        value = data.get(key)
        if isinstance(value, str):
            data[key] = parse_inline_list(value)
    return {
        "required": data.get("Required", []),
        "optional": data.get("Optional", []),
        "rationale": data.get("Rationale", ""),
    }


def parse_scalar(value: str) -> object:
    value = value.strip()
    if value.lower() == "true":
        return True
    if value.lower() == "false":
        return False
    if value.lower() == "none":
        return None
    if len(value) >= 2 and value[0] == value[-1] == "`":
        return value[1:-1]
    return value


def clean_empty_values(value: object) -> object:
    if isinstance(value, list):
        return [item for item in value if item not in (None, "")]
    return value


def parse_inline_list(value: str) -> list[str]:
    value = value.strip()
    if value.startswith("[") and value.endswith("]"):
        value = value[1:-1]
    if not value or value.lower() == "none":
        return []
    items = []
    for part in value.split(","):
        item = part.strip().strip("`[]")
        item = item.replace("`", "")
        if item:
            items.append(item)
    return items


def first_fenced_block(section: str) -> str:
    match = re.search(r"```(?:\w+)?\s*\n(.*?)\n```", section, re.DOTALL)
    return match.group(1).strip() if match else ""


def list_items(section: str) -> list[str]:
    items: list[str] = []
    for line in section.splitlines():
        stripped = line.strip()
        if stripped.startswith("- "):
            items.append(stripped[2:].strip())
    return items


def parse_trace_validation(section: str) -> dict[str, list[str]]:
    return {
        "commands": section_items_after_label(section, "commands"),
        "evidence": section_items_after_label(section, "evidence"),
        "caveats": section_items_after_label(section, "caveats"),
    }


def section_items_after_label(section: str, label: str) -> list[str]:
    items: list[str] = []
    capture = False
    for line in section.splitlines():
        stripped = line.strip()
        if stripped.startswith("- ") and stripped.lower().endswith(":"):
            capture = label in stripped.lower()
            continue
        if capture and stripped.startswith("- "):
            items.append(stripped[2:].strip())
    return items


def title_from_node(node: str) -> str:
    return node.replace("_", " ").title()


def build_llm_ref(payload: dict) -> str:
    lines: list[str] = [f"scriptnode example: {payload['id']}", ""]
    scenario = payload["scenario"]
    if scenario.get("title"):
        lines.extend([str(scenario["title"]), ""])
    if payload.get("description"):
        lines.extend([str(payload["description"]), ""])
    if scenario.get("projectContext"):
        lines.extend(["Context:", indent(str(scenario["projectContext"])), ""])
    if scenario.get("teachingGoal"):
        lines.extend(["Use this when:", indent(str(scenario["teachingGoal"])), ""])

    if payload.get("graphPlan"):
        lines.extend(["Graph:", "```text", str(payload["graphPlan"]), "```", ""])

    builder = payload["builderSetup"]
    lines.extend(["Host setup:"])
    if builder.get("moduleId"):
        lines.append(indent(f"Module: {builder['moduleId']}"))
    if builder.get("networkId"):
        lines.append(indent(f"Network: {builder['networkId']}"))
    details = builder.get("details", {})
    if isinstance(details, dict):
        for key, value in details.items():
            if value not in (None, "", []):
                lines.append(indent(f"{key}: {value}"))
    lines.append("")

    support = payload.get("supportNodes", {})
    if support:
        lines.extend(["Support nodes:"])
        if support.get("required"):
            lines.append(indent("Required: " + ", ".join(support["required"])))
        if support.get("optional"):
            lines.append(indent("Optional: " + ", ".join(support["optional"])))
        if support.get("rationale"):
            lines.append(indent(str(support["rationale"])))
        lines.append("")

    if payload.get("commentsToPreserve"):
        lines.extend(["Key construction rules:", *bullet_lines(payload["commentsToPreserve"]), ""])
    if payload.get("publicParameters"):
        lines.extend(["Public controls:", *bullet_lines(payload["publicParameters"]), ""])
    if payload.get("verifiedConnections"):
        lines.extend(["Verified connections:", *bullet_lines(payload["verifiedConnections"]), ""])

    trace = payload.get("traceValidation", {})
    if trace.get("evidence") or trace.get("caveats"):
        lines.extend(["Validated behavior:"])
        lines.extend(bullet_lines(trace.get("evidence", [])))
        lines.extend(bullet_lines(trace.get("caveats", [])))
        lines.append("")

    mistakes = payload.get("gotchas", [])
    if mistakes:
        lines.extend(["Common mistakes:"])
        for mistake in mistakes:
            title = mistake.get("title", "")
            explanation = mistake.get("explanation") or mistake.get("right") or ""
            lines.append(indent(f"- {title}: {explanation}" if explanation else f"- {title}"))
        lines.append("")

    if payload.get("defaultsOmitted"):
        lines.extend(["Intentional defaults omitted:", *bullet_lines(payload["defaultsOmitted"]), ""])

    lines.extend(["HISE CLI build commands:", "```bash", payload.get("commandList", ""), "```"])
    return "\n".join(lines).rstrip()


def indent(text: str) -> str:
    return "\n".join(f"  {line}" if line else "" for line in text.splitlines())


def bullet_lines(items: list[str]) -> list[str]:
    return [indent(f"- {item}") for item in items]


def validate(args: argparse.Namespace) -> int:
    try:
        jobs = find_publish_jobs(node_filter=args.node)
    except FileNotFoundError as exc:
        print(str(exc), file=sys.stderr)
        return 1
    if not jobs:
        message = f"No complete example found for {args.node}." if args.node else "No complete examples found."
        print(message, file=sys.stderr)
        return 1

    issues = validate_jobs(jobs, check_duplicate_ids=True)
    if issues:
        print_validation_issues(issues)
        return 1
    print(f"Validated {len(jobs)} example(s): no issues found.")
    return 0


def executable_lines(text: str) -> list[str]:
    """Return normalized HSC commands, excluding blank and comment-only lines."""
    return [line.strip() for line in text.splitlines() if line.strip() and not line.lstrip().startswith("#")]


def validate_hsc_script(text: str, label: str) -> list[str]:
    lines = executable_lines(text)
    issues: list[str] = []
    expected_preamble = [HSC_PLAYGROUND_OPEN, "/builder", "reset"]

    if lines[:3] != expected_preamble:
        issues.append(
            f"{label}: HSC executable lines must start with "
            f"{HSC_PLAYGROUND_OPEN!r}, '/builder', 'reset'"
        )
    if lines.count(HSC_PLAYGROUND_OPEN) != 1:
        issues.append(f"{label}: HSC must contain {HSC_PLAYGROUND_OPEN!r} exactly once")

    for line in lines:
        normalized = " ".join(line.lower().split())
        if normalized.startswith("/hise playground close") or normalized.startswith("/hise playground disable"):
            issues.append(f"{label}: public HSC must not close or disable the Playground")
            break
    return issues


def validate_shell_activation(commands: str, label: str, phase: str) -> list[str]:
    lines = executable_lines(commands)
    issues: list[str] = []
    if not lines or lines[0] != SHELL_PLAYGROUND_OPEN:
        issues.append(f"{label}: {phase} command block must start with {SHELL_PLAYGROUND_OPEN!r}")
    if lines.count(SHELL_PLAYGROUND_OPEN) != 1:
        issues.append(f"{label}: {phase} command block must contain Playground activation exactly once")
    for line in lines:
        normalized = " ".join(line.lower().split())
        if "playground close" in normalized or "playground disable" in normalized:
            issues.append(f"{label}: {phase} command block must not close or disable the Playground")
            break
    return issues


def validate_hsc(args: argparse.Namespace) -> int:
    if args.node:
        if "." not in args.node:
            print("--node must be a factory path like dynamics.gate", file=sys.stderr)
            return 1
        factory, node = args.node.split(".", 1)
        scripts = [PHASE4 / factory / f"{node}.hsc"]
        if not scripts[0].is_file():
            print(f"No Phase 4 HSC found for {args.node}.", file=sys.stderr)
            return 1
    else:
        scripts = sorted(PHASE4.glob("*/*.hsc"))
        if not scripts:
            print("No Phase 4 HSC scripts found.", file=sys.stderr)
            return 1

    issues: list[str] = []
    for script in scripts:
        label = node_key(script, PHASE4).replace("/", ".")
        try:
            issues.extend(validate_hsc_script(read_text(script), label))
        except OSError as exc:
            issues.append(f"{label}: could not read HSC: {exc}")
    if issues:
        print_validation_issues(issues)
        return 1
    print(f"Validated {len(scripts)} Phase 4 HSC script(s): no issues found.")
    return 0


def validate_jobs(jobs: list[PublishJob], *, check_duplicate_ids: bool) -> list[str]:
    issues: list[str] = []
    for job in jobs:
        try:
            issues.extend(validate_job(job))
        except Exception as exc:  # noqa: BLE001 - validation must report malformed artifacts together.
            issues.append(f"{job.label}: could not validate artifacts: {exc}")

    if check_duplicate_ids:
        ids: dict[str, list[str]] = {}
        for path in sorted(PHASE5.glob("*/*.llm.md")):
            try:
                meta, _ = parse_authored_ref(read_text(path))
                ids.setdefault(str(meta["id"]), []).append(node_key(path, PHASE5))
            except (KeyError, ValueError):
                continue
        for example_id, nodes in ids.items():
            if len(nodes) > 1:
                issues.append(f"phase5: duplicate id {example_id!r} used by {', '.join(nodes)}")
    return issues


def validate_job(job: PublishJob) -> list[str]:
    issues: list[str] = []
    expected = job.label
    source = read_text(job.source_doc)
    phase1 = read_text(job.phase1)
    phase2 = read_text(job.phase2)
    phase3 = read_text(job.phase3)
    hsc = read_text(job.hsc)
    phase5 = read_text(job.phase5_ref)

    source_meta = parse_frontmatter(source)
    identities = {
        "source factoryPath": source_meta.get("factoryPath"),
        "phase1 heading": parse_heading_identity(phase1),
        "phase1 Factory path": parse_labeled_value(phase1, "Factory path"),
        "phase2 heading": parse_heading_identity(phase2),
        "phase3 heading": parse_heading_identity(phase3),
    }
    for location, value in identities.items():
        if value != expected:
            issues.append(f"{expected}: {location} is {value!r}, expected {expected!r}")

    status = parse_keyed_section(markdown_section(phase3, "Status"))
    for key in ("Built in HISE", "User approved"):
        if status.get(key) is not True:
            issues.append(f"{expected}: Phase 3 {key} must be true")

    phase2_naming = parse_keyed_section(markdown_section(phase2, "Naming"))
    phase3_naming = parse_keyed_section(markdown_section(phase3, "Naming"))
    module_match = MODULE_DECL_RE.search(hsc)
    network_match = NETWORK_RE.search(hsc)
    meta, body = parse_authored_ref(phase5)
    module_type = module_match.group(1) if module_match else ""
    module_id = module_match.group(2) if module_match else ""
    network_id = network_match.group(1) if network_match else ""
    consistency = {
        "Phase 2 module ID": phase2_naming.get("Module ID"),
        "Phase 3 module ID": phase3_naming.get("Module ID"),
        "Phase 5 moduleId": meta.get("moduleId"),
    }
    for location, value in consistency.items():
        if value != module_id:
            issues.append(f"{expected}: {location} is {value!r}, HSC uses {module_id!r}")
    for location, value in {
        "Phase 2 network ID": phase2_naming.get("Network ID"),
        "Phase 3 network ID": phase3_naming.get("Network ID"),
        "Phase 5 networkName": meta.get("networkName"),
    }.items():
        if value != network_id:
            issues.append(f"{expected}: {location} is {value!r}, HSC uses {network_id!r}")
    if meta.get("moduleType") != module_type:
        issues.append(f"{expected}: Phase 5 moduleType is {meta.get('moduleType')!r}, HSC uses {module_type!r}")

    phase2_host = parse_keyed_section(markdown_section(phase2, "Builder Setup")).get("Host context")
    phase3_host = parse_keyed_section(markdown_section(phase3, "Builder Setup Applied")).get("Host context")
    expected_host = {
        "ScriptFX": "Script FX",
        "ScriptSynth": "Script Synth",
        "ScriptModulator": "Script Modulator",
        "ScriptEnvelopeModulator": "Script Envelope",
    }.get(module_type)
    for location, value in (("Phase 2 host context", phase2_host), ("Phase 3 host context", phase3_host)):
        if value != expected_host:
            issues.append(f"{expected}: {location} is {value!r}, expected {expected_host!r}")

    hsc_nodes = parse_hsc_nodes(hsc)
    issues.extend(validate_hsc_script(hsc, expected))
    if not any(node_type == expected for node_type, _, _ in hsc_nodes):
        issues.append(f"{expected}: HSC does not contain the primary node")
    if EXECUTABLE_SIDE_EFFECT_RE.search(hsc):
        issues.append(f"{expected}: HSC contains executable save or screenshot commands")

    phase3_commands = first_fenced_block(markdown_section(phase3, "Optimized Public Shell Commands"))
    phase5_commands = first_fenced_block_after_label(body, "HISE CLI build commands")
    issues.extend(validate_shell_activation(phase3_commands, expected, "Phase 3"))
    issues.extend(validate_shell_activation(phase5_commands, expected, "Phase 5"))
    if phase3_commands != phase5_commands:
        issues.append(f"{expected}: Phase 3 and Phase 5 command blocks must match exactly")

    phase2_nodes = parse_graph_nodes(first_fenced_block(markdown_section(phase2, "Graph Plan")))
    phase3_nodes = parse_shell_nodes(phase3_commands)
    phase5_nodes = parse_shell_nodes(phase5_commands)
    for location, nodes in (("Phase 2 graph", phase2_nodes), ("Phase 3 commands", phase3_nodes), ("Phase 5 commands", phase5_nodes)):
        if set(nodes) != set(hsc_nodes):
            issues.append(f"{expected}: {location} topology does not match HSC topology")

    required_support = parse_support_nodes(markdown_section(phase1, "Support Nodes"))["required"]
    hsc_types = {node_type for node_type, _, _ in hsc_nodes}
    for support in required_support:
        if support not in hsc_types:
            issues.append(f"{expected}: required Phase 1 support node {support!r} is absent from HSC")
    phase5_support = parse_body_support(body)
    for support in phase5_support:
        if support not in hsc_types:
            issues.append(f"{expected}: required Phase 5 support node {support!r} is absent from HSC")

    hsc_parameters = set(HSC_PARAMETER_RE.findall(hsc))
    phase3_parameters = set(SHELL_PARAMETER_RE.findall(phase3_commands))
    phase5_parameters = set(SHELL_PARAMETER_RE.findall(phase5_commands))
    phase2_parameters = set(re.findall(r'^-\s+([A-Za-z]\w*)\s+->', markdown_section(phase2, "Public Parameters"), re.MULTILINE))
    for location, parameters in (
        ("Phase 2 public controls", phase2_parameters),
        ("Phase 3 commands", phase3_parameters),
        ("Phase 5 commands", phase5_parameters),
    ):
        if parameters != hsc_parameters:
            issues.append(f"{expected}: {location} controls do not match HSC public controls")

    hsc_connections = parse_hsc_connections(hsc)
    for location, commands in (
        ("Phase 3 commands", phase3_commands),
        ("Phase 5 commands", phase5_commands),
    ):
        if parse_shell_connections(commands) != hsc_connections:
            issues.append(f"{expected}: {location} connections do not match HSC connections")

    issues.extend(validate_phase5_schema(job, meta, body))
    return issues


def validate_phase5_schema(job: PublishJob, meta: dict, body: str) -> list[str]:
    issues: list[str] = []
    label = job.label
    string_fields = ("id", "node", "domain", "category", "title", "summary", "useCase", "difficulty", "networkName", "moduleType", "moduleId")
    for key in string_fields:
        if not isinstance(meta.get(key), str) or not meta[key].strip():
            issues.append(f"{label}: Phase 5 {key} must be a non-empty string")
    for key in ("tags", "aliases", "relatedNodes"):
        value = meta.get(key)
        if not isinstance(value, list) or not value or not all(isinstance(item, str) and item for item in value):
            issues.append(f"{label}: Phase 5 {key} must be a non-empty string list")
    parameters = meta.get("parameters")
    if not isinstance(parameters, dict) or not parameters or not all(
        isinstance(key, str) and key and isinstance(value, str) and value for key, value in parameters.items()
    ):
        issues.append(f"{label}: Phase 5 parameters must be a non-empty string mapping")
    enums = {
        "domain": {"scriptnode"},
        "category": {"dsp-network"},
        "difficulty": {"beginner", "intermediate", "advanced"},
        "moduleType": {"ScriptFX", "ScriptSynth", "ScriptModulator", "ScriptEnvelopeModulator"},
    }
    for key, allowed in enums.items():
        if meta.get(key) not in allowed:
            issues.append(f"{label}: Phase 5 {key} must be one of {', '.join(sorted(allowed))}")
    if meta.get("node") != label:
        issues.append(f"{label}: Phase 5 node must be {label!r}")
    if label not in meta.get("relatedNodes", []):
        issues.append(f"{label}: Phase 5 relatedNodes must include the primary node")
    if not body or not re.search(rf'^scriptnode example:\s*{re.escape(label)}\s*$', body, re.MULTILINE):
        issues.append(f"{label}: Phase 5 body must identify the primary node")
    for section in ("Graph:", "Host:", "Support nodes:", "Key rules:", "Public controls:", "HISE CLI build commands:"):
        if section not in body:
            issues.append(f"{label}: Phase 5 body is missing {section}")
    return issues


def parse_heading_identity(text: str) -> str:
    match = re.search(r'^#\s+([^\s]+)\s+-\s+HSC\b', text, re.MULTILINE)
    return match.group(1) if match else ""


def parse_labeled_value(text: str, label: str) -> str:
    match = re.search(rf'^-\s+{re.escape(label)}:\s+`?([^`\s]+)`?\s*$', text, re.MULTILINE)
    return match.group(1) if match else ""


def parse_hsc_nodes(text: str) -> list[tuple[str, str, str | None]]:
    nodes = []
    pattern = re.compile(r'^\s*add\s+([\w.]+)\s+as\s+"([^"]+)"(?:\s+to\s+(\S+))?\s*$')
    for line in text.splitlines():
        match = pattern.match(line)
        if match and "." in match.group(1):
            nodes.append((match.group(1), match.group(2), match.group(3)))
    return nodes


def parse_shell_nodes(text: str) -> list[tuple[str, str, str | None]]:
    nodes = []
    for line in text.splitlines():
        if " dsp add " not in line:
            continue
        node_type = re.search(r'--type\s+(\S+)', line)
        node_id = re.search(r'--id\s+(\S+)', line)
        parent = re.search(r'--parent\s+(\S+)', line)
        if node_type and node_id:
            nodes.append((node_type.group(1), node_id.group(1), parent.group(1) if parent else None))
    return nodes


def parse_graph_nodes(text: str) -> list[tuple[str, str, str | None]]:
    nodes = []
    parents: list[tuple[int, str]] = []
    for line in text.splitlines():
        path_marker = re.match(r'^(\s+)([A-Za-z]\w*(?:[._][A-Za-z]\w*)+)\s*$', line)
        if path_marker:
            indent = len(path_marker.group(1))
            while parents and parents[-1][0] >= indent:
                parents.pop()
            parents.append((indent, path_marker.group(2)))
            continue
        match = re.match(r'^(\s+)([A-Za-z]\w*)\s+([\w.]+)\s*$', line)
        if match and "." in match.group(3):
            indent = len(match.group(1))
            while parents and parents[-1][0] >= indent:
                parents.pop()
            parent = parents[-1][1] if parents else None
            nodes.append((match.group(3), match.group(2), parent))
            parents.append((indent, match.group(2)))
    return nodes


def parse_hsc_connections(text: str) -> set[tuple[str, str, bool]]:
    pattern = re.compile(r'^\s*connect\s+(\S+)\s+to\s+(\S+)(?:\s+(matched))?\s*$', re.MULTILINE)
    return {(source, target, mode == "matched") for source, target, mode in pattern.findall(text)}


def parse_shell_connections(text: str) -> set[tuple[str, str, bool]]:
    connections = set()
    for line in text.splitlines():
        if " dsp connect " not in line:
            continue
        source = re.search(r'--source\s+(\S+)', line)
        source_param = re.search(r'--source-param\s+(\S+)', line)
        target = re.search(r'--target\s+(\S+)', line)
        target_param = re.search(r'--param\s+(\S+)', line)
        if source and target and target_param:
            source_name = source.group(1)
            if source_param:
                source_name += "." + source_param.group(1)
            connections.add((source_name, target.group(1) + "." + target_param.group(1), "--matched" in line))
    return connections


def first_fenced_block_after_label(text: str, label: str) -> str:
    index = text.find(label)
    return first_fenced_block(text[index:]) if index >= 0 else ""


def parse_body_support(body: str) -> list[str]:
    match = re.search(r'^\s+Required:\s+(.+)$', body, re.MULTILINE)
    return re.findall(r'`([^`]+)`', match.group(1)) if match else []


def print_validation_issues(issues: list[str]) -> None:
    print(f"Validation failed with {len(issues)} issue(s):", file=sys.stderr)
    for issue in issues:
        print(f"- {issue}", file=sys.stderr)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    subparsers = parser.add_subparsers(dest="command", required=True)

    screenshots = subparsers.add_parser(
        "screenshots",
        help="Generate disposable screenshots in hsc/output for Phase 4 .hsc files missing PNGs.",
    )
    screenshots.add_argument("--force", action="store_true", help="Regenerate screenshots even when PNGs already exist.")
    screenshots.add_argument("--scale", default="200%", help="Screenshot scale passed to hise-cli. Default: 200%%.")
    screenshots.add_argument(
        "--ui-delay",
        type=float,
        default=1.5,
        help="Seconds to wait after loading a script before taking the screenshot. Default: 1.5.",
    )
    screenshots.add_argument("--retries", type=int, default=2, help="Screenshot retry count. Default: 2.")
    screenshots.add_argument(
        "--retry-delay",
        type=float,
        default=1.0,
        help="Seconds to wait between screenshot retries. Default: 1.0.",
    )
    screenshots.set_defaults(func=lambda ns: screenshot_jobs(find_jobs(force=ns.force), ns))

    inventory_parser = subparsers.add_parser(
        "inventory",
        help="Report target documentation count and HSC processing coverage by phase.",
    )
    inventory_parser.add_argument(
        "--include-readmes",
        action="store_true",
        help="Include Readme.md files from output in the target count.",
    )
    inventory_parser.add_argument(
        "--by-factory",
        action="store_true",
        help="Include a per-factory coverage table.",
    )
    inventory_parser.set_defaults(func=inventory)

    draft_parser = subparsers.add_parser(
        "draft-llmref",
        help="Print a verbose Phase 5 authoring draft for one node to stdout.",
    )
    draft_parser.add_argument(
        "--node",
        required=True,
        help="Node factory path, eg dynamics.gate.",
    )
    draft_parser.set_defaults(func=draft_llmref)

    validate_parser = subparsers.add_parser(
        "validate",
        help="Validate completed example artifacts without running HISE or writing output.",
    )
    validate_parser.add_argument(
        "--node",
        help="Validate one node by factory path, eg dynamics.gate. Defaults to all completed examples.",
    )
    validate_parser.set_defaults(func=validate)

    validate_hsc_parser = subparsers.add_parser(
        "validate-hsc",
        help="Validate Phase 4 HSC Playground safety without requiring Phase 5 artifacts.",
    )
    validate_hsc_parser.add_argument(
        "--node",
        help="Validate one node by factory path, eg dynamics.gate. Defaults to all Phase 4 scripts.",
    )
    validate_hsc_parser.set_defaults(func=validate_hsc)

    publish_parser = subparsers.add_parser(
        "publish",
        help="Build website and MCP artifacts from completed HSC example phases.",
    )
    publish_parser.add_argument(
        "--node",
        help="Publish one node by factory path, eg dynamics.comp. Defaults to all completed Phase 5 examples.",
    )
    publish_parser.add_argument("--scale", default="200%", help="Screenshot scale passed to hise-cli. Default: 200%%.")
    publish_parser.add_argument(
        "--ui-delay",
        type=float,
        default=1.5,
        help="Seconds to wait after loading a script before taking the screenshot. Default: 1.5.",
    )
    publish_parser.add_argument("--retries", type=int, default=2, help="Screenshot retry count. Default: 2.")
    publish_parser.add_argument(
        "--retry-delay",
        type=float,
        default=1.0,
        help="Seconds to wait between screenshot retries. Default: 1.0.",
    )
    publish_parser.set_defaults(func=publish)

    parser.set_defaults(
        scale="200%",
        ui_delay=1.5,
        retries=2,
        retry_delay=1.0,
        force=False,
        include_readmes=False,
        by_factory=False,
    )
    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    return args.func(args)


if __name__ == "__main__":
    raise SystemExit(main())
