resource "aws_security_group" "codebuild_sg" {
  name        = "codebuild-sg"
  description = "codebuild-sg"
  vpc_id      = local.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

variable "repo_attr" {
  default = {
    git_location : "https://github.com/zkfmapf123/codebuild-runner"
    git_submodule_config : false
  }
}

resource "aws_codebuild_project" "runner" {
  name                   = "runner"
  build_timeout          = 60
  concurrent_build_limit = 1
  service_role           = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    modes = [
      "LOCAL_DOCKER_LAYER_CACHE"
    ]
    type = "LOCAL"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-aarch64-standard:3.0"
    type                        = "ARM_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    # environment_variable {
    #   name  = "SOME_KEY1"
    #   value = "SOME_VALUE1"
    # }

    # environment_variable {
    #   name  = "SOME_KEY2"
    #   value = "SOME_VALUE2"
    #   type  = "PARAMETER_STORE"
    # }
  }

  #   logs_config {
  #     cloudwatch_logs {
  #       group_name  = "log-group"
  #       stream_name = "log-stream"
  #     }
  #   }

  source {
    buildspec = <<-EOT
                version: 0.2
                phases:
                  build:
                    commands:
                       - echo "code build"
    EOT

    type            = "GITHUB"
    location        = lookup(var.repo_attr, "git_location")
    git_clone_depth = 1

    git_submodules_config {
      fetch_submodules = lookup(var.repo_attr, "git_submodule_config")
    }
  }

  #   source_version = "master"

  vpc_config {
    vpc_id = local.vpc_id

    subnets = values(local.was_subnets)

    security_group_ids = [
      aws_security_group.codebuild_sg.id
    ]
  }
}

resource "aws_codebuild_webhook" "runner-webhook" {
  project_name = aws_codebuild_project.runner.name
  build_type   = "BUILD"

  filter_group {
    filter {
      exclude_matched_pattern = false
      pattern                 = "WORKFLOW_JOB_QUEUED"
      type                    = "EVENT"
    }
  }
}