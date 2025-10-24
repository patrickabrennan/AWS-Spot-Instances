output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnet_ids" {
  value = [for s in aws_subnet.public : s.id]
}

output "asg_name" {
  value = aws_autoscaling_group.asg.name
}

output "launch_template_id" {
  value = aws_launch_template.main.id
}

