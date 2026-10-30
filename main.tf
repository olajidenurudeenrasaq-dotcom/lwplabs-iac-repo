provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "git::https://github.com/olajidenurudeenrasaq-dotcom/AWS-Modules.git//vpc?ref=main"

  name                       = var.project_name
  vpc_cidr                   = var.vpc_cidr
  public_subnets             = var.public_subnets
  private_subnets            = var.private_subnets
  availability_zones         = var.availability_zones
  private_availability_zones = var.private_availability_zones

  public_nacl_ingress_rules  = var.public_nacl_ingress_rules
  public_nacl_egress_rules   = var.public_nacl_egress_rules
  private_nacl_ingress_rules = var.private_nacl_ingress_rules
  private_nacl_egress_rules  = var.private_nacl_egress_rules

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

module "web_security_group" {
  source = "git::https://github.com/olajidenurudeenrasaq-dotcom/AWS-Modules.git//security-group?ref=main"

  name        = "${var.project_name}-web-sg"
  description = "Security group for web application access"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = [
    {
      description = "SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "HTTP"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }

  depends_on = [module.vpc]
}

module "ec2_app" {
  source = "git::https://github.com/olajidenurudeenrasaq-dotcom/AWS-Modules.git//ec2?ref=main"

  name                        = "${var.project_name}-app"
  instance_type               = var.instance_type
  subnet_id                   = module.vpc.public_subnet_ids[0]
  security_group_ids          = [module.web_security_group.security_group_id]
  associate_public_ip_address = true

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Name        = "${var.project_name}-app"
  }

  depends_on = [module.vpc]
}
