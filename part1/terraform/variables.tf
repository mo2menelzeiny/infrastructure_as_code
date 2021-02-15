variable "profile" {
  default = "default"
}

variable "region" {
  default = "eu-north-1"
}

variable "public_key" {
  default = "~/.ssh/id_rsa.pub"
}

variable "ec2_size" {
  default = "t3.micro"
}

variable "centos8_ami_id" {
  default = "ami-0e201bc52c64d7b5a"
}
