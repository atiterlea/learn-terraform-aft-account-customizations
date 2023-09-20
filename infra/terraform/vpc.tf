data "aws_region" "current" {}

resource "aws_vpc_ipam" "this" {
  description = "Global IPAM"
  operating_regions {
    region_name = data.aws_region.current.name
  }
}

resource "aws_vpc_ipam_pool" "this" {
  address_family = "ipv4"
  ipam_scope_id  = aws_vpc_ipam.this.private_default_scope_id
  locale         = data.aws_region.current.name
}

resource "aws_vpc_ipam_pool_cidr" "this" {
  ipam_pool_id = aws_vpc_ipam_pool.this.id
  cidr         = "10.0.0.0/8"
}

resource "aws_vpc" "this" {
  ipv4_ipam_pool_id   = aws_vpc_ipam_pool.this.id
  ipv4_netmask_length = 16
  tags = {
    Name = "dev"
  }
  depends_on = [
    aws_vpc_ipam_pool_cidr.this
  ]
}

resource "aws_subnet" "this" {
  vpc_id     = aws_vpc.this.id
  cidr_block = cidrsubnet(aws_vpc.this.cidr_block, 8, 0)
}

resource "aws_ram_resource_share" "this" {
  name                      = "dev"
  allow_external_principals = true
}

resource "aws_ram_resource_association" "this" {
  resource_arn       = aws_subnet.this.arn
  resource_share_arn = aws_ram_resource_share.this.arn
}
