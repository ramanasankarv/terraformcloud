locals {
  // # Global configuration
  environment = "uat"

  # BASTION VPC configuration
  vpc_public_subnet_id          = "<one of a public subnet id>"

  # BASTION EC2
  ec2_instance_type = "t2.micro"
  ec2_ami_id        = "ami-0eb375f24fdf647b8"

  # VPC
  vpc_cidrs            = "11.10.0.0/16"
  vpc_azs              = ["ap-southeast-1a", "ap-southeast-1b"]

  #sample of subnets CIDR
  vpc_public_subnets   = ["11.10.1.0/24", "11.10.2.0/24"]
  vpc_private_subnets  = ["11.10.3.0/24", "11.10.4.0/24"]
  vpc_database_subnets = ["11.10.5.0/24", "11.10.6.0/24"]
  vpc_opensearch_subnets = ["11.10.7.0/24", "11.10.8.0/24"]

  #DNS
  cloudfront_aliases = []  #list of cloudfront aliases aka hostname for the frontend
  alb_hostname = ""  #hostname for the api

  alb_acm_certificate_arn = "#" #certificate arn for the api
  route53_public_hosted_zone_id = ""  #route53 zone id for the technical zone

  cf_acm_certificate_arn = "" #cloudfront certificate that match cloudfront aliases

  # RDS
  rds_instance_class = "db.m6gd.large"
  rds_engine_version = "10.6.14"
  rds_engine = "mariadb"
  rds_allocated_storage = "100"
}
