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

              acp_prod_ingress_cidr        = "10.5.0.0/16"
              dq_ops_ingress_cidr          = "10.2.0.0/16"
              dq_external_dashboard_subnet = "10.1.14.0/24"
              peering_cidr_block           = "1.1.1.0/24"
              apps_vpc_id                  = "vpc-12345"
              naming_suffix                = "apps-preprod-dq"
              s3_archive_bucket            = "bucket-name"
              s3_archive_bucket_key        = "1234567890"
              s3_archive_bucket_name       = "bucket-name"
            }

        """
        self.result = Runner(self.snippet).result

    def test_subnet_vpc(self):
        self.assertEqual(self.result["root_modules"]["aws_subnet.subnet"]["vpc_id"], "vpc-12345")

    def test_subnet_cidr(self):
        self.assertEqual(self.result["root_modules"]["aws_subnet.subnet"]["cidr_block"], "10.1.14.0/24")

    @unittest.skip
    def test_security_group_ingress(self):
        self.assertTrue(Runner.finder(self.result["root_modules"]["aws_security_group.sgrp"], ingress, {
            'from_port': '80',
            'to_port': '80',
            'from_port': '3389',
            'to_port': '3389',
            'Protocol': 'tcp',
            'Cidr_blocks': '0.0.0.0/0'
        }))
    @unittest.skip
    def test_security_group_egress(self):
        self.assertTrue(Runner.finder(self.result["root_modules"]["aws_security_group.sgrp"], egress, {
            'from_port': '0',
            'to_port': '0',
            'Protocol': '-1',
            'Cidr_blocks': '0.0.0.0/0'
        }))

    def test_subnet_tags(self):
        self.assertEqual(self.result["root_modules"]["aws_subnet.subnet"]["tags.Name"], "subnet-external-tableau-apps-preprod-dq")

    def test_security_group_tags(self):
        self.assertEqual(self.result["root_modules"]["aws_security_group.sgrp"]["tags.Name"], "sg-external-tableau-apps-preprod-dq")

    def test_ec2_tags(self):
        self.assertEqual(self.result["root_modules"]["aws_instance.ext_tableau"]["tags.Name"], "ec2-external-tableau-apps-preprod-dq")

if __name__ == '__main__':
    unittest.main()
