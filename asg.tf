############################
# asg.tf — uses selected profile
############################

resource "aws_autoscaling_group" "asg" {
  # Use prefix to avoid AlreadyExists on replacement
  name_prefix               = "${var.asg_name}-"
  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity
  vpc_zone_identifier       = [for s in aws_subnet.public : s.id]
  health_check_type         = "EC2"
  capacity_rebalance        = true
  force_delete              = true

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.main.id
        version            = "$Latest"
      }

      # Build overrides from selected profile (or user override list)
      dynamic "override" {
        for_each = toset(local.effective_instance_types)
        content {
          instance_type = override.value
        }
      }
    }

    instances_distribution {
      spot_allocation_strategy                 = "capacity-optimized"
      on_demand_percentage_above_base_capacity = var.on_demand_percentage
    }
  }

  tag {
    key                 = "Name"
    value               = "app-spot-node"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true

    # Guard against arch/profile mismatch (e.g., arm profile with x86 AMI)
    precondition {
      condition     = contains(["x86","arm"], var.arch) && var.arch == local.selected_profile.arch
      error_message = "Profile arch (${local.selected_profile.arch}) must match var.arch (${var.arch})."
    }
  }
}
