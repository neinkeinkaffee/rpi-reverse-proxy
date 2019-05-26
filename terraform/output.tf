output "proxy.eip" {
  value = "${aws_eip.proxy_eip.public_ip}"
}

output "proxy.public_ip" {
  value = "${aws_instance.proxy.public_ip}"
}