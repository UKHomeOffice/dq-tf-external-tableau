data "aws_ami" "ext_tableau_linux" {
  most_recent = true

  filter {
    name = "name"

    values = [
      "dq-tableau-linux-205*",
    ]
  }


  owners = [
    "self",
  ]
}

data "aws_ami" "ext_tableau_linux_upgrade" {
  most_recent = true

  filter {
    name = "name"

    values = [
      "dq-tableau-linux-206*",
    ]
  }

  owners = [
    "self",
  ]
}
