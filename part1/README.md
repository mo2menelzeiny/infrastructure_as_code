1 - Build Hello World! ami for private servers using packer and ansible to configure nginx

`packer build template.pkr.hcl`

2 - Deploy terraform resources and regenerate the dynamic inventory using terraform output template

`terraform apply`

3 - Run Ansible playbook to configure public servers from the generated inventory

`ansible-playbook -i inventory.yaml public.yaml`

