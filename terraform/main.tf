terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region_name
}

resource "aws_ecs_cluster" "app-cluster" {
  name = "${var.app_name}-app"
}

resource "aws_ecs_task_definition" "app-task" {
  family                   = var.app_name
  container_definitions    = <<DEFINITION
  [
    {
      "name": "${var.app_name}",
      "image": "${var.app_image}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": ${var.app_container_port},
          "hostPort": ${var.app_container_port}
        }
      ],
      "memory": 512,
      "cpu": 256,
      "environment": [
        {
          "name": "MONGODB_URL",
          "value": "mongodb.${var.app_name}:${var.db_container_port}"
        }
      ]
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"] # Stating that we are using ECS Fargate
  network_mode             = "awsvpc"    # Using awsvpc as our network mode as this is required for Fargate
  memory                   = 512         # Specifying the memory our container requires
  cpu                      = 256         # Specifying the CPU our container requires
  execution_role_arn       = "${aws_iam_role.ecsTaskExecutionRole.arn}"
}

resource "aws_ecs_service" "app-service" {
  name            = "app-service"
  cluster         = "${aws_ecs_cluster.app-cluster.id}"
  task_definition = "${aws_ecs_task_definition.app-task.arn}"
  launch_type     = "FARGATE"
  desired_count   = 1 

  network_configuration {
    subnets          = ["${aws_default_subnet.default_subnet_a.id}", "${aws_default_subnet.default_subnet_b.id}", "${aws_default_subnet.default_subnet_c.id}"]
    assign_public_ip = true # Providing our containers with public IPs
    security_groups  = ["${aws_security_group.app_service_security_group.id}"]
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.target_group.arn}"
    container_name   = "${aws_ecs_task_definition.app-task.family}"
    container_port   = var.app_container_port
  }

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }

}

output "app_url" {
  value="http://${aws_alb.application_load_balancer.dns_name}/docs"
}