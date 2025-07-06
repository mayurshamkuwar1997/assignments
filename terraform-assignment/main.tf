resource "aws_vpc" "myvpc" {

        cidr_block = "10.10.0.0/16"
        tags = {
          Name = "vpc1"
          }
                }
resource "aws_internet_gateway" "igw" {
           vpc_id = "${aws_vpc.myvpc.id}"
           tags = {
             Name = "my_igw1"
                }
        }

resource "aws_subnet" "sub1" {
                vpc_id = "${aws_vpc.myvpc.id}"
                cidr_block = "10.10.1.0/24"
                availability_zone = "ap-south-1a"
                tags = {
                     Name = "pub_sub1"
                        }

                }

resource "aws_subnet" "sub2" {
                vpc_id = "${aws_vpc.myvpc.id}"
                cidr_block = "10.10.2.0/24"
                availability_zone = "ap-south-1b"
                tags = {
                     Name = "pub_sub2"
                        }

                }

resource "aws_subnet" "sub3" {
                vpc_id = "${aws_vpc.myvpc.id}"
                cidr_block = "10.10.3.0/24"
                availability_zone = "ap-south-1c"
                tags = {
                     Name = "pub_sub3"
                        }
                }

resource "aws_route_table" "rt1" {
            vpc_id = "${aws_vpc.myvpc.id}"
            route {
                 cidr_block = "0.0.0.0/0"
                 gateway_id = "${aws_internet_gateway.igw.id}"
                  }
                    tags = {
                    Name = "pub_route"
                        }
                }

resource "aws_route_table_association" "sub_one" {
                   subnet_id = "${aws_subnet.sub1.id}"
                   route_table_id = "${aws_route_table.rt1.id}"
                }

resource "aws_route_table_association" "sub_two" {
                   subnet_id = "${aws_subnet.sub2.id}"
                   route_table_id = "${aws_route_table.rt1.id}"
                }

resource "aws_route_table_association" "sub_three" {
                   subnet_id = "${aws_subnet.sub3.id}"
                   route_table_id = "${aws_route_table.rt1.id}"
                }
resource "aws_security_group" "sg_1" {
                   name = "sg_1"
                   description = "sg_1"
                   vpc_id = "${aws_vpc.myvpc.id}"

                   ingress {
                         from_port   = 22
                         to_port     = 22
                         protocol    = "tcp"
                         cidr_blocks = ["0.0.0.0/0"]
                }

                  ingress {
                          from_port   = 80
                          to_port     = 80
                          protocol    = "tcp"
                          cidr_blocks = ["0.0.0.0/0"]
                        }

                  egress {
                         from_port   = 0
                         to_port     = 0
                         protocol    = "-1"
                         cidr_blocks  = ["0.0.0.0/0"]
                        }
        }

resource "aws_instance" "webserver" {
               ami = "ami-018046b953a698135"
               instance_type = "t2.micro"
               key_name = "mum.key"
               subnet_id = "${aws_subnet.sub1.id}"
               vpc_security_group_ids = [aws_security_group.sg_1.id]
               associate_public_ip_address = true


               provisioner "remote-exec" {
                inline = [
                 "sudo yum install httpd -y",
                 "sudo service httpd start",
                 "sudo chkconfig httpd on",
                 "sudo chmod -R 777 /var/www/html"
                   ]

                connection {
               type = "ssh"
               user = "ec2-user"
               private_key = file("/mnt/mykey.pem")
               host = self.public_ip
                }

        }
              provisioner "file" {
                 source      = "/mnt/terraform/index.html"
                 destination = "/var/www/html/index.html"

              connection {
              type        = "ssh"
              user        = "ec2-user"
              private_key = file("/mnt/mykey.pem")
              host        = self.public_ip
  }
}
              tags = {
                Name = "test_server"
                    }

}
