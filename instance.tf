#Get Linux AMI
data "aws_ssm_parameter" "linxu-ami-master" {
  provider = aws.region-master
  name     = var.ami-path
}

data "aws_ssm_parameter" "linxu-ami-worker" {
  provider = aws.region-worker
  name     = var.ami-path
}


# output "ami_id" {
#   value     = data.aws_ssm_parameter.linxu-ami-master
#   sensitive = true
# }

#Create ssh keypair to login into EC2 instances

resource "aws_key_pair" "master-key" {
  provider   = aws.region-master
  key_name   = "jenkins"
  public_key = file("~/.ssh/id_rsa.pub")

}
resource "aws_key_pair" "worker-key" {
  provider   = aws.region-worker
  key_name   = "jenkins"
  public_key = file("~/.ssh/id_rsa.pub")

}

#Create EC2 instance for master-jenkins in us-east-1

resource "aws_instance" "jenkins-master" {
  provider                    = aws.region-master
  subnet_id                   = aws_subnet.master_subnet_1.id
  ami                         = data.aws_ssm_parameter.linxu-ami-master.value
  instance_type               = var.instance-type
  key_name                    = aws_key_pair.master-key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.jenkins-master.id]
  tags = {
    Name = "jenkins_master_tf"
  }
  depends_on = [aws_main_route_table_association.set-master-rt-assoc]


}


#Create EC2 instance for master-jenkins in us-east-1

resource "aws_instance" "jenkins-worker" {
  provider                    = aws.region-worker
  count                       = var.counts
  subnet_id                   = aws_subnet.subnet_1_worker.id
  ami                         = data.aws_ssm_parameter.linxu-ami-worker.value
  instance_type               = var.instance-type
  key_name                    = aws_key_pair.worker-key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.worker-sg.id]
  tags = {
    Name = join("_", ["jenkins_worker_tf", count.index + 1])
  }
  depends_on = [aws_main_route_table_association.set-worker-rt-assoc, aws_instance.jenkins-master]


}
