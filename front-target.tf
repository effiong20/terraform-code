resource "aws_lb_target_group" "presentation-target" {
  name     = "presentation-targe"
  port     = 80
  protocol = "HTTP"
 health_check {
    enabled  = true
    interval = 10
    path     = "/health"
    port     = 80
    protocol = "HTTP"
    timeout  = 5
    matcher  = "200"
  }
  vpc_id   = aws_vpc.my-vpc.id
}

#resource "aws_lb_target_group_attachment" "presentation1-target" {
#  target_group_arn = aws_lb_target_group.presentation-target.arn
#  target_id        = aws_lb_target_group.presentation-target.id
 # port             = 80
#}

resource "aws_lb" "Frontend-alb" {
  name               = "frontend-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.Frontend-alb-sg.id]
  subnets            = [aws_subnet.public_subnet[0].id, aws_subnet.public_subnet[1].id, aws_subnet.public_subnet[2].id]

  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_listener" "frontalb-lsiten" {
  load_balancer_arn = aws_lb.Frontend-alb.arn
  port              = "80"
  protocol          = "HTTP"
 
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.presentation-target.arn
  }
}