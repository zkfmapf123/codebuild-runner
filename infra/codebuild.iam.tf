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

resource "aws_iam_role_policy_attachment" "codebuild_attach" {
  role       = aws_iam_role.codebuild_role.id
  policy_arn = data.aws_iam_policy.codebuild_admin.arn
}