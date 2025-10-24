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

# Spot overrides
instance_type_overrides_override = [
  "m6i.large",
  "c6i.large",
  "r6i.large",
  "m7i-flex.large",
  "c7i.large",
  "r7i.large"
]

# Optional
key_name = null

