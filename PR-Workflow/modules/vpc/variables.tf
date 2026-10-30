variable "name" {
  description = "Name prefix for network resources"
  type        = string
}

variable "availability_zone" {
  description = "Availability zone for the public and private subnets"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR range for the VPC"
  type        = string
  default     = "10.30.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR range for the public client subnet"
  type        = string
  default     = "10.30.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR range for the private middle-tier subnet"
  type        = string
  default     = "10.30.2.0/24"
}
