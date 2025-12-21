const owner = "thieled";
const repo  = "ecpr-newsletter";

async function dispatch(workflow, inputs) {
  const res = await fetch(
    `https://api.github.com/repos/${owner}/${repo}/actions/workflows/${workflow}/dispatches`,
    {
      method: "POST",
      headers: {
        "Accept": "application/vnd.github+json"
      },
      body: JSON.stringify({
        ref: "main",
        inputs: inputs
      })
    }
  );

  if (!res.ok) {
    throw new Error("Failed to start workflow");
  }
}

function setStatus(msg) {
  document.getElementById("status").textContent = msg;
}

async function createIssue() {
  const year = document.getElementById("year").value;
  const issue = document.getElementById("issue").value;
  const overwrite = document.getElementById("overwrite").checked;

  setStatus("Starting create-issue workflow…");

  await dispatch("new-issue.yml", {
    year: year,
    issue: issue,
    overwrite: overwrite.toString()
  });

  setStatus("Workflow started. Check Actions tab for progress.");
}

async function renderIssue() {
  const year = document.getElementById("year").value;
  const issue = document.getElementById("issue").value;

  setStatus("Starting render workflow…");

  await dispatch("render-inline.yml", {
    year: year,
    issue: issue
  });

  setStatus("Render started. Refresh Actions tab for status.");
}
