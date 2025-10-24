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

Below are the 15 profies:
Profile ID	Arch	Purpose / Tier	Example Instance Types	vCPU (approx)	RAM (approx)	Disk (GB)	Notes
p1	x86	Ultra-cheap tiny	t3a.micro, t3.micro	2 vCPU	1 GB	8	Lowest cost x86 Spot; great for quick demos
p2	x86	Small	t3a.small, t3.small, t3a.micro	2 vCPU	2 GB	16	Ideal for lightweight test/demo apps
p3	x86	Medium (cheap)	t3a.medium, t3.medium, t3a.small	2 vCPU	4 GB	20	Most common baseline demo size
p4	x86	General Purpose (M5)	m5.large, m5.xlarge, m6i.large	2–4 vCPU	8–16 GB	40	Better performance while keeping cost low
p5	x86	General Purpose (M6i)	m6i.large, m6i.xlarge, m5.large	2–4 vCPU	8–16 GB	50	Modern gen GP; good mix of cost and stability
p6	x86	Compute Leaning (C5)	c5.large, c5.xlarge, c6i.large	2–4 vCPU	4–8 GB	30	Faster CPU, good for short compute bursts
p7	x86	Compute Leaning (C6i)	c6i.large, c6i.xlarge, c5.large	2–4 vCPU	4–8 GB	30	Newer gen, often cheap Spot
p8	x86	Memory Optimized (R5)	r5.large, r5.xlarge, r6i.large	2–4 vCPU	16–32 GB	60	Higher RAM for memory-heavy workloads
p9	x86	Memory Optimized (R6i)	r6i.large, r6i.xlarge, r5.large	2–4 vCPU	16–32 GB	80	Best for in-memory data stores, caches, SAP app server
p10	x86	IO-Heavy Demo (gp3)	m6i.large, m5.large, c6i.large	2–4 vCPU	8–16 GB	100	Shows gp3 disk tuning (IOPS/throughput)
p11	arm	Ultra-cheap tiny (Graviton)	t4g.micro, t4g.small	2 vCPU	1–2 GB	8	Cheapest ARM Spot; use with arm64 AMI
p12	arm	Small/Medium (T4g)	t4g.medium, t4g.small, t4g.large	2–4 vCPU	4–8 GB	20	ARM GP baseline
p13	arm	General Purpose (M6g)	m6g.medium, m6g.large, m7g.medium	2–4 vCPU	8–16 GB	40	Stable ARM GP profile
p14	arm	General Purpose (M7g)	m7g.medium, m7g.large, m6g.large	2–4 vCPU	8–16 GB	50	Newer gen Graviton
p15	arm	Compute Leaning (C7g)	c7g.large, c7g.xlarge, t4g.medium	2–4 vCPU	4–8 GB	30	High performance ARM compute
