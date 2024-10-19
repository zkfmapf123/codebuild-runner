resource "aws_ecr_repository" "ecs_ecr" {
  name = "ecs-server-registry"
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "ecs-cluster"
}

resource "aws_ecs_task_definition" "task_def" {
  family = "service"
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name      = "svc"
      image     = "${aws_ecr_repository.ecs_ecr.repository_url}:latest"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ],
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : "svc-logs",
          "awslogs-create-group" : "true",
          "awslogs-region" : "ap-northeast-2",
          "awslogs-stream-prefix" : "svc"
        },
        "secretOptions" : []
      },
    }
  ])

  runtime_platform {
    cpu_architecture        = "ARM64"
  }

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = "512"
  cpu                      = "256"
}

resource "aws_security_group" "ecs_sg" {
  name        = "server-ecs-sg"
  description = "server-ecs-sg"
  vpc_id      = local.vpc_id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_service" "ecs_svc" {
  name = "server"
  cluster= aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.task_def.arn
  desired_count = 1

  # iam_role = aws_iam_role.ecs_service_role.arn
  launch_type = "FARGATE"
  platform_version = "LATEST"

  network_configuration {
    subnets = values(local.was_subnets)
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.server_ecs_tg.arn
    container_name = "svc"
    container_port = 3000
  }
}