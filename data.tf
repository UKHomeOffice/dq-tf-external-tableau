data "aws_ami" "ext_tableau_linux" {
  most_recent = true

  filter {
    name = "name"

    # "dq-tableau-linux-nnn" is used to pull exact image
    # "copied from*" is used to pull copy of nnn image copied to Prod/NotProd
    values = [
      var.environment == "prod" ? "dq-tableau-linux-1060*" : "dq-tableau-linux-1060*",
    ]
  }

  # "self" is used to ensure that NotProd uses image copied to NotProd account
  # and Prod uses image copied to Prod account
  owners = [
    "self"
  ]
}
