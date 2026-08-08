# IAM Terraform Module (`/terraform/modules/iam`)

## Description
Defines AWS IAM roles, OIDC identity providers, and policies for ECS execution, task runtime, and keyless CI/CD deployment.

## Responsibilities
- **GitHub Actions OIDC Provider (`aws_iam_openid_connect_provider.github`)**: Enables keyless authentication for GitHub Actions runners via `sts:AssumeRoleWithWebIdentity`.
- **GitHub Actions Deployment Role (`aws_iam_role.github_actions_oidc`)**:
  - Trust policy scoped to repository subjects (supporting both repository string claims `repo:Aaron-joyce/event-driven-ticketing:*` and GitHub's immutable-ID format `repo:owner-id@ID/repo-id@ID:*`).
  - Attached custom scoped least-privilege deployment policy (`github-actions-deploy-policy-dev`) restricted to Terraform & ECR resource actions.
- **API Gateway Execution Role**: Scoped strictly to `sqs:SendMessage` for the target queue.
- **ECS Task Execution Role**: Scoped to ECR image pulls, CloudWatch logs, and `secretsmanager:GetSecretValue` on the DB password secret.
- **Worker Task Role**: Scoped strictly to `sqs:ReceiveMessage`, `sqs:DeleteMessage`, `sqs:GetQueueAttributes`, CloudWatch logs, and `secretsmanager:GetSecretValue`.
