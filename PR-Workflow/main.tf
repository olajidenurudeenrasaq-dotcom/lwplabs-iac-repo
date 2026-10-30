data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "vpc" {
  source = "./modules/vpc"

  name              = "nurudeen-website"
  availability_zone = var.availability_zone
}

resource "aws_security_group" "client" {
  name        = "nurudeen-website-client"
  description = "Allow public HTTP to the website client tier"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Public HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Nurudeen Website Client SG"
  }
}

resource "aws_security_group" "middle" {
  name        = "nurudeen-website-middle"
  description = "Allow HTTP only from the client tier"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "Client tier to middle tier"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.client.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Nurudeen Website Middle SG"
  }
}

module "middle_tier" {
  source = "./modules/ec2"

  name                        = "Nurudeen Website Middle Tier"
  tier                        = "middle"
  ami_id                      = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = module.vpc.private_subnet_id
  security_group_ids          = [aws_security_group.middle.id]
  associate_public_ip_address = false
  user_data                   = <<-USERDATA
    #!/bin/bash
    set -euxo pipefail
    dnf install -y httpd
    sed -i 's/^Listen 80$/Listen 8080/' /etc/httpd/conf/httpd.conf
    printf '%s\n' '<!doctype html><html lang="en"><head><meta charset="utf-8"><title>Nurudeen Website</title></head><body><h1>Welcome to Nurudeen website</h1><p>Middle tier is running.</p></body></html>' > /var/www/html/index.html
    systemctl enable --now httpd
  USERDATA
}

module "client_tier" {
  source = "./modules/ec2"

  name                        = "Nurudeen Website"
  tier                        = "client"
  ami_id                      = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = module.vpc.public_subnet_id
  security_group_ids          = [aws_security_group.client.id]
  associate_public_ip_address = true
  user_data                   = <<-USERDATA
    #!/bin/bash
    set -euxo pipefail
    dnf install -y httpd
    cat > /var/www/html/index.html <<'HTML'
    <!doctype html>
    <html lang="en">
      <head><meta charset="utf-8"><title>Nurudeen Website</title></head>
      <body>
        <h1>Welcome to Nurudeen website</h1>
        <p>This page is served by the public client tier.</p>
        <p><a href="/middle">Visit the middle tier</a></p>
      </body>
    </html>
    HTML
    if ! grep -RqsE '^[[:space:]]*LoadModule[[:space:]]+proxy_module[[:space:]]' /etc/httpd/conf.modules.d; then
      echo 'LoadModule proxy_module modules/mod_proxy.so' >> /etc/httpd/conf.modules.d/00-proxy.conf
    fi
    if ! grep -RqsE '^[[:space:]]*LoadModule[[:space:]]+proxy_http_module[[:space:]]' /etc/httpd/conf.modules.d; then
      echo 'LoadModule proxy_http_module modules/mod_proxy_http.so' >> /etc/httpd/conf.modules.d/00-proxy.conf
    fi
    cat > /etc/httpd/conf.d/middle-proxy.conf <<'APACHE'
    ProxyRequests Off
    ProxyPass /middle http://${module.middle_tier.private_ip}:8080/
    ProxyPassReverse /middle http://${module.middle_tier.private_ip}:8080/
    APACHE
    httpd -t
    systemctl enable --now httpd
  USERDATA
}

resource "aws_eip" "website" {
  domain   = "vpc"
  instance = module.client_tier.instance_id

  tags = {
    Name = "Nurudeen Website"
  }
}
