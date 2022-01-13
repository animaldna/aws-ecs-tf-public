module "s3" {
  source = "../s3_alb_log_bucket"

  resource_prefix = var.resource_prefix
  aws_account_id  = var.aws_account_id
  env             = var.env
}

resource "aws_lb" "service_alb" {
  name            = "${var.resource_prefix}-alb"
  security_groups = var.security_groups
  access_logs {
    bucket  = module.s3.alb_log_bucket
    enabled = true
  }
  subnets = var.public_subnets
}

resource "aws_lb_target_group" "service_target_group" {
  name        = "${var.resource_prefix}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  deregistration_delay = 90
}

resource "aws_lb_listener" "alb_80_listener" {
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.service_target_group.arn
  }
  load_balancer_arn = aws_lb.service_alb.arn
  port              = 80
  protocol          = "HTTP"
}

resource "aws_lb_listener" "alb_443_listener" {
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.service_target_group.arn
  }
  load_balancer_arn = aws_lb.service_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.acm_cert
}