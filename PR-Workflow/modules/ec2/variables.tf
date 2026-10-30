variable "name" {
  description = "Name tag for the EC2 instance"
  type        = string
}

variable "tier" {
  description = "Application tier assigned to the instance"
  type        = string
}

variable "ami_id" {
  description = "Amazon Linux AMI ID"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "subnet_id" {
  description = "Subnet in which to launch the instance"
  type        = string
}

variable "security_group_ids" {
  description = "Security groups attached to the instance"
  type        = list(string)
}

variable "associate_public_ip_address" {
  description = "Whether to assign a public IPv4 address"
  type        = bool
}

variable "user_data" {
  description = "Bootstrap script for the EC2 instance"
  type        = string
}
