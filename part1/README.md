Build Hello World! ami for private servers using packer
also uses ami id from manifest to spawn the private instances inside terraform dir

`cd packer`

`packer build template.pkr.hcl`

`cd terraform`

`terraform apply`

The dynamic inventory is generated using terraform output template
