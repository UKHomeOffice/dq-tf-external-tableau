output "iam_roles" {
  value = ["${aws_iam_role.ext_tableau.id}"]
}

output "rds_address" {
  value = "${aws_db_instance.postgres.*.endpoint}"
}
