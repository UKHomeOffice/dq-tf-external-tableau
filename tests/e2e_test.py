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

    def test_rds_cw_export(self):
        self.assertCountEqual(self.result["root_modules"]["aws_db_instance.postgres"]["enabled_cloudwatch_logs_exports"], ["postgresql", "upgrade"])

if __name__ == '__main__':
    unittest.main()
