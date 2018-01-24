resource "aws_iam_role_policy" "policy" {
  role   = "${var.role_id}"
  policy = "${data.aws_iam_policy_document.teleport.json}"
}

data "aws_iam_policy_document" "teleport" {
  statement {
    sid = "AllAPIActionsOnTeleportAuth"

    actions = [
      "dynamodb:*",
    ]

    resources = [
      "arn:aws:dynamodb:${var.dynamodb_region}:*:table/${var.dynamodb_table}",
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
      "arn:aws:logs:*:*:log-group:teleport_audit_log",
      "arn:aws:logs:*:*:log-group:teleport_audit_log:*",
    ]
  }
}
