resource "aws_iam_role" "teleport" {
  name_prefix = "teleport-task-${var.project}-"

  assume_role_policy = <<EOF
{
 "Version": "2008-10-17",
 "Statement": [
   {
     "Sid": "",
     "Effect": "Allow",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Action": "sts:AssumeRole"
   }
 ]
}
EOF
}

module "iam_policy" {
  source          = "../teleport-auth-iam-policy"
  role_id         = "${aws_iam_role.teleport.id}"
  dynamodb_table  = "${var.dynamodb_table}"
  dynamodb_region = "${var.aws_region}"
}
