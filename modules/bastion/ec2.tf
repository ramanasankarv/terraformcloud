data "aws_security_group" "rds_sg" {
  tags = {
    Name        = "${var.project}-${var.appname}-rds-${var.env}"
    Environment = var.env
    Project     = var.project
    Customer    = var.appname
  }
}
resource "aws_security_group" "ssh_access" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["185.15.129.9/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = var.bastion_vpc_id
  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_key_pair" "my_key" {
  key_name   = "canon"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDD7FdIUfySgYvnqjt31LI40WFEj+cPNrcF+/dCJ3giE4eqHN7CwvnKW/sPnZ2EHCZDPG1Geeor8N9ABpxr1gcrk3VbVYYqIPPjlkig9DIBQFyv0yA0x0y3vdy20vhz9qlNDjwpW0b8LrTwa1BnPqrnFbztKdAGjuqc3o83+edA9nZxL+XKS33d0lZzA9F4dylKXnqZgNHjqt8618kzc/e9wmHIcypTuFTaKfLCk4nSLfDoxc/w0hpn1jW6uSUW7dHcWqYjuS5bW9GdZbVbdRMDIo96Cj5gCAt1gT16kekbC84fNA3IDvd4SgAbmwr9+wtN/SjQvb4RXfqlUlc8SFyWJ9I0A1Mvt9+MR3AeOnGVUDxrCieSmT/M7v2M0PjMMt67RvcJlsK63Of749D1HwVWXeZQchDoQmHpwyew54mCWQPHOAMqAhPRfg0i/BoXbwJhBUlcrxBv/144FUJTuxhdnvcakM8AMd8DOFxNce1WQWzLSqmWWbJZVLzfU96Hpn0= ramanasankar.v@in-blr-wks517.GLOBALSERVS"  # replace with the path to your public key
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 4.1.4"

  name = "bastion-${var.appname}-${var.env}"

  ami           = var.bastion_ami_id
  instance_type = var.bastion_instance_type
  monitoring    = true
  subnet_id     = var.bastion_subnet_id

  key_name = aws_key_pair.my_key.key_name
  
  associate_public_ip_address = true

  iam_instance_profile = aws_iam_instance_profile.profile.name

  vpc_security_group_ids = [aws_security_group.default.id, data.aws_security_group.rds_sg.id,aws_security_group.ssh_access.id]
  
  root_block_device = [
    {
      encrypted = true
    }
  ]

  tags = merge(
    var.tags,
    {
      type = "bastion"
    }
  )
}


resource "aws_ssm_association" "update_ssm_agent" {
  name          = "AWS-UpdateSSMAgent"
  association_name = "update-ssm-agent-association"
  targets {
    key    = "InstanceIds"
    values = var.instance_ids
  }
  schedule_expression = "rate(1 day)" # Check and update SSM agent daily
  compliance_severity = "CRITICAL"
}