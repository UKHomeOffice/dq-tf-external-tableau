data "aws_ami" "ext_tableau_linux" {
  most_recent = true

  filter {
    name = "name"

    values = [
      "dq-tableau-linux-177*",
    ]
  }

  owners = [
    "self",
  ]
}
