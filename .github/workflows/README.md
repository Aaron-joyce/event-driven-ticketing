# GitHub Actions Workflows (`/.github/workflows`)

## Description
CI/CD automated pipeline definitions for code validation, container builds, and infrastructure management.

## Workflows
- `pr.yml`: Triggered on Pull Requests to `main`. Runs linter (`ruff`/`flake8`), unit tests (`pytest`), `terraform fmt -check`, and posts `terraform plan` output as a PR comment.
- `deploy.yml`: Triggered on merge to `main`. Builds Docker images, pushes to Amazon ECR, and executes `terraform apply`.
