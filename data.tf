data "aws_region" "current" {
  current = true
}

data "aws_ami" "ext_tableau" {
  most_recent = true

  filter {
    name = "name"

    values = [
      "dq-tableau-7",
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
      "dq-tableau-7",
    ]
  }

  owners = [
    "self",
  ]
}
