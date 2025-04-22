output "subnets" {
  description = "A map of subnet names to their IDs"
  value = {
    for idx, subnet in aws_subnet.this :
    "${var.project_name}-${var.is_public ? "public" : "private"}-subnet${idx + 1}" => subnet.id
  }
}