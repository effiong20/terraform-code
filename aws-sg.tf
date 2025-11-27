resource "aws_security_group" "Bastian-host-sg" {
  name        = "Bastian-host-sg"
  description = "Allow SSH traffic"
  vpc_id      = aws_vpc.my-vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Bastian-host-sg"
  }
}

resource "aws_security_group" "Frontend-alb-sg" {
  name        = "Frontend-alb-sg"
  description = "Allow HTTP traffic"
  vpc_id      = aws_vpc.my-vpc.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Frontend-alb-sg"
  }
}

resource "aws_security_group" "Frontend-server-sg" {
  name        = "Frontend-server-sg"
  description = "Allow HTTP SSH traffic"
  vpc_id      = aws_vpc.my-vpc.id

  ingress {
    description     = "HTTP"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.Frontend-alb-sg.id]

  }
  ingress {
    description     = "SSH"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.Bastian-host-sg.id]

  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Frontend-server-sg"
  }
}

resource "aws_security_group" "Backend-alb-sg" {
  name        = "Backend-alb-sg"
  description = "Allow HTTP and SSHtraffic"
  vpc_id      = aws_vpc.my-vpc.id

  ingress {
    description     = "HTTP"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.Frontend-server-sg.id]

  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Backend-alb-sg"
  }
}

resource "aws_security_group" "App-server-sg" {
  name        = "App-server-sg"
  description = "Allow HTTP and SSH traffic"
  vpc_id      = aws_vpc.my-vpc.id

  ingress {
    description     = "HTTP"
    from_port       = 3200
    to_port         = 3200
    protocol        = "tcp"
    security_groups = [aws_security_group.Backend-alb-sg.id]

  }
  ingress {
    description     = "SSH"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.Bastian-host-sg.id]

  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "App-server-sg"
  }
}

resource "aws_security_group" "DB-sg" {
  name        = "DB-sg"
  description = "Allow HTTP and SSH traffic"
  vpc_id      = aws_vpc.my-vpc.id

  ingress {
    description     = "MYSQL"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.App-server-sg.id]

  }
  ingress {
    description     = "SSH"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.Bastian-host-sg.id]

  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "DB-sg"
  }
}
