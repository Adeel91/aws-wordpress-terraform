output "bastion_public_ip" {
  value = aws_instance.ec2_bastion_host.public_ip
}

output "ec2_wordpress_az1_id" {
  value = aws_instance.ec2_wordpress_az1.id
}

output "ec2_wordpress_az2_id" {
  value = aws_instance.ec2_wordpress_az2.id
}