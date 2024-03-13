terraform {
  required_version	= "~> 1.1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "af-south-1"
  profile = "AWSPowerUserAccess-591243144041"
}

#data "aws_vpc" "default" {
#  default = true
#}

data "aws_availability_zones" "available" {}

# use data source to get all avalablility zones in region
data "aws_availability_zones" "available_zones" {}

resource "aws_rds_cluster_instance" "cluster_instances" {
#  identifier         = "test-tf-to-delete"
  cluster_identifier         = "test-tf-to-delete"
  instance_class     = "db.t3.micro"
  engine             = "aurora-postgresql"
  engine_version     = "16.1"
}

resource "aws_rds_cluster" "default" {
  cluster_identifier = "aurora-cluster-demo"
  engine             = "aurora-postgresql"
  availability_zones = ["af-south-1a", "af-south-1b", "af-south-1c"]
  database_name      = "mydb"
  master_username    = "foo"
  master_password    = "barbut8chars"
  backup_retention_period = 7
  preferred_backup_window = "07:00-09:00"

    tags = {
    "Service Description" = "test-tf-to-delete"
  }
}

# use data source to get all avalablility zones in region
data "aws_security_group" "security_groups" {
    filter {
    name   = "tag:Service Description"
    values = ["INSURE IOT NONP"]
  }
}
 
data "aws_vpc" "main" {
    filter {
    name   = "tag:Name"
    values = ["dsy-discovery-insure-non-prod-insure-dsy-private-591243144041-vpc-af-south-1"]
  }
}

# create security group for the database
resource "aws_security_group" "database_security_group" {
  name        = "database security group"
  description = "enable aurora access on port 5432"
  #vpc_id      = "vpc-0b96fbb17237c558a"
  #vpc_id      = data.aws_vpc.default.id 
  vpc_id            = data.aws_vpc.main.id


  ingress {
    description      = "aurora access"
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
  #  security_groups  = ["sg-0998e6e929c46bf89"]
#    security_groups  = [aws_security_group.database_security_group.name]
  #  security_groups  = [data.aws_security_group.security_groups.name[0]]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    "Service Description" = "test-tf-sg"
  }
}


