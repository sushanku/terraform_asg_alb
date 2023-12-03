# Configure the AWS provider
provider "aws" {
  region = "us-east-1" # Replace with your desired AWS region
  access_key = "XXXXXXXXXXX"
  secret_key = "XXXXXXXXXXXXXXXXXXXXXXX"
}

# Create the ALB
resource "aws_lb" "example_alb" {
  name               = "example-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = ["${var.subnet_id1}", "${var.subnet_id2}"] # Replace with your subnet IDs

  enable_deletion_protection = false
}

# Create the ALB listener
resource "aws_lb_listener" "example_listener" {
  load_balancer_arn = aws_lb.example_alb.arn
  port              = "80" # Change the port to 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.example_tg.arn
  }
}

# Create the target group
resource "aws_lb_target_group" "example_tg" {
  name     = "example-tg"
  port     = 8080 # Change the port to 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}" # Replace with your VPC ID

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Create the ASG
resource "aws_autoscaling_group" "example_asg" {
  name                      = "example-asg"
  max_size                  = 5
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 2
  force_delete              = true
  launch_configuration      = aws_launch_configuration.example_lc.name
  vpc_zone_identifier       = ["${var.subnet_id1}", "${var.subnet_id2}"] # Replace with your subnet IDs

  target_group_arns = [aws_lb_target_group.example_tg.arn]
}

# Create the launch configuration
resource "aws_launch_configuration" "example_lc" {
  name_prefix     = "example-lc-"
  image_id        = "ami-083e83736ef0c4ef3" # Replace AMI ID created by packer
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.instance_sg.id]

#   associate_public_ip_address = false
  
  user_data = filebase64("./app_start.sh")

  lifecycle {
    create_before_destroy = true
  }
}

# Create security groups for http traffic
resource "aws_security_group" "alb_sg" {
  name        = "allow_http"
  description = "Allow HTTP inbound traffic"
  vpc_id      = "${var.vpc_id}" # Replace with your VPC ID

  ingress {
    from_port   = 80 # Change the port to 80
    to_port     = 80 # Change the port to 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "instance_sg" {
  name        = "allow_http_from_alb"
  description = "Allow HTTP inbound traffic from ALB"
  vpc_id      = "${var.vpc_id}" # Replace with your VPC ID

  ingress {
    from_port       = 80 # Change the port to 80
    to_port         = 8080 # Change the port to 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}
