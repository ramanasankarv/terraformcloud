resource "random_password" "opensearch_password" {
  length  = var.random_password_length
  special = false
}

resource "aws_secretsmanager_secret" "opensearch_password" {
  name        = "opensearch_password-${var.env}"
  description = "opensearch Password"  
  recovery_window_in_days = 0  
  tags = {
    Name        = "opensearch_password"
    Environment = var.env
  }
}

resource "aws_secretsmanager_secret_version" "opensearch_password" {
  secret_id     = aws_secretsmanager_secret.opensearch_password.id
  secret_string = random_password.opensearch_password.result
}

resource "aws_security_group" "opensearch_sg" {
  name        = "${var.project}-${var.appname}-opensearch-${var.env}"
  description = "Security group for opensearch with custom ports open within VPC, and opensearch publicly open"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project}-${var.appname}-rds-${var.env}"
    Environment = var.env
    Project     = var.project
    Customer    = var.appname
  }  
}

module "opensearch" {
  source = "terraform-aws-modules/opensearch/aws"


  # Domain
  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
  }

  advanced_security_options = {
    enabled                        = false
    anonymous_auth_enabled         = true
    internal_user_database_enabled = true

    master_user_options = {
      master_user_name = "master-user"
      master_user_password = random_password.opensearch_password.result
    }
  }

  auto_tune_options = {
    desired_state = "DISABLED"
    rollback_on_disable = "NO_ROLLBACK"
  }

  cluster_config = {
    instance_count           = 2
    dedicated_master_enabled = true
    dedicated_master_type    = "t3.small.search"
    instance_type            = "t3.small.search"

    zone_awareness_config = {
      availability_zone_count = 2
    }

    zone_awareness_enabled = true
  }

  domain_endpoint_options = {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  domain_name = "${var.project}-${var.appname}-opensearch-${var.env}"

  ebs_options = {
    ebs_enabled = true
    iops        = 3000
    throughput  = 125
    volume_type = "gp3"
    volume_size = 10
  }

  encrypt_at_rest = {
    enabled = true
  }

  engine_version = "OpenSearch_2.13"

  log_publishing_options = [
    { log_type = "INDEX_SLOW_LOGS" },
    { log_type = "SEARCH_SLOW_LOGS" },
  ]

  node_to_node_encryption = {
    enabled = true
  }

  software_update_options = {
    auto_software_update_enabled = true
  }

  vpc_options = {
    subnet_ids = var.public_subnets
  }

  # VPC endpoint
  vpc_endpoints = {
    one = {
      subnet_ids = var.public_subnets
    }
  }

  # Access policy
  access_policy_statements = [
    {
      effect = "Allow"

      principals = [{
        type        = "*"
        identifiers = ["*"]
      }]

      actions = ["es:*"]

      condition = [{
        test     = "IpAddress"
        variable = "aws:SourceIp"
        values   = ["0.0.0.0/0"]
      }]
    }
  ]

  tags = {
    Terraform   = "true"
    Environment = "${var.env}"
  }
}

