module "instance" {
  source          = "github.com/UKHomeOffice/connectivity-tester-tf"
  user_data       = "CHECK_self=127.0.0.1:80 CHECK_google=google.com:80 CHECK_googletls=google.com:443 LISTEN_http=0.0.0.0:80"
  subnet_id       = "${aws_subnet.subnet.id}"
  security_groups = ["${aws_security_group.sgrp.id}"]

  tags = {
    Name             = "instance-${var.service}-${var.environment}"
    Service          = "${var.service}"
    Environment      = "${var.environment}"
    EnvironmentGroup = "${var.environment_group}"
  }
}

resource "aws_subnet" "subnet" {
  vpc_id     = "${var.apps_vpc_id}"
  cidr_block = "${var.dq_external_dashboard_subnet}"

  tags {
    Name             = "sn-tableau-external-${var.service}-${var.environment}-{az}"
    Service          = "${var.service}"
    Environment      = "${var.environment}"
    EnvironmentGroup = "${var.environment_group}"
  }
}

resource "aws_security_group" "sgrp" {
  vpc_id = "${var.apps_vpc_id}"

  ingress {
    from_port = "${var.https_from_port}"
    to_port   = "${var.https_to_port}"
    protocol  = "${var.https_protocol}"

    cidr_blocks = ["${var.dq_ops_ingress_cidr}",
      "${var.acp_prod_ingress_cidr}",
    ]
  }

  ingress {
    from_port   = "${var.RDP_from_port}"
    to_port     = "${var.RDP_to_port}"
    protocol    = "${var.RDP_protocol}"
    cidr_blocks = ["${var.dq_ops_ingress_cidr}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name             = "sg-external-tableau-${var.service}-${var.environment}"
    Service          = "${var.service}"
    Environment      = "${var.environment}"
    EnvironmentGroup = "${var.environment_group}"
  }
}
