locals {
  overrides = [for t in var.instance_type_overrides : { instance_type = t }]
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
        for_each = local.overrides
        content {
          instance_type = override.value.instance_type
          # weighted_capacity = "1" # optional if mixing sizes
        }
      }
    }

    instances_distribution {
      on_demand_percentage_above_base_capacity = 0
      spot_allocation_strategy                 = "capacity-optimized-prioritized"
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

