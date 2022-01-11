data "aws_elb_service_account" "elb_srvc_account" {}

data "template_file" "alb_log_bucket_policy" {
  template = file("${path.module}/log_bucket_policy.json")

  vars = {
    bucket_name    = "${var.resource_prefix}-alb-logs"
    elb_account_id = data.aws_elb_service_account.elb_srvc_account.id
    aws_account_id = var.aws_account_id
  }
}

resource "aws_s3_bucket" "alb_log_bucket" {
  bucket        = "${var.resource_prefix}-alb-logs"
  acl           = "log-delivery-write"
  force_destroy = var.env == "prod" ? false : true
  policy        = data.template_file.alb_log_bucket_policy.rendered
}