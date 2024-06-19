#S3 Bucket on Which we will add policy
resource "aws_s3_bucket" "create-bucket"{
  bucket = var.bucketname
  tags = var.tags
}


#Resource to add bucket policy to a bucket 
resource "aws_s3_bucket_policy" "public_read_access" {
  bucket = aws_s3_bucket.create-bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "s3:GetObject"
        Effect    = "Allow"
        Resource  = "${aws_s3_bucket.create-bucket.arn}/*"
        Principal = {
          AWS = "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${aws_cloudfront_origin_access_identity.s3_oai.id}"
        }
      },
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::851725316377:role/snapshot-web-ecs-execution-cms-role-dev"
        },
        Action = [
          "s3:AbortMultipartUpload",
          "s3:GetObject*",
          "s3:List*",
          "s3:PutObject*",
        ],
        Resource = [
          aws_s3_bucket.create-bucket.arn,
          "${aws_s3_bucket.create-bucket.arn}/*"
        ]
      },
      {
        Sid = "DenyInsecureTransport",
        Effect = "Deny",
        Principal = "*",
        Action = "s3:*",
        Resource =[
          aws_s3_bucket.create-bucket.arn,
          "${aws_s3_bucket.create-bucket.arn}/*"
        ],
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}


#A resource to enable versioning on bucket
resource "aws_s3_bucket_versioning" "versioning_apply" {
  bucket = aws_s3_bucket.create-bucket.bucket
  versioning_configuration {
    status = "Enabled"
  }
}

#Resource to enable encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "default-encryption" {
  bucket = aws_s3_bucket.create-bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "s3_owner_ship" {
  bucket = aws_s3_bucket.create-bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

#Adds an ACL to bucket
resource "aws_s3_bucket_acl" "create_bucket_acl" {
  bucket = aws_s3_bucket.create-bucket.bucket
  depends_on = [
    aws_s3_bucket_ownership_controls.s3_owner_ship,
    aws_s3_bucket_public_access_block.create_public_block,
  ]

  acl    = "private"
}

#Block Public Access
resource "aws_s3_bucket_public_access_block" "create_public_block" {
  bucket = aws_s3_bucket.create-bucket.bucket

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

resource "aws_cloudfront_origin_access_identity" "s3_oai" {
  comment = "My origin access identity"
}

# Create Cloudfront distribution
resource "aws_cloudfront_distribution" "prod_distribution" {
    origin {
        origin_id   = aws_s3_bucket.create-bucket.id
        domain_name = aws_s3_bucket.create-bucket.bucket_regional_domain_name

        origin_path = "/assets/s3fs-public"

        s3_origin_config {
          origin_access_identity = aws_cloudfront_origin_access_identity.s3_oai.cloudfront_access_identity_path
        }
    }
    
    enabled = true
    
    default_cache_behavior {
        allowed_methods  = ["GET", "HEAD"]
        cached_methods   = ["GET", "HEAD"]
        target_origin_id = aws_s3_bucket.create-bucket.id

        forwarded_values {
          query_string = false
          cookies {
            forward = "none"
          }
        }

        viewer_protocol_policy = "redirect-to-https"
        min_ttl                = 0
        default_ttl            = 3600
        max_ttl                = 86400
    }
    
    # Restricts who is able to access this content
    restrictions {
        geo_restriction {
            # type of restriction, blacklist, whitelist or none
            restriction_type = "none"
        }
    }

    # SSL certificate for the service.
    viewer_certificate {
        cloudfront_default_certificate = true
    }

    tags = var.tags
}