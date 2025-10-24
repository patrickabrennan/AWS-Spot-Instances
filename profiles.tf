#########################################
# profiles.tf — 15 selectable profiles
#########################################

# Curated instance-type sets + gp3 root volume per profile.
# Choose with var.profile_id = "p1".."p15". You can override any field via vars.

locals {
  profiles = {
    # Ultra-cheap burstable (x86)
    p1 = {
      name           = "x86-tiny"
      arch           = "x86"
      instance_types = ["t3a.micro", "t3.micro"]
      ebs = { type = "gp3", size_gb = 8,  iops = 3000, throughput = 125 }
    }

    p2 = {
      name           = "x86-small"
      arch           = "x86"
      instance_types = ["t3a.small", "t3.small", "t3a.micro", "t3.micro"]
      ebs = { type = "gp3", size_gb = 16, iops = 3000, throughput = 125 }
    }

    p3 = {
      name           = "x86-medium-cheap"
      arch           = "x86"
      instance_types = ["t3a.medium", "t3.medium", "t3a.small", "t3.small"]
      ebs = { type = "gp3", size_gb = 20, iops = 3000, throughput = 125 }
    }

    # General purpose (x86)
    p4 = {
      name           = "x86-gp-m5"
      arch           = "x86"
      instance_types = ["m5.large", "m5.xlarge", "m6i.large"]
      ebs = { type = "gp3", size_gb = 40, iops = 3000, throughput = 125 }
    }

    p5 = {
      name           = "x86-gp-m6i"
      arch           = "x86"
      instance_types = ["m6i.large", "m6i.xlarge", "m5.large"]
      ebs = { type = "gp3", size_gb = 50, iops = 3000, throughput = 125 }
    }

    # Compute-leaning (x86)
    p6 = {
      name           = "x86-c5"
      arch           = "x86"
      instance_types = ["c5.large", "c5.xlarge", "c6i.large"]
      ebs = { type = "gp3", size_gb = 30, iops = 3000, throughput = 125 }
    }

    p7 = {
      name           = "x86-c6i"
      arch           = "x86"
      instance_types = ["c6i.large", "c6i.xlarge", "c5.large"]
      ebs = { type = "gp3", size_gb = 30, iops = 3000, throughput = 125 }
    }

    # Memory-leaning (x86)
    p8 = {
      name           = "x86-r5"
      arch           = "x86"
      instance_types = ["r5.large", "r5.xlarge", "r6i.large"]
      ebs = { type = "gp3", size_gb = 60, iops = 3000, throughput = 250 }
    }

    p9 = {
      name           = "x86-r6i"
      arch           = "x86"
      instance_types = ["r6i.large", "r6i.xlarge", "r5.large"]
      ebs = { type = "gp3", size_gb = 80, iops = 6000, throughput = 250 }
    }

    # IO-heavy demo (x86) — showcase gp3 tunables
    p10 = {
      name           = "x86-io-gp3-high"
      arch           = "x86"
      instance_types = ["m6i.large", "m5.large", "c6i.large"]
      ebs = { type = "gp3", size_gb = 100, iops = 8000, throughput = 500 }
    }

    # ARM / Graviton (cheap in many regions)
    p11 = {
      name           = "arm-t4g-tiny"
      arch           = "arm"
      instance_types = ["t4g.micro", "t4g.small"]
      ebs = { type = "gp3", size_gb = 8,  iops = 3000, throughput = 125 }
    }

    p12 = {
      name           = "arm-t4g-medium"
      arch           = "arm"
      instance_types = ["t4g.medium", "t4g.small", "t4g.large"]
      ebs = { type = "gp3", size_gb = 20, iops = 3000, throughput = 125 }
    }

    p13 = {
      name           = "arm-gp-m6g"
      arch           = "arm"
      instance_types = ["m6g.medium", "m6g.large", "m7g.medium"]
      ebs = { type = "gp3", size_gb = 40, iops = 3000, throughput = 125 }
    }

    p14 = {
      name           = "arm-gp-m7g"
      arch           = "arm"
      instance_types = ["m7g.medium", "m7g.large", "m6g.large"]
      ebs = { type = "gp3", size_gb = 50, iops = 3000, throughput = 125 }
    }

    p15 = {
      name           = "arm-compute-c7g"
      arch           = "arm"
      instance_types = ["c7g.large", "c7g.xlarge", "t4g.medium"]
      ebs = { type = "gp3", size_gb = 30, iops = 3000, throughput = 125 }
    }
  }

  # Select profile; default to p1 if unknown id
  selected_profile = lookup(local.profiles, var.profile_id, local.profiles.p1)

  # Effective instance list: prefer user override if non-empty, else profile list
  # coalescelist() returns the first non-empty list.
  effective_instance_types = coalescelist(
    var.instance_type_overrides_override,
    local.selected_profile.instance_types
  )

  # Effective EBS root: each field can be overridden
  effective_ebs = {
    type       = coalesce(var.ebs_volume_type_override,    local.selected_profile.ebs.type)
    size_gb    = coalesce(var.ebs_volume_size_gb_override, local.selected_profile.ebs.size_gb)
    iops       = coalesce(var.ebs_iops_override,           local.selected_profile.ebs.iops)
    throughput = coalesce(var.ebs_throughput_override,     local.selected_profile.ebs.throughput)
  }
}
