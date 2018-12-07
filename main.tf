locals {
  naming_suffix                = "external-tableau-${var.naming_suffix}"
  naming_suffix_2018_vanilla   = "ext-tableau-2018-vanilla-${var.naming_suffix}"
  naming_suffix_s3_backup_test = "external-tableau-s3-backup-test-${var.naming_suffix}"
  s3_archive_bucket_sub_path   = "tableau-ext"
}

resource "aws_instance" "ext_tableau" {
  key_name                    = "${var.key_name}"
  ami                         = "${data.aws_ami.ext_tableau.id}"
  instance_type               = "r4.2xlarge"
  iam_instance_profile        = "${aws_iam_instance_profile.ext_tableau.id}"
  vpc_security_group_ids      = ["${aws_security_group.sgrp.id}"]
  associate_public_ip_address = false
  subnet_id                   = "${aws_subnet.subnet.id}"
  private_ip                  = "${var.dq_external_dashboard_instance_ip}"
  monitoring                  = true

  user_data = <<EOF
  <powershell>
  $tsm_user = aws --region eu-west-2 ssm get-parameter --name tableau_server_username --query 'Parameter.Value' --output text --with-decryption
  [Environment]::SetEnvironmentVariable("tableau_tsm_user", $tsm_user, "Machine")
  $tsm_password = aws --region eu-west-2 ssm get-parameter --name tableau_server_password --query 'Parameter.Value' --output text --with-decryption
  [Environment]::SetEnvironmentVariable("tableau_tsm_password", $tsm_password, "Machine")
  $s3_bucket_name = ${var.s3_archive_bucket_name}
  [Environment]::SetEnvironmentVariable("bucket_name", $s3_bucket_name, "Machine")
  $password = aws --region eu-west-2 ssm get-parameter --name addomainjoin --query 'Parameter.Value' --output text --with-decryption
  $username = "DQ\domain.join"
  $credential = New-Object System.Management.Automation.PSCredential($username,$password)
  $instanceID = aws --region eu-west-2 ssm get-parameter --name ext_tableau_hostname --query 'Parameter.Value' --output text --with-decryption
  Add-Computer -DomainName DQ.HOMEOFFICE.GOV.UK -OUPath "OU=Computers,OU=dq,DC=dq,DC=homeoffice,DC=gov,DC=uk" -NewName $instanceID -Credential $credential -Force -Restart
  </powershell>
EOF

  tags = {
    Name = "ec2-${local.naming_suffix}"
  }

  lifecycle {
    prevent_destroy = true

    ignore_changes = [
      "user_data",
      "ami",
      "instance_type",
    ]
  }
}

resource "aws_instance" "ext_tableau_2018_vanilla" {
  key_name                    = "${var.key_name}"
  ami                         = "${data.aws_ami.ext_tableau_2018_vanilla.id}"
  instance_type               = "r4.2xlarge"
  iam_instance_profile        = "${aws_iam_instance_profile.ext_tableau.id}"
  vpc_security_group_ids      = ["${aws_security_group.sgrp.id}"]
  associate_public_ip_address = false
  subnet_id                   = "${aws_subnet.subnet.id}"
  private_ip                  = "${var.dq_external_dashboard_instance_2018_vanilla_ip}"
  monitoring                  = true

  user_data = <<EOF
  <powershell>
  $tsm_user = aws --region eu-west-2 ssm get-parameter --name tableau_server_username --query 'Parameter.Value' --output text --with-decryption
  [Environment]::SetEnvironmentVariable("tableau_tsm_user", $tsm_user, "Machine")
  $tsm_password = aws --region eu-west-2 ssm get-parameter --name tableau_server_password --query 'Parameter.Value' --output text --with-decryption
  [Environment]::SetEnvironmentVariable("tableau_tsm_password", $tsm_password, "Machine")
  $s3_bucket_name = ${var.s3_archive_bucket_name}
  [Environment]::SetEnvironmentVariable("bucket_name", $s3_bucket_name, "Machine")
  $password = aws --region eu-west-2 ssm get-parameter --name addomainjoin --query 'Parameter.Value' --output text --with-decryption
  $username = "DQ\domain.join"
  $credential = New-Object System.Management.Automation.PSCredential($username,$password)
  $instanceID = aws --region eu-west-2 ssm get-parameter --name ext_tableau_hostname --query 'Parameter.Value' --output text --with-decryption
  Add-Computer -DomainName DQ.HOMEOFFICE.GOV.UK -OUPath "OU=Computers,OU=dq,DC=dq,DC=homeoffice,DC=gov,DC=uk" -NewName $instanceID -Credential $credential -Force -Restart
  </powershell>
EOF

  tags = {
    Name = "ec2-${local.naming_suffix_2018_vanilla}"
  }

  lifecycle {
    prevent_destroy = true

    ignore_changes = [
      "user_data",
      "ami",
      "instance_type",
    ]
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
