resource "aws_iam_role" "codebuild_role" {

  name        = "codebuild-admin-role"
  description = "Allows CodeBuild to call AWS services on your behalf."

  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "codebuild.amazonaws.com"
          }
        },
      ]
      Version = "2012-10-17"
    }
  )
}

data "aws_iam_policy" "codebuild_admin" {
  name = "AWSCodeBuildAdminAccess"
}

resource "aws_iam_policy" "codebuild_policy" {
  name = "codeconnection_policy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "codeconnections:GetConnectionToken",
          "codeconnections:GetConnection",
          "ecr:Get*",
          "ecr:Put*",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:BatchCheckLayerAvailability",
        ],
        "Resource" : [
          "*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "codebuild_ecr_policy" {
  name = "codebuild_ecr_policy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ecr:Get*",
          "ecr:Put*",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:BatchCheckLayerAvailability",
        ],
        "Resource" : [
          "*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "codebuild_ecs_policy" {
  name = "codebuild_ecs_policy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ecs:DescribeServices",
          "ecs:DescribeTaskDefinition",
          "ecs:DescribeTasks",
          "ecs:ListClusters",
          "ecs:ListServices",
          "ecs:ListTasks",
          "ecs:RegisterTaskDefinition",
          "ecs:UpdateService",
          "iam:PassRole"
        ],
        "Resource" : [
          "*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "codebuild_passrole_policy" {
  name = "codebuild_ecs_passrole_policy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "iam:PassRole"
        ],
        "Resource" : [
          "*"
        ]
      }
    ]
  })
}



resource "aws_iam_role_policy_attachment" "codebuild_attach" {
  role       = aws_iam_role.codebuild_role.id
  policy_arn = data.aws_iam_policy.codebuild_admin.arn
}

resource "aws_iam_role_policy_attachment" "codebuild_attachs" {
  for_each = {
    for i, v in [aws_iam_policy.codebuild_policy, aws_iam_policy.codebuild_ecr_policy, aws_iam_policy.codebuild_ecs_policy, aws_iam_policy.codebuild_passrole_policy] :
    i => v
  }

  role       = aws_iam_role.codebuild_role.id
  policy_arn = each.value.arn
}