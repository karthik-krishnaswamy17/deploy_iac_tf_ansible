variable "profile" {
  type    = string
  default = "default"
}
variable "region-master" {
  type    = string
  default = "us-east-1"

}
variable "region-worker" {
  type    = string
  default = "us-west-2"

}
variable "ami-path"{
  type = string
  default = "/aws/service/ami-amazon-linux-latest/amzn2-ami-kernel-5.10-hvm-x86_64-gp2"
}

variable "counts" {
  type    = number
  default = 1

}
variable "instance-type" {
  type    = string
  default = "t3.micro"
}
variable "external_ip" {
  default = ["0.0.0.0/0"]

}