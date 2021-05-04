output "iam_roles" {
  value = [aws_iam_role.ext_tableau.id]
}

output "ext_tableau_instance_id" {
  value = [aws_instance.ext_tableau_linux[0].id]
}
