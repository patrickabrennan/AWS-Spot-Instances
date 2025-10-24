# AMIs for each arch (keep in sync with var.arch)
data "aws_ssm_parameter" "al2023_x86" { name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64" }
data "aws_ssm_parameter" "al2023_arm" { name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-arm64" }

locals {
  image_id = var.arch == "arm" ? data.aws_ssm_parameter.al2023_arm.value : data.aws_ssm_parameter.al2023_x86.value
  user_data_b64 = base64encode("#!/bin/bash\necho 'demo: $(uname -m) $(hostname)' > /etc/motd")
}

resource "aws_launch_template" "main" {
  name_prefix            = "app-spot-lt-"
  image_id               = local.image_id
  # Default only; ASG overrides will pick actual types
  instance_type          = var.arch == "arm" ? "t4g.small" : "t3a.small"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.instance_sg.id]
  user_data              = local.user_data_b64

  # Root volume from selected profile (with user overrides applied)
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_type           = local.effective_ebs.type
      volume_size           = local.effective_ebs.size_gb
      iops                  = local.effective_ebs.iops
      throughput            = local.effective_ebs.throughput
      delete_on_termination = true
      encrypted             = true
    }
  }

  # IMPORTANT: Do NOT set instance_market_options here (ASG controls Spot)

  tag_specifications {
    resource_type = "instance"
    tags = { Name = "app-spot-node" }
  }

  lifecycle {
    create_before_destroy = true
  }
}
