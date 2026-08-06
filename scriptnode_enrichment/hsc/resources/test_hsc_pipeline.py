from __future__ import annotations

import argparse
import contextlib
import importlib.util
import io
import sys
import tempfile
import unittest
from pathlib import Path
from unittest import mock


MODULE_PATH = Path(__file__).with_name("hsc_pipeline.py")
SPEC = importlib.util.spec_from_file_location("hsc_pipeline", MODULE_PATH)
pipeline = importlib.util.module_from_spec(SPEC)
assert SPEC.loader is not None
sys.modules[SPEC.name] = pipeline
SPEC.loader.exec_module(pipeline)


class ParserTests(unittest.TestCase):
    def test_agent_payload_uses_last_json_line(self) -> None:
        self.assertEqual(pipeline.parse_agent_payload('noise\n{"ok": false}\n{"ok": true, "value": 2}\n')["value"], 2)

    def test_markdown_and_yaml_parsers(self) -> None:
        text = "## Status\n\n- Built in HISE: true\n- User approved: false\n"
        self.assertEqual(
            pipeline.parse_keyed_section(pipeline.markdown_section(text, "Status")),
            {"Built in HISE": True, "User approved": False},
        )
        self.assertEqual(
            pipeline.parse_simple_yaml(["tags:", "  - alpha", "parameters:", "  Gain: useful"]),
            {"tags": ["alpha"], "parameters": {"Gain": "useful"}},
        )

    def test_subcommand_is_required_and_validate_accepts_node(self) -> None:
        parser = pipeline.build_parser()
        with self.assertRaises(SystemExit), contextlib.redirect_stderr(io.StringIO()):
            parser.parse_args([])
        args = parser.parse_args(["validate", "--node", "dynamics.gate"])
        self.assertEqual(args.command, "validate")
        self.assertEqual(args.node, "dynamics.gate")
        hsc_args = parser.parse_args(["validate-hsc", "--node", "dynamics.gate"])
        self.assertEqual(hsc_args.command, "validate-hsc")
        self.assertEqual(hsc_args.node, "dynamics.gate")

    def test_hsc_playground_preamble_ignores_comments(self) -> None:
        script = "#!/usr/bin/env hise-cli run\n# note\n\n/hise playground open\n/builder\nreset\nadd ScriptFX as \"Safe\"\n"
        self.assertEqual(pipeline.validate_hsc_script(script, "test.safe"), [])

    def test_hsc_playground_rejects_missing_out_of_order_and_duplicate_open(self) -> None:
        cases = {
            "missing": "/builder\nreset\n",
            "out of order": "/builder\n/hise playground open\nreset\n",
            "duplicate": "/hise playground open\n/builder\nreset\n/hise playground open\n",
        }
        for name, script in cases.items():
            with self.subTest(name=name):
                self.assertTrue(pipeline.validate_hsc_script(script, f"test.{name}"))

    def test_hsc_playground_rejects_close_and_disable(self) -> None:
        for command in ("/hise playground close", "/hise   playground   disable"):
            script = f"/hise playground open\n/builder\nreset\n{command}\n"
            with self.subTest(command=command):
                issues = pipeline.validate_hsc_script(script, "test.unsafe")
                self.assertTrue(any("close or disable" in issue for issue in issues))

    def test_shell_activation_must_be_exact_first_command(self) -> None:
        safe = '# comment\nhise-cli -hise "playground open" --agent\nhise-cli builder reset --agent\n'
        self.assertEqual(pipeline.validate_shell_activation(safe, "test.safe", "Phase 3"), [])
        unsafe = 'hise-cli builder reset --agent\nhise-cli -hise "playground open" --agent\n'
        self.assertTrue(pipeline.validate_shell_activation(unsafe, "test.unsafe", "Phase 3"))


