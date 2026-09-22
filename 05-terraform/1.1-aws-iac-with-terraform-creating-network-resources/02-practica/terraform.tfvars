aws_region = "eu-west-1"

vpc_name = "cmtr-iacp1ebx-01-vpc"
vpc_cidr = "10.10.0.0/16"

internet_gateway_name = "cmtr-iacp1ebx-01-igw"
route_table_name      = "cmtr-iacp1ebx-01-rt"

public_subnets = {
  a = {
    name              = "cmtr-iacp1ebx-01-subnet-public-a"
    cidr_block        = "10.10.1.0/24"
    availability_zone = "eu-west-1a"
  }
  b = {
    name              = "cmtr-iacp1ebx-01-subnet-public-b"
    cidr_block        = "10.10.3.0/24"
    availability_zone = "eu-west-1b"
  }
  c = {
    name              = "cmtr-iacp1ebx-01-subnet-public-c"
    cidr_block        = "10.10.5.0/24"
    availability_zone = "eu-west-1c"
  }
}
