output "Jenkins-Master-Public-Ip" {
  value = aws_instance.jenkins-master.public_ip
}

output "Jenkins-worker-Public-IP" {
  value = {
    for instance in aws_instance.jenkins-worker :
    instance.id => instance.public_ip
  }
}

output "LB-DNS-NAME" {
  value = aws_lb.application-lb.dns_name
}