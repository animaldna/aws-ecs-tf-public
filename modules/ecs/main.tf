module "iam" {
  source          = "../iam_ecs_roles"
  resource_prefix = var.resource_prefix
}

resource "aws_cloudwatch_log_group" "container_logs" {
  name = "/aws/ecs/${var.resource_prefix}-container-logs"
}

resource "aws_ecs_task_definition" "task-template" {
  family = "${var.resource_prefix}-task-template"
  depends_on = [aws_cloudwatch_log_group.container_logs]
  container_definitions = jsonencode([
    {
      name      = "${var.resource_prefix}-container"
      image     = var.image
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/aws/ecs/${var.resource_prefix}-container-logs"
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = module.iam.ecs_task_exec_role_arn
  task_role_arn            = module.iam.ecs_task_role_arn
}

resource "aws_ecs_cluster" "cluster" {
  name               = "${var.resource_prefix}-cluster"
  capacity_providers = [var.env == "prod" ? "FARGATE" : "FARGATE_SPOT"]

  setting {
    name  = "containerInsights"
    value = var.env == "prod" ? "enabled" : "disabled"
  }
  # TODO: set up logging
  # tags {
  #   network = "public"
  # }
}

resource "aws_ecs_service" "service" {
  name          = "${var.resource_prefix}-service"
  cluster       = aws_ecs_cluster.cluster.arn
  desired_count = var.env == "prod" ? 4 : 2
  launch_type   = "FARGATE"
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }
  load_balancer {
    target_group_arn = var.alb_target_group
    container_name   = "${var.resource_prefix}-container"
    container_port   = 80
  }
  # TODO: port should be dynamic
  network_configuration {
    subnets          = var.public_subnets
    security_groups  = var.security_groups
    assign_public_ip = true
  }
  task_definition = aws_ecs_task_definition.task-template.arn
  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
}