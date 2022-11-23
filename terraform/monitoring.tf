# module "ecs-service-cloudwatch-dashboard-app" {
#   source  = "silinternational/ecs-service-cloudwatch-dashboard/aws"
#   version = "2.0.1"
#   aws_region     = var.region_name
#   cluster_name   = "${var.app_name}"
#   dashboard_name = "${var.app_name}"
#   service_names  = ["app-service"]
# }

# module "ecs-service-cloudwatch-dashboard-db" {
#   source  = "silinternational/ecs-service-cloudwatch-dashboard/aws"
#   version = "2.0.1"
#   aws_region     = var.region_name
#   cluster_name   = "${var.app_name}-db"
#   dashboard_name = "${var.app_name}"
#   service_names  = ["db-service"]
# }

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.app_name}-dashboard"
  dashboard_body = jsonencode({
    widgets = local.widgets
  })
}

locals {
  widgets = [for service_name in ["app", "db"] : {
    type   = "metric"
    width  = 18
    height = 6
    properties = {
      view    = "timeSeries"
      stacked = false
      metrics = [
        ["AWS/ECS", "CPUUtilization", "ServiceName", "${service_name}-service", "ClusterName", "${var.app_name}-${service_name}", { color = "#d62728", stat = "Maximum" }],
        [".", "MemoryUtilization", ".", ".", ".", ".", { yAxis = "right", color = "#1f77b4", stat = "Maximum" }]
      ]
      region = var.region_name,
      annotations = {
        horizontal = [
          {
            color = "#ff9896",
            label = "100% CPU",
            value = 100
          },
          {
            color = "#9edae5",
            label = "100% Memory",
            value = 100,
            yAxis = "right"
          },
        ]
      }
      yAxis = {
        left = {
          min = 0
        }
        right = {
          min = 0
        }
      }
      title  = "${var.app_name}-${service_name}"
      period = 300
    }
  }]
}
