Build Hello World! ami for private servers using packer
inside packer dir
`packer build template.pkr.hcl`
Use ami id from manifest to spawn the private instances
inside terraform dir
`terraform apply`
The dynamic inventory is generated using terraform output template
