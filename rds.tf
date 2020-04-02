resource "aws_db_subnet_group" "rds" {
  name = "ext_tableau_rds_group"

  subnet_ids = [
    "${aws_subnet.subnet.id}",
    "${aws_subnet.ext_tableau_az2.id}",
  ]

  tags {
    Name = "rds-subnet-group-${local.naming_suffix}"
  }
}

resource "aws_subnet" "ext_tableau_az2" {
  vpc_id                  = "${var.apps_vpc_id}"
  cidr_block              = "${var.dq_external_dashboard_subnet_az2}"
  map_public_ip_on_launch = false
  availability_zone       = "${var.az2}"

  tags {
    Name = "az2-subnet-${local.naming_suffix}"
  }
}

resource "aws_route_table_association" "ext_tableau_rt_rds" {
  subnet_id      = "${aws_subnet.ext_tableau_az2.id}"
  route_table_id = "${var.route_table_id}"
}

resource "random_string" "password" {
  length  = 16
  special = false
}

resource "random_string" "username" {
  length  = 8
  special = false
  number  = false
}

resource "aws_security_group" "ext_tableau_db" {
  vpc_id = "${var.apps_vpc_id}"

  tags {
    Name = "sg-db-${local.naming_suffix}"
  }
}

resource "aws_security_group_rule" "allow_bastion" {
  type        = "ingress"
  description = "Postgres from the Bastion host"
  from_port   = "${var.rds_from_port}"
  to_port     = "${var.rds_to_port}"
  protocol    = "${var.rds_protocol}"

  cidr_blocks = [
    "${var.dq_ops_ingress_cidr}",
    "${var.peering_cidr_block}",
  ]

  security_group_id = "${aws_security_group.ext_tableau_db.id}"
}

resource "aws_security_group_rule" "allow_tab_ext" {
  type        = "ingress"
  description = "Postgres from the Tab Ext host"
  from_port   = "${var.rds_from_port}"
  to_port     = "${var.rds_to_port}"
  protocol    = "${var.rds_protocol}"

  cidr_blocks = [
    "${var.dq_external_dashboard_subnet}",
  ]

  security_group_id = "${aws_security_group.ext_tableau_db.id}"
}

resource "aws_security_group_rule" "allow_db_lambda" {
  type        = "ingress"
  description = "Postgres from the Lambda subnet"
  from_port   = "${var.rds_from_port}"
  to_port     = "${var.rds_to_port}"
  protocol    = "${var.rds_protocol}"

  cidr_blocks = [
    "${var.dq_lambda_subnet_cidr}",
    "${var.dq_lambda_subnet_cidr_az2}",
  ]

  security_group_id = "${aws_security_group.ext_tableau_db.id}"
}

resource "aws_security_group_rule" "allow_db_out" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = -1
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.ext_tableau_db.id}"
}

resource "aws_db_instance" "postgres" {
  identifier                            = "ext-tableau-postgres-${local.naming_suffix}"
  allocated_storage                     = "${var.environment == "prod" ? "500" : "210"}"
  storage_type                          = "gp2"
  engine                                = "postgres"
  engine_version                        = "${var.environment == "prod" ? "10.10" : "10.10"}"
  instance_class                        = "${var.environment == "prod" ? "db.m5.2xlarge" : "db.t3.small"}"
  enabled_cloudwatch_logs_exports       = ["postgresql", "upgrade"]
  username                              = "${random_string.username.result}"
  password                              = "${random_string.password.result}"
  name                                  = "${var.database_name}"
  port                                  = "${var.port}"
  backup_window                         = "${var.environment == "prod" ? "00:00-01:00" : "07:00-08:00"}"
  maintenance_window                    = "${var.environment == "prod" ? "tue:01:00-tue:02:00" : "thu:14:00-thu:15:00"}"
  backup_retention_period               = 14
  deletion_protection                   = true
  storage_encrypted                     = true
  multi_az                              = false
  skip_final_snapshot                   = true
  ca_cert_identifier                    = "${var.environment == "prod" ? "rds-ca-2019" : "rds-ca-2019"}"
  apply_immediately                     = "${var.environment == "prod" ? "false" : "true"}"
  performance_insights_enabled          = true
  performance_insights_retention_period = "7"
  monitoring_interval                   = "60"
  monitoring_role_arn                   = "${var.rds_enhanced_monitoring_role}"
  db_subnet_group_name                  = "${aws_db_subnet_group.rds.id}"
  vpc_security_group_ids                = ["${aws_security_group.ext_tableau_db.id}"]

  lifecycle {
    prevent_destroy = true
  }

  tags {
    Name = "postgres-${local.naming_suffix}"
  }
}

module "rds_alarms" {
  source = "github.com/UKHomeOffice/dq-tf-cloudwatch-rds"

  naming_suffix                = "${local.naming_suffix}"
  environment                  = "${var.naming_suffix}"
  pipeline_name                = "external-tableau"
  db_instance_id               = "${aws_db_instance.postgres.id}"
  free_storage_space_threshold = 100000000000                     # 100GB free space
  read_latency_threshold       = 0.05                             # 50 milliseconds
  write_latency_threshold      = 2.5                              # 2.5 seconds
}

resource "aws_ssm_parameter" "rds_external_tableau_postgres_endpoint" {
  name  = "rds_external_tableau_postgres_endpoint"
  type  = "SecureString"
  value = "${aws_db_instance.postgres.endpoint}"
}

resource "aws_ssm_parameter" "rds_external_tableau_username" {
  name  = "rds_external_tableau_username"
  type  = "SecureString"
  value = "${random_string.username.result}"
}

resource "aws_ssm_parameter" "rds_external_tableau_password" {
  name  = "rds_external_tableau_password"
  type  = "SecureString"
  value = "${random_string.password.result}"
}

resource "random_string" "service_username" {
  length  = 8
  special = false
  number  = false
}

resource "random_string" "service_password" {
  length  = 16
  special = false
}

resource "aws_ssm_parameter" "rds_external_tableau_service_username" {
  name  = "rds_external_tableau_service_username"
  type  = "SecureString"
  value = "${random_string.service_username.result}"
}

resource "aws_ssm_parameter" "rds_external_tableau_service_password" {
  name  = "rds_external_tableau_service_password"
  type  = "SecureString"
  value = "${random_string.service_password.result}"
}
