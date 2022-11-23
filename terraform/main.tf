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
  name = var.app_name
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
          "containerPort": 8000,
          "hostPort": 8000
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
  name            = "app-service"                             # Naming our service
  cluster         = "${aws_ecs_cluster.app-cluster.id}"             # Referencing our created Cluster
  task_definition = "${aws_ecs_task_definition.app-task.arn}" # Referencing the task our service will spin up
  launch_type     = "FARGATE"
  desired_count   = 3 # Setting the number of containers we want deployed to 3

  network_configuration {
    subnets          = ["${aws_default_subnet.default_subnet_a.id}", "${aws_default_subnet.default_subnet_b.id}", "${aws_default_subnet.default_subnet_c.id}"]
    assign_public_ip = true # Providing our containers with public IPs
    security_groups  = ["${aws_security_group.app_service_security_group.id}"] # Setting the security group
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.target_group.arn}" # Referencing our target group
    container_name   = "${aws_ecs_task_definition.app-task.family}"
    container_port   = 8000 # Specifying the container port
  }

}

output "app_url" {
  value="http://${aws_alb.application_load_balancer.dns_name}/docs"
}