#Variables
variable "aws_vpc" {}
variable "subnet_public1" {}
variable "subnet_public2" {}
variable "lb-security-group" {}
variable "aws_instance-ec2" {}

#Ouputs to pass to root
output "lb-dns-name" {
  value = aws_lb.lb-nginx.dns_name
}


# Load Balancer
resource "aws_lb" "lb-nginx" {
  name               = "ec2-lb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [var.lb-security-group]
  subnets            = [var.subnet_public1, var.subnet_public2]
}

# Target group
resource "aws_alb_target_group" "ec2" {
  name     = "nginx-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.aws_vpc

  health_check {
    path                = "/"
    port                = "traffic-port"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 2
    interval            = 60
    matcher             = "200"
  }
}


resource "aws_lb_target_group_attachment" "ec2" {
  target_group_arn = aws_alb_target_group.ec2.arn
  target_id        = var.aws_instance-ec2
  port             = 80
}


resource "aws_lb_listener" "ec2-lb-http-listener" {
  load_balancer_arn = aws_lb.lb-nginx.id
  port              = "80"
  protocol          = "HTTP"
  depends_on        = [aws_alb_target_group.ec2]

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.ec2.arn
  }
}

