provider "aws" {
  region = "us-west-2"
}

module "s3_backend" {
  source      = "./modules/s3-backend"
  bucket_name = "serhii-terraform-state-lesson-5"
  table_name  = "terraform-locks"
}

module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr_block     = "10.0.0.0/16"
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets    = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
  vpc_name           = "lesson-8-9-vpc"
}

module "rds" {
  source = "./modules/rds"

  name       = "lesson-db"
  use_aurora = false

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids

  allowed_cidr_blocks = ["10.0.0.0/16"]

  db_name  = "appdb"
  username = "dbadmin"
  password = var.db_password

  engine         = "postgres"
  engine_version = "16.13"
  instance_class = "db.t3.micro"

  allocated_storage = 20
  multi_az          = false

  publicly_accessible = false

  tags = {
    Project = "lesson-db-module"
    Managed = "terraform"
  }
}

module "ecr" {
  source       = "./modules/ecr"
  ecr_name     = "lesson-8-9-ecr"
  scan_on_push = true
}

module "eks" {
  source       = "./modules/eks"
  cluster_name = "lesson-8-9-eks"
  subnet_ids   = module.vpc.private_subnet_ids
}

module "jenkins" {
  source       = "./modules/jenkins"
  cluster_name = module.eks.cluster_name
}

module "argo_cd" {
  source = "./modules/argo_cd"

  cluster_name = module.eks.cluster_name
}