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
