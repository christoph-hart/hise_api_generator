import json
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT))

import publish


class PublishIntegrationTests(unittest.TestCase):
    def make_bundle(self, root: Path) -> tuple[Path, Path, Path]:
        phase5 = root / "phase5" / "dynamics"
        phase4 = root / "phase4" / "dynamics"
        output = root / "output" / "dynamics"
        phase5.mkdir(parents=True)
        phase4.mkdir(parents=True)
        output.mkdir(parents=True)

        authored = "---\nid: dynamics.gate.example\n---\nbody\n"
        (phase5 / "gate.llm.md").write_text(authored, encoding="utf-8")
        (output / "gate.llm.md").write_text(authored, encoding="utf-8")
        (output / "gate.png").write_bytes(b"\x89PNG\r\n\x1a\nrest")
        hsc_script = "/hise playground open\n/builder\nreset\n/exit\n"
        (phase4 / "gate.hsc").write_text(hsc_script, encoding="utf-8")
        payload = {
            "schemaVersion": 1,
            "id": "dynamics.gate.example",
            "node": "dynamics.gate",
            "factory": "dynamics",
            "slug": "gate",
            "title": "Gate example",
            "summary": "Summary",
            "useCase": "Use case",
            "hscScript": hsc_script,
            "screenshot": "gate.png",
            "screenshotUrl": "/data/v2/scriptnode-examples/dynamics/gate.png",
        }
        (output / "gate.json").write_text(json.dumps(payload), encoding="utf-8")
        return root / "phase5", root / "output", root / "phase4"

    def test_load_and_deploy_complete_bundle(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            phase5, output, phase4 = self.make_bundle(root)
            examples = publish.load_scriptnode_example_bundles(phase5, output, phase4)
            public_dir = root / "website" / "public" / "data" / "v2" / "scriptnode-examples"
            publish.deploy_scriptnode_example_bundles(examples, public_dir, dry_run=False)

            manifest = json.loads((public_dir / "manifest.json").read_text(encoding="utf-8"))
            self.assertEqual(list(manifest["examples"]), ["dynamics.gate"])
            self.assertTrue((public_dir / "dynamics" / "gate.json").is_file())
            self.assertTrue((public_dir / "dynamics" / "gate.png").is_file())

    def test_stale_bundle_is_rejected(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            phase5, output, phase4 = self.make_bundle(root)
            (output / "dynamics" / "gate.llm.md").write_text("stale", encoding="utf-8")
            with self.assertRaisesRegex(ValueError, "stale"):
                publish.load_scriptnode_example_bundles(phase5, output, phase4)

    def test_stale_hsc_bundle_is_rejected(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            phase5, output, phase4 = self.make_bundle(root)
            (phase4 / "dynamics" / "gate.hsc").write_text(
                "/hise playground open\n/builder\nreset\nadd ScriptFX as \"Changed\"\n",
                encoding="utf-8",
            )
            with self.assertRaisesRegex(ValueError, "generated HSC script is stale"):
                publish.load_scriptnode_example_bundles(phase5, output, phase4)

    def test_unsafe_hsc_bundle_is_rejected(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            phase5, output, phase4 = self.make_bundle(root)
            unsafe = "/builder\nreset\n"
            (phase4 / "dynamics" / "gate.hsc").write_text(unsafe, encoding="utf-8")
            payload_path = output / "dynamics" / "gate.json"
            payload = json.loads(payload_path.read_text(encoding="utf-8"))
            payload["hscScript"] = unsafe
            payload_path.write_text(json.dumps(payload), encoding="utf-8")
            with self.assertRaisesRegex(ValueError, "safe Playground preamble"):
                publish.load_scriptnode_example_bundles(phase5, output, phase4)

    def test_injects_one_component(self):
        examples = {
            "dynamics.gate": {
                "dataUrl": "/data/v2/scriptnode-examples/dynamics/gate.json"
            }
        }
        content = "---\nfactoryPath: dynamics.gate\n---\n\nBody\n\n## Signal Path\n\nPath\n"
        injected = publish.inject_scriptnode_example(content, "dynamics.gate", examples)
        self.assertEqual(injected.count("::scriptnode-example"), 1)
        self.assertIn('node: "dynamics.gate"', injected)
        self.assertLess(injected.index("::scriptnode-example"), injected.index("## Signal Path"))
        self.assertEqual(
            publish.inject_scriptnode_example(injected, "dynamics.gate", examples),
            injected,
        )

    def test_public_dir_requires_content_v2(self):
        root = Path("site")
        self.assertEqual(
            publish.scriptnode_example_public_dir(root / "content" / "v2"),
            root / "public" / "data" / "v2" / "scriptnode-examples",
        )
        with self.assertRaises(ValueError):
            publish.scriptnode_example_public_dir(root / "output")


if __name__ == "__main__":
    unittest.main()
