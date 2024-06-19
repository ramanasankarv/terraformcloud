resource "aws_vpc_endpoint" "s3_endpoint" {
  service_name = "com.amazonaws.ap-southeast-1.s3"

  # Linking the endpoint to the VPC
  vpc_id          = var.vpc_id
  route_table_ids = var.route_table_ids

  vpc_endpoint_type = "Gateway"

  tags = var.tags
}
