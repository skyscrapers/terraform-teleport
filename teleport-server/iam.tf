resource "aws_iam_instance_profile" "profile" {
  name_prefix = "teleport-${var.project}-${var.environment}-"
  role        = "${aws_iam_role.role.name}"
}

resource "aws_iam_role" "role" {
  name_prefix = "teleport-${var.project}-${var.environment}-"

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

resource "aws_iam_role_policy" "policy" {
  role   = "${aws_iam_role.role.id}"
  policy = "${data.aws_iam_policy_document.teleport.json}"
}

data "aws_iam_policy_document" "teleport" {
  statement {
    sid = "getR53"

    actions = [
      "route53:ListHostedZones",
      "route53:GetChange",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    sid = "changeR53"

    actions = [
      "route53:ChangeResourceRecordSets",
    ]

    resources = [
      "arn:aws:route53:::hostedzone/${data.aws_route53_zone.root.zone_id}",
    ]
  }

  statement {
    sid = "AllAPIActionsOnTeleportAuth"

    actions = [
      "dynamodb:*",
    ]

    resources = [
      "arn:aws:dynamodb:${data.aws_region.current.name}:*:table/${local.teleport_dynamodb_table}",
      "arn:aws:dynamodb:${data.aws_region.current.name}:*:table/${local.teleport_dynamodb_table}_events",
    ]
  }

  statement {
    sid = "CloudWatchLogsAccess"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = [
      "${aws_cloudwatch_log_group.teleport_audit.arn}",
      "${aws_cloudwatch_log_group.teleport_audit.arn}:*",
      "${aws_cloudwatch_log_group.teleport.arn}",
      "${aws_cloudwatch_log_group.teleport.arn}:*",
    ]
  }

  statement {
    sid = "S3EventAccess"

    actions = [
      "s3:Get*",
      "s3:Put*",
    ]

    resources = [
      "${aws_s3_bucket.sessions.arn}/*",
    ]
  }

  statement {
    sid = "S3EventListAccess"

    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "${aws_s3_bucket.sessions.arn}",
    ]
  }
}
