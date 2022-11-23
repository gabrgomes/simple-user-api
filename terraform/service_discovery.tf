
resource "aws_service_discovery_private_dns_namespace" "fargate" {
  name        = "${var.app_name}"
  description = "${var.app_name}"
  vpc = "${aws_default_vpc.default_vpc.id}"
}

resource "aws_service_discovery_service" "db_service_discovery" {
  name = "mongodb"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.fargate.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    dns_records {
      ttl  = 10
      type = "SRV"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}