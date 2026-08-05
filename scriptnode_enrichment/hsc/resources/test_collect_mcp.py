from __future__ import annotations

import sys
import unittest
from pathlib import Path
from unittest import mock


ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT))

import collect_mcp


class ScriptnodeExampleCollectionTests(unittest.TestCase):
    def test_collects_current_validated_examples_without_publish_output(self) -> None:
        missing_output = ROOT / "does-not-exist"
        with mock.patch.object(collect_mcp.hsc_pipeline, "PUBLISH_OUTPUT", missing_output):
            result = collect_mcp.collect_scriptnode_examples(ROOT)

        self.assertEqual(result["schemaVersion"], 1)
        self.assertEqual(
            list(result["examples"]),
            [
                "dynamics.comp",
                "dynamics.envelope_follower",
                "dynamics.gate",
                "dynamics.limiter",
                "routing.selector",
            ],
        )
        gate = result["examples"]["dynamics.gate"]
        for key in ("id", "node", "text", "llmRef", "hscScript", "commandList", "relatedNodes"):
            self.assertTrue(gate[key])
        self.assertEqual(gate["node"], "dynamics.gate")

    def test_validation_failure_stops_collection(self) -> None:
        with mock.patch.object(
            collect_mcp.hsc_pipeline,
            "validate_jobs",
            return_value=["dynamics.gate: broken"],
        ):
            with self.assertRaisesRegex(ValueError, "broken"):
                collect_mcp.collect_scriptnode_examples(ROOT)

    def test_invalid_example_id_stops_collection(self) -> None:
        original = collect_mcp.hsc_pipeline.build_publish_payload

        def invalid_id(job):
            payload = original(job)
            payload["id"] = "wrong-id"
            return payload

        with mock.patch.object(collect_mcp.hsc_pipeline, "build_publish_payload", side_effect=invalid_id):
            with self.assertRaisesRegex(ValueError, "example id must begin"):
                collect_mcp.collect_scriptnode_examples(ROOT)


if __name__ == "__main__":
    unittest.main()
