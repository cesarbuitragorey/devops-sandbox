aws_region  = "us-east-1"
name_prefix = "ansible-lab"
domain      = "example.com"

machines = {
  control = { host_number = 10 }
  node1   = { host_number = 11 }
  node2   = { host_number = 12 }
}

instance_type    = "t3.micro"
root_volume_size = 10

ami_owner_id     = "125523088429"
ami_name_pattern = "CentOS Stream 9 x86_64 *"
ssh_user         = "ec2-user"

public_key_path       = "~/.ssh/ansible_lab.pub"
private_key_file_name = "ansible_lab"

allowed_ssh_cidr = "190.255.115.133/32"
collectd_port    = 9103

tags = {
  Project = "ansible-practical-task"
  Owner   = "cesar.buitrago"
}
