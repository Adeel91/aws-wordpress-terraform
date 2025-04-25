output "bastion_public_ip" {
  value = aws_instance.ec2_bastion_host.public_ip
}
