resource "aws_wafv2_ip_set" "ipsets" {
  name               = "${var.project}-${var.appname}-webacl-ipsets-opensearch-${var.env}"
  description        = "Whitelisted IP"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = var.whitelisted_ip_list

  tags = var.tags
}

resource "aws_wafv2_web_acl" "alb_web_acl" {
  name        = "${var.project}-${var.appname}-webacl-opensearch-${var.env}"
  description = "Rule"
  scope       = "REGIONAL"

  default_action {
    block {}
  }

  rule {
    name     = "rule-1"
    priority = 1

    action {
      allow {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.ipsets.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "${var.project}-${var.appname}-webacl-opensearch-${var.env}-rule"
      sampled_requests_enabled   = false
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "${var.project}-${var.appname}-webacl-opensearch-${var.env}-metric"
    sampled_requests_enabled   = false
  }

  tags = var.tags
}

resource "aws_wafv2_web_acl_association" "alb_association" {
  resource_arn = "arn:aws:es:ap-southeast-1:851725316377:domain/snapshot-web-opensearch-dev"
  web_acl_arn  = aws_wafv2_web_acl.alb_web_acl.arn
}
