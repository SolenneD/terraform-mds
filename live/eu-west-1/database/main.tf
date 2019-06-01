# Configure the AWS Provider
provider "aws" {
  region                      = "eu-west-1"
  version                     = "~> 2.11.0"
  skip_credentials_validation = true
  access_key = "[ACCESS_KEY]"
  secret_key = "[SECRET_KEY]"
}

//variables.tf


resource "aws_vpc" "main" {
  cidr_block           = "172.20.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "sub" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "172.20.10.0/24"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "sub"
  }
}

resource "aws_subnet" "sup" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "172.20.11.0/24"
  availability_zone = "eu-west-1b"

  tags = {
    Name = "sup"
  }
}

resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = ["${aws_subnet.sub.id}", "${aws_subnet.sup.id}"]

  tags = {
    Name = "dbsososubnet"
  }
}

//security.tf
resource "aws_security_group" "ingress-all-test" {
  name   = "allow-all-sg"
  vpc_id = "${aws_vpc.main.id}"

  ingress {
    cidr_blocks = [
      "172.20.0.0/16",
    ]

    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
  }

  ingress {
    cidr_blocks = [
      "0.0.0.0/0",
    ]

    from_port = 22
    to_port   = 22
    protocol  = "tcp"
  }

  ingress {
    cidr_blocks = [
      "0.0.0.0/0",
    ]

    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"
  }



  // Terraform removes the default rule
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "default" {
  allocated_storage = 20
  storage_type      = "gp2"
  engine            = "postgres"
  engine_version    = "9.6.3"
  instance_class    = "db.t2.micro"
  name              = "databasesoso"
  username          = "test"
  password          = "mangermanger"

  #parameter_group_name = "default.postgres9.6.3"
  skip_final_snapshot = true

  db_subnet_group_name   = "${aws_db_subnet_group.default.id}"
  vpc_security_group_ids = ["${aws_security_group.ingress-all-test.id}"]
  availability_zone      = "eu-west-1a"
}

//servers.tf
resource "aws_instance" "test-ec2-instance" {
  ami             = "[ID_AMI]"
  instance_type   = "t2.micro"
  key_name        = "sosoKeyStp"
  security_groups = ["${aws_security_group.ingress-all-test.id}"]

  tags = {
    Name = "key"
  }

  subnet_id = "${aws_subnet.sub.id}"
}

resource "aws_eip" "ip-test-env" {
  instance = "${aws_instance.test-ec2-instance.id}"
  vpc      = true
}

//gateways.tf
resource "aws_internet_gateway" "test-env-gw" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name = "test-env-gw"
  }
}

//subnets.tf
resource "aws_route_table" "route-table-test-env" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.test-env-gw.id}"
  }

  tags = {
    Name = "test-env-route-table"
  }
}

resource "aws_route_table_association" "subnet-association" {
  subnet_id      = "${aws_subnet.sub.id}"
  route_table_id = "${aws_route_table.route-table-test-env.id}"
}
