# Build a lookup for cheap demo instance types by arch
locals {
  cheap_overrides_map = {
    arm = toset([
      "t4g.micro", "t4g.small", "t4g.medium",
      "m7g.medium", "m7g.large",
      "m6g.medium", "m6g.large"
    ])
    x86 = toset([
      "t3a.micro", "t3a.small", "t3a.medium",
      "t3.micro",  "t3.small",  "t3.medium",
      # a few fallbacks if t-family is tight
      "m5.large", "c5.large", "r5.large"
    ])
  }

  cheap_overrides = local.cheap_overrides_map[var.arch]
}

resource "aws_autoscaling_group" "asg" {
  name                      = var.asg_name
  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity
  vpc_zone_identifier       = [for s in aws_subnet.public : s.id]
  health_check_type         = "EC2"
  capacity_rebalance        = true

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.main.id
        version            = "$Latest"
      }

      dynamic "override" {
        for_each = local.cheap_overrides
        content {
          instance_type = override.value
        }
      }
    }

    instances_distribution {
      spot_allocation_strategy                 = "capacity-optimized"
      on_demand_percentage_above_base_capacity = var.on_demand_percentage
      # on_demand_base_capacity = 0
    }
  }

  tag {
    key                 = "Name"
    value               = "app-spot-node"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
