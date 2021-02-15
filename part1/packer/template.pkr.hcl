source "amazon-ebs" "hello-world-centos8" {
  ami_name = "hello-world-centos8"
  source_ami = "ami-0e201bc52c64d7b5a"
  instance_type = "t3.micro"
  ssh_username = "centos"
}

build {
  sources = [
    "source.amazon-ebs.hello-world-centos8"
  ]

  provisioner "shell" {
    inline = [
      "echo Connected!"
    ]
  }

  provisioner "ansible" {
    playbook_file = "../ansible/private.yml"
  }

  post-processor "manifest" {}
}