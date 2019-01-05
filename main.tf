locals {
  fqdn         = "${var.gateway_name}.${var.domain_name}"
  domain_name  = "${var.domain_name}"
  gateway_name = "${var.gateway_name}"
  stage_name   = "${var.stage_name}"
}

resource "aws_api_gateway_rest_api" "gateway" {
  name = "${local.gateway_name}"
}

data "aws_route53_zone" "zone" {
  name = "${local.domain_name}"
}

# ACM Requires the certificates to be created in US-EAST-1
resource "aws_acm_certificate" "ssl_cert" {
  domain_name       = "${local.fqdn}"
  validation_method = "DNS"
  provider          = "aws.us-east-1"
}

resource "aws_api_gateway_deployment" "gateway_deployment" {
  stage_name  = "${local.stage_name}"
  rest_api_id = "${aws_api_gateway_rest_api.gateway.id}"
}

resource "aws_route53_record" "cert_validation" {
  name    = "${aws_acm_certificate.ssl_cert.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.ssl_cert.domain_validation_options.0.resource_record_type}"
  records = ["${aws_acm_certificate.ssl_cert.domain_validation_options.0.resource_record_value}"]
  ttl     = "3600"
  zone_id = "${data.aws_route53_zone.zone.zone_id}"
}

resource "aws_api_gateway_domain_name" "gateway_domain" {
  depends_on  = ["aws_route53_record.cert_validation"]
  domain_name = "${local.fqdn}"

  certificate_arn = "${aws_acm_certificate.ssl_cert.arn}"
}

resource "aws_route53_record" "gateway_record" {
  zone_id = "${data.aws_route53_zone.zone.id}"
  name    = "${aws_api_gateway_domain_name.gateway_domain.domain_name}"
  type    = "A"

  alias {
    name                   = "${aws_api_gateway_domain_name.gateway_domain.cloudfront_domain_name}"
    zone_id                = "${aws_api_gateway_domain_name.gateway_domain.cloudfront_zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_api_gateway_base_path_mapping" "gateway_path_mapping" {
  api_id      = "${aws_api_gateway_rest_api.gateway.id}"
  stage_name  = "${aws_api_gateway_deployment.gateway_deployment.stage_name}"
  domain_name = "${aws_api_gateway_domain_name.gateway_domain.domain_name}"
}
