data "aws_region" "current" {}

data "aws_security_group" "rds_sg" {
  tags = {
    Name        = "${var.project}-${var.appname}-rds-${var.env}"
    Environment = var.env
    Project     = var.project
    Customer    = var.appname
  }
}
