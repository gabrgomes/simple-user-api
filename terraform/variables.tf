variable "region_name" {
  type    = string
  default = "us-east-1"
}

variable "app_name" {
  type    = string
  default = "simple-user-api"
}

variable "app_image" {
  type    = string
  default = "public.ecr.aws/f9q5q0t9/simple-user-api:latest"
}

variable "db_container_port" {
  type    = number
  default = 27017
}
