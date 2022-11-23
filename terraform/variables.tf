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

variable "app_container_port" {
  type    = number
  default = 8000
}

variable "db_container_port" {
  type    = number
  default = 27017
}

variable "max_capacity" {
  type    = number
  default = 3
}

variable "min_capacity" {
  type    = number
  default = 1
}

variable "cpu_treshold" {
  type    = number
  default = 80
}

variable "mem_treshold" {
  type    = number
  default = 80
}