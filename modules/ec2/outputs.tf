output "ec2_instances" {
  value = {
    for instance_name, instance in aws_instance.this :
    instance_name => {
      id = instance.id
      public_ip = instance.associate_public_ip_address ? instance.public_ip : null
    }
  }
}

# output "bastion_public_ip" {
#   value = aws_instance.ec2_bastion_host.public_ip
# }

# output "ec2_wordpress_az1_id" {
#   value = aws_instance.ec2_wordpress_az1.id
# }

# output "ec2_wordpress_az2_id" {
#   value = aws_instance.ec2_wordpress_az2.id
# }