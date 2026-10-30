aws_region                 = "us-east-1"
project_name               = "lwplabs-devops-project"
environment                = "stg"
vpc_cidr                   = "10.0.0.0/16"
public_subnets             = ["10.0.1.0/24"]
private_subnets            = ["10.0.11.0/24"]
availability_zones         = ["us-east-1a"]
private_availability_zones = ["us-east-1a"]

public_nacl_ingress_rules = [
  { rule_no = 100, action = "allow", protocol = "tcp", from_port = 22, to_port = 22, cidr_block = "0.0.0.0/0" },
  { rule_no = 110, action = "allow", protocol = "tcp", from_port = 80, to_port = 80, cidr_block = "0.0.0.0/0" },
  { rule_no = 120, action = "allow", protocol = "tcp", from_port = 443, to_port = 443, cidr_block = "0.0.0.0/0" }
]

public_nacl_egress_rules = [
  { rule_no = 100, action = "allow", protocol = "-1", from_port = 0, to_port = 0, cidr_block = "0.0.0.0/0" }
]

private_nacl_ingress_rules = [
  { rule_no = 100, action = "allow", protocol = "tcp", from_port = 443, to_port = 443, cidr_block = "10.0.1.0/24" }
]

private_nacl_egress_rules = [
  { rule_no = 100, action = "allow", protocol = "-1", from_port = 0, to_port = 0, cidr_block = "0.0.0.0/0" }
]

instance_type = "t3.micro"
