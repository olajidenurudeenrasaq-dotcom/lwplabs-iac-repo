resource "aws_instance" "this" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  associate_public_ip_address = var.associate_public_ip_address
  user_data                   = var.user_data
  user_data_replace_on_change = true

  tags = {
    Name = var.name
    Tier = var.tier
  }
}
