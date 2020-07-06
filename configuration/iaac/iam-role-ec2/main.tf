terraform {
  backend "s3" {
    bucket = "mybucket" # Will be overridden from build
    key    = "path/to/my/key" # Will be overridden from build
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_role" "ec2_s3_access_role" {
  name               = "saas-am-role-for-ec2-for-s3"
  assume_role_policy = "${file("assumerolepolicy.json")}"
}

resource "aws_iam_policy" "policy" {
  name        = "saas-s3-policy"
  description = "IAM policy for S3"
  policy      = "${file("policys3bucket.json")}"
}

resource "aws_iam_policy_attachment" "saas-iam-role-policy-attach" {
  name       = "saas-iam-role-policy-attach"
  roles      = ["${aws_iam_role.ec2_s3_access_role.name}"]
  policy_arn = "${aws_iam_policy.policy.arn}"
}

resource "aws_iam_instance_profile" "iam_ec2_instance_profile" {
  name  = "iam_ec2_instance_profile"
  role = "${aws_iam_role.ec2_s3_access_role.name}"
}
