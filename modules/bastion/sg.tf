
resource "aws_security_group" "default" {
  name_prefix = "${var.appname}-${var.env}-sg"
  description = "Security group for bastion host"
  vpc_id      = var.bastion_vpc_id

  # Session Manager : https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-prerequisites.html
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
