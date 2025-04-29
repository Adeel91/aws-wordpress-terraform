output "ec2_instances" {
  value = {
    for instance_name, instance in aws_instance.this :
    instance_name => {
      id = instance.id
      public_ip = instance.associate_public_ip_address ? instance.public_ip : null
    }
  }
}