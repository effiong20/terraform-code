data "aws_ami" "my-amazon-image" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


resource "aws_launch_template" "web-template" {
  name_prefix   = "web-template-"
  image_id      = data.aws_ami.my-amazon-image.id
  instance_type = "t2.micro"
  key_name      = "sample-key"

  vpc_security_group_ids = [aws_security_group.Frontend-server-sg.id]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>Web Server ${random_id.server.hex}</h1>" > /var/www/html/index.html
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "web-server"
    }
  }
}

resource "aws_autoscaling_group" "web-asg" {
  name                = "web-asg"
  vpc_zone_identifier = [aws_subnet.public_subnet[0].id, aws_subnet.public_subnet[1].id]
  target_group_arns   = [aws_lb_target_group.presentation-target.arn]
  health_check_type   = "ELB"
  min_size            = 1
  max_size            = 3
  desired_capacity    = 2

  launch_template {
    id      = aws_launch_template.web-template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "web-asg-instance"
    propagate_at_launch = true
  }
}

resource "random_id" "server" {
  byte_length = 4
}
