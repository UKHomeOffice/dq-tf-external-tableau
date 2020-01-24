# pylint: disable=missing-docstring, line-too-long, protected-access, E1101, C0202, E0602, W0109
import unittest
from runner import Runner


class TestE2E(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        self.snippet = """
            provider "aws" {
              region = "eu-west-2"
              profile = "foo"
              skip_credentials_validation = true
              skip_get_ec2_platforms = true
            }

            module "root_modules" {
              source = "./mymodule"
              providers = {aws = "aws"}

              apps_vpc_id                  = "1234"
              acp_prod_ingress_cidr        = "10.5.0.0/16"
              dq_ops_ingress_cidr          = "10.2.0.0/16"
              dq_external_dashboard_subnet = "10.1.14.0/24"
              peering_cidr_block           = "1.1.1.0/24"
              apps_vpc_id                  = "vpc-12345"
              naming_suffix                = "apps-preprod-dq"
              s3_archive_bucket            = "bucket-name"
              s3_archive_bucket_key        = "1234567890"
              s3_archive_bucket_name       = "bucket-name"
              haproxy_private_ip2          = "1.2.3.3"
              haproxy_config_bucket        = "s3-bucket-name"
              haproxy_config_bucket_key    = "arn:aws:kms:us-west-2:111122223333:key/1234abcd-12ab-34cd-56ef-1234567890ab"
              rds_enhanced_monitoring_role = "arn:aws:iam::123456789:role/rds-enhanced-monitoring-role"
              environment                  = "prod"
            }

        """
        self.result = Runner(self.snippet).result

    def test_subnet_vpc(self):
        self.assertEqual(self.result["root_modules"]["aws_subnet.subnet"]["vpc_id"], "vpc-12345")

    def test_subnet_cidr(self):
        self.assertEqual(self.result["root_modules"]["aws_subnet.subnet"]["cidr_block"], "10.1.14.0/24")

    def test_subnet_tags(self):
        self.assertEqual(self.result["root_modules"]["aws_subnet.subnet"]["tags.Name"], "subnet-external-tableau-apps-preprod-dq")

    def test_security_group_tags(self):
        self.assertEqual(self.result["root_modules"]["aws_security_group.sgrp"]["tags.Name"], "sg-external-tableau-apps-preprod-dq")

    def test_ssm_service_username(self):
        self.assertEqual(self.result["root_modules"]["aws_ssm_parameter.rds_external_tableau_service_username"]["name"], "rds_external_tableau_service_username")

    def test_ssm_service_username_type(self):
        self.assertEqual(self.result["root_modules"]["aws_ssm_parameter.rds_external_tableau_service_username"]["type"], "SecureString")

    def test_ssm_service_password(self):
        self.assertEqual(self.result["root_modules"]["aws_ssm_parameter.rds_external_tableau_service_password"]["name"], "rds_external_tableau_service_password")

    def test_ssm_service_password_type(self):
        self.assertEqual(self.result["root_modules"]["aws_ssm_parameter.rds_external_tableau_service_password"]["type"], "SecureString")

    def test_rds_deletion_protection(self):
        self.assertEqual(self.result["root_modules"]["aws_db_instance.postgres"]["deletion_protection"], "true")

    def test_rds_stg_identifier(self):
        self.assertEqual(self.result["root_modules"]["aws_db_instance.external_reporting_snapshot_stg"]["identifier"], "stg-postgres-external-tableau-apps-preprod-dq")

    def test_ssm_service_username(self):
        self.assertEqual(self.result["root_modules"]["aws_ssm_parameter.rds_external_tableau_postgres_staging_endpoint"]["name"], "rds_external_tableau_postgres_staging_endpoint")

    def test_rds_postgres_allocated_storage(self):
        self.assertEqual(self.result["root_modules"]["aws_db_instance.postgres"]["allocated_storage"], "500")

    def test_rds_postgres_instance_class(self):
        self.assertEqual(self.result["root_modules"]["aws_db_instance.postgres"]["instance_class"], "db.m5.2xlarge")

    def test_rds_postgres_backup_window(self):
        self.assertEqual(self.result["root_modules"]["aws_db_instance.postgres"]["backup_window"], "00:00-01:00")

    def test_rds_postgres_maintenance_window(self):
        self.assertEqual(self.result["root_modules"]["aws_db_instance.postgres"]["maintenance_window"], "mon:01:00-mon:02:00")

    def test_rds_postgres_ca_cert_identifier(self):
        self.assertEqual(self.result["root_modules"]["aws_db_instance.postgres"]["ca_cert_identifier"], "rds-ca-2019")

    def test_rds_postgres_identifier(self):
        self.assertEqual(self.result["root_modules"]["aws_db_instance.postgres"]["identifier"], "ext-tableau-postgres-external-tableau-apps-preprod-dq")

    def test_rds_postgres_tag(self):
        self.assertEqual(self.result["root_modules"]["aws_db_instance.postgres"]["tags.Name"], "postgres-external-tableau-apps-preprod-dq")

    def test_rds_postgres_engine_version(self):
        self.assertEqual(self.result["root_modules"]["aws_db_instance.postgres"]["engine_version"], "10.6")

    def test_rds_postgres_apply_immediately(self):
        self.assertEqual(self.result["root_modules"]["aws_db_instance.postgres"]["apply_immediately"], "false")

    def test_rds_postgres_stg_snapshot_identifier(self):
        self.assertEqual(self.result["root_modules"]["aws_db_instance.external_reporting_snapshot_stg"]["snapshot_identifier"], "rds:postgres-internal-tableau-apps-prod-dq-2020-01-21-00-07")

    def test_rds_postgres_stg_allocated_storage(self):
        self.assertEqual(self.result["root_modules"]["aws_db_instance.external_reporting_snapshot_stg"]["allocated_storage"], "3300")

    def test_rds_postgres_stg_instance_class(self):
        self.assertEqual(self.result["root_modules"]["aws_db_instance.external_reporting_snapshot_stg"]["instance_class"], "db.m5.4xlarge")

    def test_rds_postgres_stg_backup_window(self):
        self.assertEqual(self.result["root_modules"]["aws_db_instance.external_reporting_snapshot_stg"]["backup_window"], "00:00-01:00")

    def test_rds_postgres_stg_maintenance_window(self):
        self.assertEqual(self.result["root_modules"]["aws_db_instance.external_reporting_snapshot_stg"]["maintenance_window"], "thu:15:30-thu:16:00")

    def test_rds_postgres_stg_ca_cert_identifier(self):
        self.assertEqual(self.result["root_modules"]["aws_db_instance.external_reporting_snapshot_stg"]["ca_cert_identifier"], "rds-ca-2019")

    def test_rds_postgres_stg_identifier(self):
        self.assertEqual(self.result["root_modules"]["aws_db_instance.external_reporting_snapshot_stg"]["identifier"], "stg-postgres-external-tableau-apps-preprod-dq")

    def test_rds_postgres_stg_tag(self):
        self.assertEqual(self.result["root_modules"]["aws_db_instance.external_reporting_snapshot_stg"]["tags.Name"], "stg-external-tableau-apps-preprod-dq")


if __name__ == '__main__':
    unittest.main()
