output "asg_alarm_arn" {
  value = aws_cloudwatch_metric_alarm.asg_high_cpu.arn
}