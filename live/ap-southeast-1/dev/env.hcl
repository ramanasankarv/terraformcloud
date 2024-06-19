locals {
  // # Global configuration
  environment = "dev"

  # BASTION VPC configuration
  vpc_public_subnet_id          = "subnet-0f1447c6816171101"

  # BASTION EC2
  ec2_instance_type = "t2.micro"
  ec2_ami_id        = "ami-0b287aaaab87c114d"

  # VPC
  vpc_id               = "vpc-03c482e2e8a957208"
  vpc_cidrs            = "10.10.0.0/16"
  vpc_azs              = ["ap-southeast-1a", "ap-southeast-1b"]

  #sample of subnets CIDR
  vpc_public_subnets   = ["10.10.1.0/24", "10.10.2.0/24"]
  vpc_private_subnets  = ["10.10.3.0/24", "10.10.4.0/24"]
  vpc_database_subnets = ["10.10.5.0/24", "10.10.6.0/24"]
  vpc_opensearch_subnets = ["10.10.7.0/24", "10.10.8.0/24"]

  #DNS
  cloudfront_aliases = []  #list of cloudfront aliases aka hostname for the frontend
  alb_hostname = ""  #hostname for the api

  alb_acm_certificate_arn = "arn:aws:acm:ap-southeast-1:851725316377:certificate/25ad79e4-ef75-4bcb-bdad-48371f478827" #certificate arn for the api
  route53_public_hosted_zone_id = "Z07135393W1OD487FTIO9"  #route53 zone id for the technical zone

  cf_acm_certificate_arn = "" #cloudfront certificate that match cloudfront aliases

  # RDS
  rds_instance_class = "db.m6gd.large"
  rds_engine_version = "10.11.6"
  rds_engine = "mariadb"
  rds_allocated_storage = "100"
}
