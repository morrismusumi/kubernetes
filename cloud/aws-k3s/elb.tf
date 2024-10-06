# Create a load balancer target group
resource "aws_lb_target_group" "target_group_main" {
  name     = "k3s-tg"
  port     = 6443
  protocol = "TCP"
  vpc_id   = aws_vpc.vpc_main.id
  tags = {
    Name = "${var.project_name}_tg"
  }
}

# Attach instaces to target group
resource "aws_lb_target_group_attachment" "target_group_attachment" {
  count = var.node_count
  target_group_arn = aws_lb_target_group.target_group_main.arn
  target_id        = aws_instance.k8s_node[count.index].id
  port             = 6443
}

# Create a application load balancer
resource "aws_lb" "nlb_main" {
  name               = "k3s-nlb"
  internal           = false
  load_balancer_type = "network"
  security_groups    = [aws_security_group.sg_main.id]
  subnets            = [for subnet in aws_subnet.public : subnet.id]

  tags = {
    Name = "${var.project_name}_nlb"
  }
}

# Add listener to load balancer
resource "aws_lb_listener" "anb_listener_main" {
  load_balancer_arn = aws_lb.nlb_main.arn
  port              = "6443"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group_main.arn
  }
}