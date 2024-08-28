resource "aws_lb_target_group" "web-tg" {
  name             = "web-tg"
  target_type      = "instance"
  port             = 80
  protocol         = "HTTP"
  ip_address_type  = "ipv4"
  vpc_id           = aws_vpc.web-vpc.id
  protocol_version = "HTTP1"
  health_check {
    protocol            = "HTTP"
    path                = "/"
    healthy_threshold   = 5
    unhealthy_threshold = 5
    timeout             = 5
    interval            = 30
  }
  tags = {
    Name = "web-tg"
  }
}

resource "aws_lb" "web-lb" {
  load_balancer_type = "application"
  name               = "web-lb"
  internal           = false
  ip_address_type    = "ipv4"

  security_groups = [aws_security_group.web-sg.id]
  subnets         = [aws_subnet.public-sn-1a.id, aws_subnet.public-sn-1b.id]
}

# Resources for security group
resource "aws_security_group" "web-sg" {
  name        = "web-sg"
  description = "web-sg"
  vpc_id      = aws_vpc.web-vpc.id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "ingress route for SG"
  }

  ingress {
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
}

resource "aws_lb_listener" "web-listener" {
  protocol = "HTTP"
  port     = 80

  load_balancer_arn = aws_lb.web-lb.id
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web-tg.id
  }
}
