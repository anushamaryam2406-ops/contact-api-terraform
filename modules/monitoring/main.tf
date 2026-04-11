# ============================================================================
# SNS TOPIC
# ============================================================================
resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-alerts-${var.environment}"

  tags = {
    Name = "${var.project_name}-alerts"
  }
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# ============================================================================
# CLOUDWATCH ALARMS
# ============================================================================
resource "aws_cloudwatch_metric_alarm" "post_contact_errors" {
  alarm_name        = "${var.project_name}-post-errors-${var.environment}"
  alarm_description = "Alert when POST Lambda has errors"

  namespace   = "AWS/Lambda"
  metric_name = "Errors"
  dimensions = {
    FunctionName = var.post_contact_function_name
  }

  statistic           = "Sum"
  period              = var.alarm_period
  evaluation_periods  = 1
  threshold           = var.error_threshold
  comparison_operator = "GreaterThanThreshold"

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  treat_missing_data = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "get_messages_errors" {
  alarm_name        = "${var.project_name}-get-errors-${var.environment}"
  alarm_description = "Alert when GET Lambda has errors"

  namespace   = "AWS/Lambda"
  metric_name = "Errors"
  dimensions = {
    FunctionName = var.get_messages_function_name
  }

  statistic           = "Sum"
  period              = var.alarm_period
  evaluation_periods  = 1
  threshold           = var.error_threshold
  comparison_operator = "GreaterThanThreshold"

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  treat_missing_data = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "post_contact_duration" {
  alarm_name        = "${var.project_name}-post-duration-${var.environment}"
  alarm_description = "Alert when POST Lambda is too slow"

  namespace   = "AWS/Lambda"
  metric_name = "Duration"
  dimensions = {
    FunctionName = var.post_contact_function_name
  }

  statistic           = "Average"
  period              = var.alarm_period
  evaluation_periods  = 1
  threshold           = var.duration_threshold
  comparison_operator = "GreaterThanThreshold"

  alarm_actions = [aws_sns_topic.alerts.arn]

  treat_missing_data = "notBreaching"
}