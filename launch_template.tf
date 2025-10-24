# Neutral Launch Template (no instance_market_options)
# Example AMI: Amazon Linux 2023 (x86_64). Swap to Windows if desired.
data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64"
}

locals {
  user_data_b64 = base64encode("#!/bin/bash\necho 'Hello from Spot node $(hostname)' > /etc/motd")
}

resource "aws_launch_template" "main" {
  name_prefix   = "app-spot-lt-"
  image_id      = data.aws_ssm_parameter.al2023_ami.value
  instance_type = var.instance_type_overrides[0]
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.instance_sg.id]
  user_data              = local.user_data_b64

  tag_specifications {
    resource_type = "instance"
    tags = { Name = "app-spot-node" }
  }

  lifecycle {
    create_before_destroy = true
  }
}

