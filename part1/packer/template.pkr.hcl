source "amazon-ebs" "hello-world-centos8" {
  ami_name = "hello-world-centos8"
  source_ami = "ami-0e201bc52c64d7b5a"
  instance_type = "t3.micro"
  ssh_username = "centos"

  tag {
    key = "Name"
    value = "hello-world-centos8"
  }

}

build {
  sources = [
    "source.amazon-ebs.hello-world-centos8"
  ]

  provisioner "shell" {
    inline = [
      "sudo yum install -y epel-release",
      "sudo yum install -y ansible"
    ]
  }

  provisioner "ansible-local" {
    playbook_file = "ansible/private.yml"
    playbook_dir = "ansible"
  }

  post-processor "manifest" {}
}