output "vpc_id" {
  value = aws_vpc.networking.id
}

output "public_subnets" {
  value = [aws_subnet.networking.*.id]
}

output "public_route_table_ids" {
  value = [aws_route_table.networking.id]
}
