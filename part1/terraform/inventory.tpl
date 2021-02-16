all:
  children:
    private:
      hosts:
    %{ for index, instance in private_instances ~}
    ${instance.private_ip}:
    %{ endfor ~}

    public:
      hosts:
    %{ for index, instance in public_instances ~}
    ${instance.public_ip}:
    %{ endfor ~}
