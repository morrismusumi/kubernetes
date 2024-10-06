# IAM Role
resource "aws_iam_role" "ec2_ssm" {
  name = "${upper(var.project_name)}_EC2SSMRole"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sts:AssumeRole"
            ],
            "Principal": {
                "Service": [
                    "ec2.amazonaws.com"
                ]
            }
        }
    ]
})
}

# IAM Permission Policy
resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role       = aws_iam_role.ec2_ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "ec2_ssm" {
  name = "${upper(var.project_name)}_EC2SSMInstanceProfile"
  role = aws_iam_role.ec2_ssm.name
}