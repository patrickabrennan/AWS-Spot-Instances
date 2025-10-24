# AWS-Spot-Instances
Terraform setup that creates a VPC + public subnets and wires them into a persistent Spot ASG (Mixed Instances Policy), with your original knobs plus an optional Spot max bid.

It gives you:

VPC, Internet Gateway, public route table, N public subnets spread across AZs

Security group (egress all; configurable ingress ports/CIDRs)

Launch Template + ASG (100% Spot, capacity-optimized-prioritized)

15 selectable performance profiles (CPU/Memory/Network), IO fully overridable

Optional spot_max_price ceiling










This Terraform code gives you “capacity-optimized-prioritized” Spot allocation in an Auto Scaling Group with Mixed Instances Policy.

In this mode, you do not explicitly set a Spot bid price — AWS automatically bids the current Spot market price and tries to keep capacity stable.

If you want to specify a bid price manually, AWS supports it only with:

aws_spot_instance_request (per-instance spot requests)

or by adding max_price in the launch template overrides for the ASG as shown below:

add a spot_options block inside the launch template:

resource "aws_launch_template" "lt" {
  name_prefix = "${var.name}-lt-"
  image_id    = coalesce(var.ami_id, data.aws_ami.al2023.id)

  instance_type = local.chosen_profile.allowed_instance_types[0]

  instance_market_options {
    market_type = "spot"
    spot_options {
      max_price = var.spot_max_price # e.g. "0.08"
    }
  }

  # ... rest of your launch template (LT) config
}

Notes

“Persistent” Spot is achieved by the ASG, which automatically replaces interrupted Spot instances across the best pools.

Bid control: set spot_max_price = "0.12" (string). Leave null to use market price (recommended for stability with capacity-optimized).

Ingress is configurable; add/remove ports per your workload (e.g., 22, 3389, 80/443).

Subnets are public (public IPs on launch). If you need private subnets + NAT, I can add that variant too.
