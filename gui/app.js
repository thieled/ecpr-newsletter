const owner = "thieled";
const repo  = "ecpr-newsletter";

function openCreateIssue() {
  const year = document.getElementById("year").value;
  const issue = document.getElementById("issue").value;
  const overwrite = document.getElementById("overwrite").checked;

  const url =
    `https://github.com/${owner}/${repo}/actions/workflows/new-issue.yml` +
    `?year=${encodeURIComponent(year)}` +
    `&issue=${encodeURIComponent(issue)}` +
    `&overwrite=${overwrite}`;

  window.open(url, "_blank");
}

function openRenderIssue() {
  const year = document.getElementById("year").value;
  const issue = document.getElementById("issue").value;

  const url =
    `https://github.com/${owner}/${repo}/actions/workflows/render-inline.yml` +
    `?year=${encodeURIComponent(year)}` +
    `&issue=${encodeURIComponent(issue)}`;

  window.open(url, "_blank");
}
