output "subnets" {
  description = "A map of subnet names to their IDs and CIDR blocks"
  value = {
    for idx, subnet in aws_subnet.this :
    "${var.project_name}-${var.is_public ? "public" : "private"}-subnet${idx + 1}" => {
      id   = subnet.id
      cidr = subnet.cidr_block
    }
  }
}
