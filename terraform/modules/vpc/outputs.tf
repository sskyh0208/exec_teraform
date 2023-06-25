output "vpc" {
    value = aws_vpc.main
}

output "sn_pub_a" {
    value = aws_subnet.sn_pub_a
}

output "sn_pub_b" {
    value = aws_subnet.sn_pub_b
}

output "sn_priv_a" {
    value = aws_subnet.sn_priv_a
}

output "sn_priv_b" {
    value = aws_subnet.sn_priv_b
}

output "sg_alb" {
    value = aws_security_group.sg_alb
}

output "sg_ecs" {
    value = aws_security_group.sg_ecs
}