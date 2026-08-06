# GitHub Actions Workflows (`/.github/workflows`)

## Description
CI/CD automated pipeline definitions for code validation, secret scanning, container builds, and infrastructure management.

## Workflows
- `pr.yml`: Triggered on Pull Requests targeting `main`. Runs:
  - **TruffleHog**: Automated secret scanning to prevent credentials from being committed.
  - **Ruff**: Fast Python linting (`ruff check .`).
  - **Pytest**: Unit testing worker SQS consumption logic against `moto` AWS mocks and SQLite.
  - **Terraform**: `terraform fmt -check` and `terraform validate`.
- `deploy.yml`: Triggered on merge to `main`. Logs into Amazon ECR, builds and pushes the worker container image, and executes non-destructive `terraform apply`.
