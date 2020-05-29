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
              providers = {aws = aws}

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
              environment                  = "prod"
            }

        """
        self.runner = Runner(self.snippet)
        self.result = self.runner.result

    def test_subnet_vpc(self):
        self.assertEqual(self.runner.get_value("module.root_modules.aws_subnet.subnet", "vpc_id"), "vpc-12345")

    def test_subnet_cidr(self):
        self.assertEqual(self.runner.get_value("module.root_modules.aws_subnet.subnet", "cidr_block"), "10.1.14.0/24")

    def test_subnet_tags(self):
        self.assertEqual(self.runner.get_value("module.root_modules.aws_subnet.subnet", "tags"), {"Name": "subnet-external-tableau-apps-preprod-dq"})

    def test_security_group_tags(self):
        self.assertEqual(self.runner.get_value("module.root_modules.aws_security_group.sgrp", "tags"), {"Name": "sg-external-tableau-apps-preprod-dq"})

if __name__ == '__main__':
    unittest.main()
