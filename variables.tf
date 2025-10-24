variable "region" { 
  type = string  
  default = "us-east-1" 
}

# ── VPC & subnets (derived, not hard-coded)
variable "vpc_cidr" { 
  type = string  
  default = "10.42.0.0/16" 
}

variable "num_subnets" {
  type = number  
  default = 3 
}

variable "azs" {
  type = list(string) 
  default = [] 
} # [] = auto-pick

variable "subnet_newbits" {
  type = number  
  default = 8 
}       # /24 from /16

# ── Security
variable "allowed_ingress_ports" {
  description = "TCP ports to allow (e.g., [22, 3389])"
  type        = list(number)
  default     = [22, 3389]
}

variable "ingress_cidrs" {
  type = list(string) 
  default = ["0.0.0.0/0"] 
}

# ── ASG / LT
variable "asg_name" {
  type = string 
  default = "app-spot-asg" 
}

variable "desired_capacity" {
  type = number 
  default = 3 
}

variable "min_size" {
  type = number 
  default = 0 
}

variable "max_size" {
  type = number 
  default = 6 
}

variable "key_name" {
  type = string 
  default = null
}

# Architecture for AMI / types
variable "arch" {
  description = "CPU architecture: 'x86' (t3/t3a/m5/m6i/...) or 'arm' (t4g/m6g/m7g/...)"
  type        = string
  default     = "x86"
  validation {
    condition     = contains(["x86","arm"], var.arch)
    error_message = "arch must be 'x86' or 'arm'."
  }
}

# Small On-Demand spillover (0 = 100% Spot)
variable "on_demand_percentage" {
  description = "Percent above base to run On-Demand (set 0 for pure Spot)"
  type        = number
  default     = 0
}

# ── Profile selection + optional overrides (15 presets defined in profiles.tf)
variable "profile_id" {
  description = "Choose a profile p1..p15 for CPU/memory/disk class"
  type        = string
  default     = "p1"
}

variable "instance_type_overrides_override" {
  description = "Override the profile's instance types list for Spot (leave [] to use profile)"
  type        = list(string)
  default     = []
}

variable "ebs_volume_type_override" {
  type = string 
  default = null 
}

variable "ebs_volume_size_gb_override" {
  type = number 
  default = null 
}

variable "ebs_iops_override" {
  type = number 
  default = null 
}

variable "ebs_throughput_override" {
  type = number 
  default = null 
}
