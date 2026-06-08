variable "region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "name" {
  description = "Name prefix applied to all resources."
  type        = string
  default     = "whoami-lab"
}

variable "container_port" {
  description = "Port the container listens on (must match the app's PORT)."
  type        = number
  default     = 8080
}

variable "cpu" {
  description = "Fargate task CPU units. 256 = 0.25 vCPU (the smallest)."
  type        = number
  default     = 256
}

variable "memory" {
  description = "Fargate task memory in MiB. 512 is the minimum for 256 CPU."
  type        = number
  default     = 512
}

variable "log_retention_days" {
  description = "CloudWatch log retention. Keep short to stay cheap."
  type        = number
  default     = 1
}

variable "ingress_cidr" {
  description = "CIDR allowed to reach the container port. Default is open; tighten to your IP for a real test."
  type        = string
  default     = "0.0.0.0/0"
}
