#Security group for Load balancer
resource "aws_security_group" "lb-sg" {
  provider    = aws.region-master
  name        = "lb-sg"
  description = "Allow 443 traffic to Jenkins SG"
  vpc_id      = aws_vpc.vpc_master.id

  ingress {
    description = "Allow 443 from anywhere"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"

  }
  ingress {
    description = "Allow 443 from anywhere"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
}

#Security Group for Jenkins Master

resource "aws_security_group" "jenkins-master" {
  provider    = aws.region-master
  name        = "jenkins-sg"
  description = "Allow traffic from 8080 and 22"
  vpc_id      = aws_vpc.vpc_master.id

  ingress {
    description     = "allw traffic from lb vi porta 8080"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.lb-sg.id]

  }
  ingress {
    description = "allw traffic from 22"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.external_ip

  }
  ingress {
    description = "Allow traffic from Peer VPCS instance us-west2"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["192.168.0.0/16"]
  }
  egress {
    description = "Outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
}


#Security Group for Jenkins Workers
resource "aws_security_group" "worker-sg" {
  provider    = aws.region-worker
  name        = "worker-sg"
  description = "Allow traffic from Jenkins master"
  vpc_id      = aws_vpc.vpc_worker.id
  ingress {
    description = "Allow ssh port from specific ip"
    from_port   = 22
    to_port     = 22
    cidr_blocks = var.external_ip
    protocol    = "tcp"
  }

  ingress {
    description = "Allow tcp traffic from jenkin master use-east-1"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    description = "Out bound traffic"
    cidr_blocks = ["0.0.0.0/0"]
  }

}