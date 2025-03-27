resource "aws_cloudwatch_log_group" "log_group" {
  count             = "${var.vpc_flow_logs["log_destination_type"]}" == "cloud-watch-logs" ? 1 : 0
  name              = "${var.vpc_flow_logs["log_group_name"]}"
  retention_in_days = "${var.vpc_flow_logs["log_retention_days"]}"

  tags = {
    Environment = var.environment
  }
}

# IAM Role for Flow Logs
resource "aws_iam_role" "flow_log_role" {
  name = "vpc-flow-log-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "vpc-flow-logs.amazonaws.com"
      }
    }]
  })

  tags = {
    Environment = var.environment
  }
}

# IAM Policy for CloudWatch Logging
resource "aws_iam_policy" "flow_log_policy" {
  name        = "vpc-flow-log-policy-${var.environment}"
  description = "Policy for VPC Flow Logs"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams",
        "logs:PutLogEvents"
      ],
      Resource = "${var.vpc_flow_logs["log_destination_type"]}" == "cloud-watch-logs" ? aws_cloudwatch_log_group.log_group[0].arn : "*"
    }]
  })
}

# Attach IAM Policy to Role
resource "aws_iam_role_policy_attachment" "flow_log_policy_attachment" {
  role       = aws_iam_role.flow_log_role.name
  policy_arn = aws_iam_policy.flow_log_policy.arn
}

# Enable VPC Flow Logs
resource "aws_flow_log" "vpc_flow_logs" {
  vpc_id              =  aws_vpc.vpc[0].id
  traffic_type        = "${var.vpc_flow_logs["traffic_type"]}"
  log_destination_type = "${var.vpc_flow_logs["log_destination_type"]}"
  log_destination     = "${var.vpc_flow_logs["log_destination_type"]}" == "cloud-watch-logs" ? aws_cloudwatch_log_group.log_group[0].arn : null
  iam_role_arn        = "${var.vpc_flow_logs["log_destination_type"]}" == "cloud-watch-logs" ? aws_iam_role.flow_log_role.arn : null

  tags = {
    Environment = var.environment
  }

  depends_on = [
    aws_cloudwatch_log_group.log_group,
    aws_iam_role.flow_log_role
  ]
}