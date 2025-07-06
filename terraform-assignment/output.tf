output "instance_public_ip" {
       value = "${aws_instance.webserver.public_ip}"
        }

output "instance_private_ip" {
       value = "${aws_instance.webserver.private_ip}"
                }
