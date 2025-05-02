terraform {
  backend "s3" {
    bucket         = "ce9g4.tfstate-backend.com"  # Must match the bucket name above
    key            = "infra/terraform.tfstate"        # State file path
    region         = "us-east-1"                # Same as provider
    dynamodb_table = "terraform-state-locks"    # If using DynamoDB
    # use_lockfile   = true                       # replaces dynamodb_table                
    encrypt        = true                       # Use encryption
  }
}

data "aws_availability_zones" "available" {}

locals {
  prefix = "myapp" # Change to your preferred prefix
 }

resource "aws_vpc" "main" {
 cidr_block = "10.0.0.0/16"

 tags = {
   Name = "${local.prefix}-vpc-eks"
 }
}

resource "aws_subnet" "public_subnet" {
 count                   = 2
 vpc_id                  = aws_vpc.main.id
 cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
 availability_zone       = data.aws_availability_zones.available.names[count.index]
 map_public_ip_on_launch = true

 tags = {
   Name = "public-subnet-${count.index}"
 }
}

resource "aws_internet_gateway" "main" {
 vpc_id = aws_vpc.main.id

 tags = {
   Name = "${local.prefix}-igw"
 }
}

resource "aws_route_table" "public" {
 vpc_id = aws_vpc.main.id

 route {
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.main.id
 }

 tags = {
   Name = "${local.prefix}-route-table"
 }
}

resource "aws_route_table_association" "a" {
 count          = 2
 subnet_id      = aws_subnet.public_subnet.*.id[count.index]
 route_table_id = aws_route_table.public.id
}
