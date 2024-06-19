resource "aws_iam_instance_profile" "profile" {
  name = "instance-profile-${var.appname}-${var.env}"
  role = aws_iam_role.role.name
}

resource "aws_iam_role" "role" {
  name = "iam-role-bastion-${var.appname}-${var.env}"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
