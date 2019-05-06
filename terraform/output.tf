output "proxy.ip" {
  value = "${aws_instance.proxy.public_ip}"
}