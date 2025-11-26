resource "aws_db_subnet_group" "my-subgroup" {
  name       = "my-subgroup"
  subnet_ids = [aws_subnet.privat_subnet[1].id, aws_subnet.privat_subnet[2].id]

  tags = {
    Name = "my-subgroup"
  }
}

resource "aws_db_instance" "my-db" {
  allocated_storage    = 10
  db_name              = "mydb"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  db_subnet_group_name = aws_db_subnet_group.my-subgroup.name
  username             = "admin"
  password             = "admin123"
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  vpc_security_group_ids  = [aws_security_group.DB-sg.id]
}