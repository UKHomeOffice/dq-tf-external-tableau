resource "aws_iam_role" "ext_tableau" {
  name               = var.application_name
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
                    "ec2.amazonaws.com",
                    "s3.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

resource "aws_iam_policy" "ext_tableau" {
  name = "${var.application_name}-ssm-parameter"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameter"
      ],
      "Resource": [
        "arn:aws:ssm:eu-west-2:*:parameter/addomainjoin",
        "arn:aws:ssm:eu-west-2:*:parameter/ext_tableau_hostname",
        "arn:aws:ssm:eu-west-2:*:parameter/tableau_server_username",
        "arn:aws:ssm:eu-west-2:*:parameter/tableau_server_password",
        "arn:aws:ssm:eu-west-2:*:parameter/tableau_ext_s3_prefix",
        "arn:aws:ssm:eu-west-2:*:parameter/data_archive_tab_ext_backup_url",
        "arn:aws:ssm:eu-west-2:*:parameter/data_archive_tab_ext_staging_backup_url",
        "arn:aws:ssm:eu-west-2:*:parameter/tab_ext_repo_protocol",
        "arn:aws:ssm:eu-west-2:*:parameter/tab_ext_repo_user",
        "arn:aws:ssm:eu-west-2:*:parameter/tab_ext_repo_host",
        "arn:aws:ssm:eu-west-2:*:parameter/tab_ext_repo_port",
        "arn:aws:ssm:eu-west-2:*:parameter/tab_ext_repo_org",
        "arn:aws:ssm:eu-west-2:*:parameter/tab_ext_repo_name",
        "arn:aws:ssm:eu-west-2:*:parameter/tableau_admin_username",
        "arn:aws:ssm:eu-west-2:*:parameter/tableau_admin_password",
        "arn:aws:ssm:eu-west-2:*:parameter/tableau_linux_ssh_private_key",
        "arn:aws:ssm:eu-west-2:*:parameter/tableau_linux_ssh_public_key",
        "arn:aws:ssm:eu-west-2:*:parameter/tableau_ext_openid_provider_client_id",
        "arn:aws:ssm:eu-west-2:*:parameter/tableau_ext_staging_openid_provider_client_id",
        "arn:aws:ssm:eu-west-2:*:parameter/tableau_ext_openid_client_secret",
        "arn:aws:ssm:eu-west-2:*:parameter/tableau_ext_staging_openid_client_secret",
        "arn:aws:ssm:eu-west-2:*:parameter/tableau_ext_openid_provider_config_url",
        "arn:aws:ssm:eu-west-2:*:parameter/tableau_ext_staging_openid_provider_config_url",
        "arn:aws:ssm:eu-west-2:*:parameter/tableau_ext_openid_tableau_server_external_url",
        "arn:aws:ssm:eu-west-2:*:parameter/tableau_ext_staging_openid_tableau_server_external_url",
        "arn:aws:ssm:eu-west-2:*:parameter/tableau_ext_product_key",
        "arn:aws:ssm:eu-west-2:*:parameter/tableau_server_repository_username",
        "arn:aws:ssm:eu-west-2:*:parameter/tableau_server_repository_password",
        "arn:aws:ssm:eu-west-2:*:parameter/data_archive_tab_ext_backup_sub_directory",
        "arn:aws:ssm:eu-west-2:*:parameter/tableau_ext_publish_datasources",
        "arn:aws:ssm:eu-west-2:*:parameter/tableau_ext_publish_workbooks",
        "arn:aws:ssm:eu-west-2:*:parameter/tableau_config_smtp"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ssm:PutParameter"
      ],
      "Resource": "arn:aws:ssm:eu-west-2:*:parameter/data_archive_tab_ext_backup_sub_directory"
    },
    {
      "Effect": "Allow",
      "Action": [
          "Action": "ec2:ModifyInstanceMetadataOptions"
      ],
      "Resource": "arn:aws:ec2:*:*:instance/*"
    }
  ]
}
EOF

}

resource "aws_iam_policy" "ext_tableau_s3" {
  name = "${var.application_name}-s3"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": [
        "${var.s3_archive_bucket}",
        "arn:aws:s3:::${var.haproxy_config_bucket}",
        "${var.s3_carrier_portal_docs}"
        ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject"
      ],
      "Resource": [
        "${var.s3_archive_bucket}/*",
        "arn:aws:s3:::${var.haproxy_config_bucket}/*",
        "${var.s3_carrier_portal_docs}/*"
        ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
        ],
      "Resource": [
        "${var.s3_archive_bucket_key}",
        "${var.haproxy_config_bucket_key}"
        ]
    }
  ]
}
EOF

}

resource "aws_iam_instance_profile" "ext_tableau" {
  role = aws_iam_role.ext_tableau.name
}

resource "aws_iam_role_policy_attachment" "cloud_watch_agent" {
  role       = aws_iam_role.ext_tableau.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "ext_tableau" {
  role       = aws_iam_role.ext_tableau.id
  policy_arn = aws_iam_policy.ext_tableau.id
}

resource "aws_iam_role_policy_attachment" "ext_tableau_s3" {
  role       = aws_iam_role.ext_tableau.id
  policy_arn = aws_iam_policy.ext_tableau_s3.id
}

resource "aws_iam_role_policy_attachment" "dq_tf_infra_write_to_cw" {
  role       = aws_iam_role.ext_tableau.id
  policy_arn = "arn:aws:iam::${var.account_id[var.environment]}:policy/dq-tf-infra-write-to-cw"
}
