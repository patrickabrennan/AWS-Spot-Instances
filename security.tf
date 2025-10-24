resource "aws_security_group" "instance_sg" {
  name        = "app-spot-sg"
  description = "Ingress per port list; egress all"
  vpc_id      = aws_vpc.main.id

  dynamic "ingress" {
    for_each = toset(var.allowed_ingress_ports)
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = var.ingress_cidrs
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "app-spot-sg" }
}

