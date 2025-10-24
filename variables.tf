variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

# --- VPC & Subnet derivation (no hard-coded subnet CIDRs) ---
variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.42.0.0/16"
}

variable "num_subnets" {
  description = "How many public subnets to create"
  type        = number
  default     = 3
}

variable "azs" {
  description = "Optional list of AZs to use. Leave [] to auto-pick the first num_subnets AZs"
  type        = list(string)
  default     = []
}

variable "subnet_newbits" {
  description = "How many additional bits to add when splitting VPC CIDR for subnets (cidrsubnet)"
  type        = number
  default     = 8
}

# --- Security ---
variable "allowed_ingress_ports" {
  description = "List of TCP ports to allow (e.g., [22, 3389])"
  type        = list(number)
  default     = [22, 3389]
}

variable "ingress_cidrs" {
  description = "List of CIDRs allowed for ingress on the above ports"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# --- ASG / LT / Spot ---
variable "asg_name" {
  description = "ASG name"
  type        = string
  default     = "app-spot-asg"
}

variable "desired_capacity" {
  type    = number
  default = 3
}

variable "min_size" {
  type    = number
  default = 0
}

variable "max_size" {
  type    = number
  default = 6
}

variable "instance_type_overrides" {
  description = "Prioritized instance types for Spot (top is highest priority)"
  type        = list(string)
  default = [
    "m6i.large",
    "c6i.large",
    "r6i.large",
    "m7i-flex.large",
    "c7i.large",
    "r7i.large"
  ]
}

variable "key_name" {
  description = "Optional EC2 key pair"
  type        = string
  default     = null
}

