"""Keep repository code isolated from CI deployment credentials."""

import os
import subprocess

import pytest
import yaml

ROOT = os.path.dirname(os.path.dirname(__file__))
with open(f"{ROOT}/.github/workflows/ci.yml") as workflow_file:
    WORKFLOW = yaml.safe_load(workflow_file)


@pytest.mark.parametrize("result", ["success", "failure", "cancelled", "skipped"])
def test_required_check_gate(result: str) -> None:
    """The required check succeeds only when every matrix check succeeds."""
    gate = WORKFLOW["jobs"]["check"]
    assert gate["if"] == "always()"
    assert gate["needs"] == "checks"
    command = gate["steps"][0]["run"].replace("${{ needs.checks.result }}", result)
    completed = subprocess.run(["bash", "-c", command], check=False)
    assert (completed.returncode == 0) == (result == "success")


@pytest.mark.parametrize("job_name", WORKFLOW["jobs"])
def test_ci_credentials(job_name: str) -> None:
    """Only the deployment job may write; checked-out code has no saved token."""
    job = WORKFLOW["jobs"][job_name]
    permissions = job.get("permissions", WORKFLOW.get("permissions"))
    deploys = any(
        step.get("uses", "").startswith("actions/deploy-pages@")
        for step in job["steps"]
    )
    if deploys:
        assert permissions == {"pages": "write", "id-token": "write"}
        assert job["if"] == "github.ref == 'refs/heads/main'"
        assert not any("run" in step for step in job["steps"])
    else:
        assert permissions == {"contents": "read"}
    for step in job["steps"]:
        if step.get("uses", "").startswith("actions/checkout@"):
            assert not deploys
            assert step.get("with", {}).get("persist-credentials") is False
