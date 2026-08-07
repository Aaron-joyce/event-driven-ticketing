resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1", "1c58a21852c50085a6a6a127606e5797f1f96409"]
}

resource "aws_iam_role" "github_actions_oidc" {
  name = "github-actions-deploy-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = [
          "sts:AssumeRoleWithWebIdentity",
          "sts:TagSession"
        ]
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${split("/", var.github_repo)[0]}@${var.github_owner_id}/${split("/", var.github_repo)[1]}@${var.github_repo_id}:*"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "github_actions_deploy" {
  name        = "github-actions-deploy-policy-${var.environment}"
  description = "Scoped least-privilege CI/CD deployment policy for Terraform and ECR"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateVpc", "ec2:DeleteVpc", "ec2:DescribeVpcs", "ec2:ModifyVpcAttribute",
          "ec2:CreateSubnet", "ec2:DeleteSubnet", "ec2:DescribeSubnets", "ec2:ModifySubnetAttribute",
          "ec2:CreateInternetGateway", "ec2:DeleteInternetGateway", "ec2:AttachInternetGateway", "ec2:DetachInternetGateway", "ec2:DescribeInternetGateways",
          "ec2:CreateRouteTable", "ec2:DeleteRouteTable", "ec2:DescribeRouteTables", "ec2:CreateRoute", "ec2:DeleteRoute", "ec2:AssociateRouteTable", "ec2:DisassociateRouteTable",
          "ec2:AllocateAddress", "ec2:ReleaseAddress", "ec2:DescribeAddresses",
          "ec2:CreateNatGateway", "ec2:DeleteNatGateway", "ec2:DescribeNatGateways",
          "ec2:CreateSecurityGroup", "ec2:DeleteSecurityGroup", "ec2:DescribeSecurityGroups", "ec2:AuthorizeSecurityGroupIngress", "ec2:AuthorizeSecurityGroupEgress", "ec2:RevokeSecurityGroupIngress", "ec2:RevokeSecurityGroupEgress",
          "ec2:DescribeAvailabilityZones", "ec2:DescribeNetworkInterfaces", "ec2:DescribeTags", "ec2:DescribeVpcAttribute"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "sqs:CreateQueue", "sqs:DeleteQueue", "sqs:GetQueueAttributes", "sqs:SetQueueAttributes", "sqs:ListQueues", "sqs:TagQueue", "sqs:UntagQueue",
          "sqs:ListQueueTags"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "apigateway:GET", "apigateway:POST", "apigateway:PUT", "apigateway:PATCH", "apigateway:DELETE"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "rds:CreateDBInstance", "rds:DeleteDBInstance", "rds:DescribeDBInstances", "rds:ModifyDBInstance",
          "rds:CreateDBSubnetGroup", "rds:DeleteDBSubnetGroup", "rds:DescribeDBSubnetGroups", "rds:ListTagsForResource", "rds:AddTagsToResource"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecs:CreateCluster", "ecs:DeleteCluster", "ecs:DescribeClusters",
          "ecs:RegisterTaskDefinition", "ecs:DeregisterTaskDefinition", "ecs:DescribeTaskDefinition",
          "ecs:CreateService", "ecs:UpdateService", "ecs:DeleteService", "ecs:DescribeServices", "ecs:ListServices", "ecs:TagResource"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:CreateSecret", "secretsmanager:DeleteSecret", "secretsmanager:DescribeSecret", "secretsmanager:GetSecretValue", "secretsmanager:PutSecretValue", "secretsmanager:TagResource",
          "secretsmanager:GetResourcePolicy"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken", "ecr:BatchCheckLayerAvailability", "ecr:GetDownloadUrlForLayer", "ecr:GetRepositoryPolicy", "ecr:DescribeRepositories", "ecr:ListImages", "ecr:DescribeImages", "ecr:BatchGetImage", "ecr:InitiateLayerUpload", "ecr:UploadLayerPart", "ecr:CompleteLayerUpload", "ecr:PutImage", "ecr:CreateRepository"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup", "logs:DeleteLogGroup", "logs:DescribeLogGroups", "logs:PutRetentionPolicy", "logs:ListTagsForResource"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricAlarm", "cloudwatch:DeleteAlarms", "cloudwatch:DescribeAlarms"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "application-autoscaling:RegisterScalableTarget", "application-autoscaling:DeregisterScalableTarget", "application-autoscaling:DescribeScalableTargets",
          "application-autoscaling:PutScalingPolicy", "application-autoscaling:DeleteScalingPolicy", "application-autoscaling:DescribeScalingPolicies"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:GetRole", "iam:GetRolePolicy", "iam:ListRolePolicies", "iam:ListAttachedRolePolicies", "iam:ListInstanceProfilesForRole",
          "iam:CreateRole", "iam:DeleteRole", "iam:UpdateRole", "iam:PassRole", "iam:PutRolePolicy", "iam:DeleteRolePolicy", "iam:AttachRolePolicy", "iam:DetachRolePolicy",
          "iam:CreatePolicy", "iam:DeletePolicy", "iam:GetPolicy", "iam:GetPolicyVersion", "iam:ListPolicyVersions", "iam:TagRole", "iam:UntagRole", "iam:TagPolicy",
          "iam:CreateOpenIDConnectProvider", "iam:DeleteOpenIDConnectProvider", "iam:GetOpenIDConnectProvider", "iam:TagOpenIDConnectProvider", "iam:ListOpenIDConnectProviders"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::ticket-terraform-state-dev-071004",
          "arn:aws:s3:::ticket-terraform-state-dev-071004/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_deploy" {
  role       = aws_iam_role.github_actions_oidc.name
  policy_arn = aws_iam_policy.github_actions_deploy.arn
}

resource "aws_iam_role" "api_gateway_sqs" {
  name = "api-gateway-sqs-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "api_gateway_sqs" {
  name = "api-gateway-sqs-policy-${var.environment}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "sqs:SendMessage"
        Effect   = "Allow"
        Resource = var.sqs_queue_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "api_gateway_sqs" {
  role       = aws_iam_role.api_gateway_sqs.name
  policy_arn = aws_iam_policy.api_gateway_sqs.arn
}

resource "aws_iam_role" "ecs_execution" {
  name = "ecs-execution-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_policy" "ecs_execution_secrets" {
  name = "ecs-execution-secrets-policy-${var.environment}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "secretsmanager:GetSecretValue"
        Effect   = "Allow"
        Resource = var.db_secret_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_secrets" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = aws_iam_policy.ecs_execution_secrets.arn
}

resource "aws_iam_role" "ecs_task" {
  name = "ecs-task-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "ecs_task_sqs" {
  name = "ecs-task-sqs-policy-${var.environment}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Effect   = "Allow"
        Resource = var.sqs_queue_arn
      },
      {
        Action   = "secretsmanager:GetSecretValue"
        Effect   = "Allow"
        Resource = var.db_secret_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_sqs" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = aws_iam_policy.ecs_task_sqs.arn
}
