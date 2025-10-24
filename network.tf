data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  # Use provided AZs if non-empty; otherwise take the first N available
  selected_azs = coalescelist(
    var.azs,
    slice(
      data.aws_availability_zones.available.names,
      0,
      min(var.num_subnets, length(data.aws_availability_zones.available.names))
    )
  )
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "app-spot-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "app-spot-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "app-spot-public-rt"
  }
}

resource "aws_subnet" "public" {
  count                   = length(local.selected_azs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, var.subnet_newbits, count.index)
  availability_zone       = local.selected_azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "app-spot-public-${count.index + 1}"
  }
}

resource "aws_route_table_association" "public_assoc" {
  count          = length(local.selected_azs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

