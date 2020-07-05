terraform {
  backend "s3" {
    bucket = "mybucket" # Will be overridden from build
    key    = "path/to/my/key" # Will be overridden from build
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_availability_zones" "available" {
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = module.vpc.vpc_id
}

module "vpc" {

  source  = "terraform-aws-modules/vpc/aws"
  version = "2.6.0"
  name = "complete-example"

  cidr = "20.10.0.0/16" # 10.0.0.0/8 is reserved for EC2-Classic

  #azs                 = ["us-east-1a", "us-east-1b", "us-east-1c"]
  azs                  = data.aws_availability_zones.available.names
  private_subnets     = ["20.10.1.0/24", "20.10.2.0/24", "20.10.3.0/24"]
  public_subnets      = ["20.10.11.0/24", "20.10.12.0/24", "20.10.13.0/24"]
  database_subnets    = ["20.10.21.0/24", "20.10.22.0/24", "20.10.23.0/24"]

  create_database_subnet_group = false
 
  database_subnet_tags = {
    "tier" = "database"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
    "tier" = "k8s_subnet"
  }

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway = true
  single_nat_gateway = true

#  enable_dhcp_options              = true

  tags = {
    Owner       = "user"
    Environment = "staging"
    Name        = "complete"
  }

}

