#create master vpc in us-east-1
resource "aws_vpc" "vpc_master" {
  provider             = aws.region-master
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "master-vpc-jenkins"
  }
}


#create worker vpc in us-west-2
resource "aws_vpc" "vpc_worker" {
  provider             = aws.region-worker
  cidr_block           = "192.168.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "worker-vpc-jenkins"
  }
}

#Create internet gateway
resource "aws_internet_gateway" "igw" {
  provider = aws.region-master
  vpc_id   = aws_vpc.vpc_master.id

}


resource "aws_internet_gateway" "igw-worker" {
  provider = aws.region-worker
  vpc_id   = aws_vpc.vpc_worker.id

}


#Get available zone in Master VPC
data "aws_availability_zones" "azs" {
  provider = aws.region-master
  state    = "available"
}

#Create subnet in us-east-1

resource "aws_subnet" "master_subnet_1" {
  vpc_id            = aws_vpc.vpc_master.id
  provider          = aws.region-master
  cidr_block        = "10.0.1.0/24"
  availability_zone = element(data.aws_availability_zones.azs.names, 0)

}
resource "aws_subnet" "master_subnet_2" {
  vpc_id            = aws_vpc.vpc_master.id
  provider          = aws.region-master
  cidr_block        = "10.0.2.0/24"
  availability_zone = element(data.aws_availability_zones.azs.names, 1)

}


data "aws_availability_zones" "azs-worker" {
  provider = aws.region-worker
  state    = "available"
}
#Creat subnet in us-west-2

resource "aws_subnet" "subnet_1_worker" {
  provider          = aws.region-worker
  vpc_id            = aws_vpc.vpc_worker.id
  cidr_block        = "192.168.1.0/24"
  availability_zone = element(data.aws_availability_zones.azs-worker.names, 0)

}

resource "aws_subnet" "subnet_2_worker" {
  provider          = aws.region-worker
  vpc_id            = aws_vpc.vpc_worker.id
  cidr_block        = "192.168.2.0/24"
  availability_zone = element(data.aws_availability_zones.azs-worker.names, 1)

}

#Initate Peering connectionfrom us-east1 to uswest2

resource "aws_vpc_peering_connection" "useast1-uswest2" {
  provider    = aws.region-master
  vpc_id      = aws_vpc.vpc_master.id
  peer_vpc_id = aws_vpc.vpc_worker.id
  peer_region = var.region-worker

}

#Accept VPC peering in us-west2 from us-east1

resource "aws_vpc_peering_connection_accepter" "accept_peering" {
  provider                  = aws.region-worker
  vpc_peering_connection_id = aws_vpc_peering_connection.useast1-uswest2.id
  auto_accept               = true

}
#Create route table in us-east-1
resource "aws_route_table" "internet-route" {
  provider = aws.region-master
  vpc_id   = aws_vpc.vpc_master.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  route {
    vpc_peering_connection_id = aws_vpc_peering_connection.useast1-uswest2.id
    cidr_block                = "192.168.0.0/16"
  }
  lifecycle {
    ignore_changes = all
  }
  tags = {
    Name = "Master-Region-RT"
  }
}

resource "aws_main_route_table_association" "set-master-rt-assoc" {
  provider       = aws.region-master
  vpc_id         = aws_vpc.vpc_master.id
  route_table_id = aws_route_table.internet-route.id

}

resource "aws_route_table" "internet-route-worker" {
  provider = aws.region-worker
  vpc_id   = aws_vpc.vpc_worker.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-worker.id
  }
  route {
    vpc_peering_connection_id = aws_vpc_peering_connection.useast1-uswest2.id
    cidr_block                = "10.0.0.0/16"
  }
  lifecycle {
    ignore_changes = all
  }
  tags = {
    Name = "Worker-Region-RT"
  }
}
resource "aws_main_route_table_association" "set-worker-rt-assoc" {
  provider       = aws.region-worker
  vpc_id         = aws_vpc.vpc_worker.id
  route_table_id = aws_route_table.internet-route-worker.id

}

