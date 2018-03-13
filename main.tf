locals {
  naming_suffix = "external-tableau-${var.naming_suffix}"
}

resource "aws_instance" "ext_tableau" {
  key_name                    = "${var.key_name}"
  ami                         = "${data.aws_ami.ext_tableau.id}"
  instance_type               = "r4.2xlarge"
  vpc_security_group_ids      = ["${aws_security_group.sgrp.id}"]
  associate_public_ip_address = false
  subnet_id                   = "${aws_subnet.subnet.id}"
  private_ip                  = "${var.dq_external_dashboard_instance_ip}"

  lifecycle {
    prevent_destroy = true

    ignore_changes = [
      "user_data",
      "ami",
      "instance_type",
    ]
  }

  tags = {
    Name = "ec2-${local.naming_suffix}"
  }
}

resource "aws_subnet" "subnet" {
  vpc_id            = "${var.apps_vpc_id}"
  cidr_block        = "${var.dq_external_dashboard_subnet}"
  availability_zone = "${var.az}"

  tags {
    Name = "subnet-${local.naming_suffix}"
  }
}

resource "aws_route_table_association" "external_tableau_rt_association" {
  subnet_id      = "${aws_subnet.subnet.id}"
  route_table_id = "${var.route_table_id}"
}

resource "aws_security_group" "sgrp" {
  vpc_id = "${var.apps_vpc_id}"

  ingress {
    from_port = "${var.http_from_port}"
    to_port   = "${var.http_to_port}"
    protocol  = "${var.http_protocol}"

    cidr_blocks = [
      "${var.dq_ops_ingress_cidr}",
      "${var.acp_prod_ingress_cidr}",
      "${var.peering_cidr_block}",
    ]
  }

  ingress {
    from_port = "${var.RDP_from_port}"
    to_port   = "${var.RDP_to_port}"
    protocol  = "${var.RDP_protocol}"

    cidr_blocks = [
      "${var.dq_ops_ingress_cidr}",
      "${var.peering_cidr_block}",
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "sg-${local.naming_suffix}"
  }
}
