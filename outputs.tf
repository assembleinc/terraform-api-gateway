output "gateway_id" {
  value = "${aws_api_gateway_rest_api.gateway.id}"
}

output "gateway_root_resource_id" {
  value = "${aws_api_gateway_rest_api.gateway.root_resource_id}"
}

output "getaway_fpdn" {
  value = "${local.fqdn}"
}
