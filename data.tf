data "aws_region" "current" {
  current = true
}

data "aws_ami" "ext_tableau" {
  most_recent = true

  filter {
    name = "name"

    values = [
      "dq-ext-tableau-no1",
    ]
  }

  owners = [
    "self",
  ]
}

data "aws_ami" "ext_tableau_2018_vanilla" {
  most_recent = true

  filter {
    name = "name"

    values = [
      "dq-ext-tableau-86*",
    ]
  }

  owners = [
    "self",
  ]
}

data "aws_ami" "ext_tableau_s3_backup_test" {
  most_recent = true

  filter {
    name = "name"

    values = [
      "dq-ext-tableau-87*",
    ]
  }

  owners = [
    "self",
  ]
}