class PipelineTests(unittest.TestCase):
    @staticmethod
    def current_jobs():
        return pipeline.find_publish_jobs(node_filter=None)

    def test_current_examples_validate(self) -> None:
        jobs = self.current_jobs()
        self.assertEqual([job.label for job in jobs], [
            "dynamics.comp",
            "dynamics.envelope_follower",
            "dynamics.gate",
            "dynamics.limiter",
            "dynamics.updown_comp",
            "math.abs",
            "math.add",
            "math.clear",
            "math.clip",
            "math.div",
            "math.fill1",
            "math.fmod",
            "math.intensity",
            "math.inv",
            "math.map",
            "math.mod2sig",
            "math.mod_inv",
            "math.mul",
            "math.pi",
            "math.pow",
            "math.rect",
            "math.sig2mod",
            "math.sin",
            "math.sqrt",
            "math.square",
            "math.sub",
            "math.tanh",
            "routing.selector",
        ])
        self.assertEqual(pipeline.validate_jobs(jobs, check_duplicate_ids=True), [])

    def test_public_payload_schema_fields(self) -> None:
        job = next(job for job in self.current_jobs() if job.label == "dynamics.gate")
        payload = pipeline.build_publish_payload(job)
        self.assertEqual(payload["schemaVersion"], 1)
        self.assertEqual(payload["node"], "dynamics.gate")
        self.assertEqual(payload["factory"], "dynamics")
        self.assertEqual(payload["slug"], "gate")
        self.assertEqual(payload["screenshotUrl"], "/data/v2/scriptnode-examples/dynamics/gate.png")
        self.assertIn("hscScript", payload)
        self.assertIn("llmRef", payload)

    def test_schema_rejects_wrong_enum_and_missing_primary_related_node(self) -> None:
        job = next(job for job in self.current_jobs() if job.label == "dynamics.gate")
        meta, body = pipeline.parse_authored_ref(pipeline.read_text(job.phase5_ref))
        meta["difficulty"] = "expert"
        meta["relatedNodes"] = ["core.gain"]
        issues = pipeline.validate_phase5_schema(job, meta, body)
        self.assertTrue(any("difficulty" in issue for issue in issues))
        self.assertTrue(any("relatedNodes" in issue for issue in issues))

    def test_screenshot_jobs_target_gitignored_output(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            phase4 = root / "phase4"
            script = phase4 / "dynamics" / "gate.hsc"
            script.parent.mkdir(parents=True)
            script.write_text('add ScriptFX as "Gate"\n', encoding="utf-8")
            output = root / "output"
            with mock.patch.object(pipeline, "PHASE4", phase4), mock.patch.object(pipeline, "PUBLISH_OUTPUT", output):
                jobs = pipeline.find_jobs(force=False)
            self.assertEqual(jobs[0].output, output / "dynamics" / "gate.png")

    def test_published_inventory_requires_json_llm_and_png(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            output = Path(temp)
            factory = output / "dynamics"
            factory.mkdir()
            (factory / "gate.json").write_text("{}", encoding="utf-8")
            (factory / "gate.png").write_bytes(b"png")
            with mock.patch.object(pipeline, "PUBLISH_OUTPUT", output):
                self.assertEqual(pipeline.collect_published_nodes(), set())
                (factory / "gate.llm.md").write_text("reference", encoding="utf-8")
                self.assertEqual(pipeline.collect_published_nodes(), {"dynamics/gate"})

    def test_png_dimensions_rejects_non_png(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            path = Path(temp) / "bad.png"
            path.write_bytes(b"not a png")
            with self.assertRaisesRegex(ValueError, "Not a valid PNG"):
                pipeline.png_dimensions(path)

    def test_publish_preflight_happens_before_run_hise(self) -> None:
        job = self.current_jobs()[0]
        args = argparse.Namespace(node=None, ui_delay=0, scale="100%", retries=0, retry_delay=0)
        with (
            mock.patch.object(pipeline, "find_publish_jobs", return_value=[job]),
            mock.patch.object(pipeline, "validate_jobs", return_value=["broken artifact"]),
            mock.patch.object(pipeline, "run_hise") as run_hise,
            contextlib.redirect_stdout(io.StringIO()),
            contextlib.redirect_stderr(io.StringIO()),
        ):
            self.assertEqual(pipeline.publish(args), 1)
        run_hise.assert_not_called()

    def test_validate_hsc_does_not_require_phase5(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            phase4 = Path(temp) / "phase4"
            script = phase4 / "dynamics" / "gate.hsc"
            script.parent.mkdir(parents=True)
            script.write_text("/hise playground open\n/builder\nreset\n", encoding="utf-8")
            args = argparse.Namespace(node="dynamics.gate")
            with mock.patch.object(pipeline, "PHASE4", phase4), contextlib.redirect_stdout(io.StringIO()):
                self.assertEqual(pipeline.validate_hsc(args), 0)


if __name__ == "__main__":
    unittest.main()
