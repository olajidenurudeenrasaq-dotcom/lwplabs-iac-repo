variable "aws_region" {
  description = "AWS region to deploy the infrastructure in"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used in tags and resource names"
  type        = string
  default     = "lwplabs"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "private_subnets" {
  description = "Private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.11.0/24"]
}

variable "availability_zones" {
  description = "Availability zones for the subnets"
  type        = list(string)
  default     = ["us-east-1a"]
}

variable "private_availability_zones" {
  description = "Availability zones for the private subnets"
  type        = list(string)
  default     = ["us-east-1a"]
}

variable "public_nacl_ingress_rules" {
  description = "Ingress rules for the public NACL"
  type = list(object({
    rule_no    = number
    action     = string
    protocol   = string
    from_port  = number
    to_port    = number
    cidr_block = string
  }))
  default = [
    {
      rule_no    = 100
      action     = "allow"
      protocol   = "tcp"
      from_port  = 22
      to_port    = 22
      cidr_block = "0.0.0.0/0"
    },
    {
      rule_no    = 110
      action     = "allow"
      protocol   = "tcp"
      from_port  = 80
      to_port    = 80
      cidr_block = "0.0.0.0/0"
    },
    {
      rule_no    = 120
      action     = "allow"
      protocol   = "tcp"
      from_port  = 443
      to_port    = 443
      cidr_block = "0.0.0.0/0"
    }
  ]
}

variable "public_nacl_egress_rules" {
  description = "Egress rules for the public NACL"
  type = list(object({
    rule_no    = number
    action     = string
    protocol   = string
    from_port  = number
    to_port    = number
    cidr_block = string
  }))
  default = [
    {
      rule_no    = 100
      action     = "allow"
      protocol   = "-1"
      from_port  = 0
      to_port    = 0
      cidr_block = "0.0.0.0/0"
    }
  ]
}

variable "private_nacl_ingress_rules" {
  description = "Ingress rules for the private NACL"
  type = list(object({
    rule_no    = number
    action     = string
    protocol   = string
    from_port  = number
    to_port    = number
    cidr_block = string
  }))
  default = [
    {
      rule_no    = 100
      action     = "allow"
      protocol   = "tcp"
      from_port  = 443
      to_port    = 443
      cidr_block = "0.0.0.0/0"
    }
  ]
}

variable "private_nacl_egress_rules" {
  description = "Egress rules for the private NACL"
  type = list(object({
    rule_no    = number
    action     = string
    protocol   = string
    from_port  = number
    to_port    = number
    cidr_block = string
  }))
  default = [
    {
      rule_no    = 100
      action     = "allow"
      protocol   = "-1"
      from_port  = 0
      to_port    = 0
      cidr_block = "0.0.0.0/0"
    }
  ]
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}
