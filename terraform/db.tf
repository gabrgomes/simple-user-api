
resource "aws_ecs_cluster" "db-cluster" {
  name = "${var.app_name}-db"
  }

resource "aws_ecs_task_definition" "db-task" {
  family                   = "${var.app_name}-db"
  container_definitions    = <<DEFINITION
  [
    {
      "name": "${var.app_name}-db",
      "image": "mongo",
      "essential": true,
      "portMappings": [
        {
          "containerPort": ${var.db_container_port},
          "hostPort": ${var.db_container_port}
        }
      ],
      "memory": 1024,
      "cpu": 256
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"] # Stating that we are using ECS Fargate
  network_mode             = "awsvpc"    # Using awsvpc as our network mode as this is required for Fargate
  memory                   = 1024         # Specifying the memory our container requires
  cpu                      = 256         # Specifying the CPU our container requires
  execution_role_arn       = "${aws_iam_role.ecsTaskExecutionRole.arn}"
}

resource "aws_ecs_service" "db-service" {
  name            = "db-service"                             # Naming our service
  cluster         = "${aws_ecs_cluster.db-cluster.id}"             # Referencing our created Cluster
  task_definition = "${aws_ecs_task_definition.db-task.arn}" # Referencing the task our service will spin up
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = ["${aws_default_subnet.default_subnet_a.id}", "${aws_default_subnet.default_subnet_b.id}", "${aws_default_subnet.default_subnet_c.id}"]
    assign_public_ip = true # Providing our containers with public IPs
    security_groups  = ["${aws_security_group.db_service_security_group.id}"] # Setting the security group
  }

  service_registries {
    registry_arn = "${aws_service_discovery_service.db_service_discovery.arn}"
    port = var.db_container_port
  }

}
