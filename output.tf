######
output "vpc_id" {
  value = aws_vpc.my-vpc.id
}
output "public_subnet" {
  value = aws_subnet.public_subnet[*].id
}
output "privat_subnet" {
  value = aws_subnet.privat_subnet[*].id
}
output "db_endpoint" {
  value = aws_db_instance.my-db.id
}

output "db_sg_id" {
  value = aws_security_group.DB-sg.id
}

output "frontend-alb-endpoint" {
  value = aws_lb.Frontend-alb.id
}
