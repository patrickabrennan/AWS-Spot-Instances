region = "us-east-1"
asg_name = "app-spot-asg"

# VPC / subnets (derived)
vpc_cidr       = "10.42.0.0/16"
num_subnets    = 3
azs            = []                # or ["us-east-1a","us-east-1b","us-east-1c"]
subnet_newbits = 8                 # /24s from a /16

# SG ingress
allowed_ingress_ports = [22, 3389]
ingress_cidrs         = ["0.0.0.0/0"]  # tighten in real envs

# ASG sizing
min_size         = 0
max_size         = 6
desired_capacity = 3

# Pick which of the 15 profiles to use
profile_id = "p2"   # e.g., x86 small — see list below

# Architecture must match the profile (x86 or arm)
arch = "x86"        # for p1–p10 use "x86", for p11–p15 use "arm"

# Optional overrides (leave empty to use profile defaults)
instance_type_overrides_override = []
ebs_volume_type_override    = null
ebs_volume_size_gb_override = null
ebs_iops_override           = null
ebs_throughput_override     = null

# Spot behavior
on_demand_percentage = 0  # 0 = pure Spot, >0 adds small On-Demand buffer
# Optional
key_name = "sap"
