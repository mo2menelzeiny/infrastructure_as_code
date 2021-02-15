output "nat" {
  value = aws_nat_gateway.part1
}

output "private_instances" {
  value = aws_instance.part1_private
}

output "public_instances" {
  value = aws_instance.part1_public
}

resource "local_file" "inventory" {
  filename = "../ansible/inventory.yml"
  content = templatefile("inventory.tpl", {
    private_instances = aws_instance.part1_private,
    public_instances = aws_instance.part1_public
  })
}