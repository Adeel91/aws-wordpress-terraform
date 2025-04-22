output "public_subnet_names_and_ids" {
  value = module.public_subnet.subnets
}

output "private_subnet_names_and_ids" {
  value = module.private_subnet.subnets
}