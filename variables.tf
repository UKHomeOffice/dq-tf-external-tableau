variable "naming_suffix" {
  default     = false
  description = "Naming suffix for tags, value passed from dq-tf-apps"
}

variable "database_name" {
  default     = "external_tableau"
  description = "RDS Postgres database name"
}

variable "port" {
  default     = "5432"
  description = "RDS Postgres port access"
}

variable "environment" {
  default     = "notprod"
  description = "Switch between environments"
}

variable "az" {
  default     = "eu-west-2a"
  description = "Default availability zone for the subnet."
}

variable "az2" {
  default     = "eu-west-2b"
  description = "Default availability zone for the subnet."
}

variable "http_from_port" {
  default     = 80
  description = "From port for HTTPS traffic"
}

variable "http_to_port" {
  default     = 80
  description = "To port for HTTPS traffic"
}

variable "http_protocol" {
  default     = "tcp"
  description = "Protocol for HTTPS traffic"
}

variable "SSH_from_port" {
  default     = 22
  description = "From port for SSH traffic"
}

variable "SSH_to_port" {
  default     = 22
  description = "To port for SSH traffic"
}

variable "SSH_protocol" {
  default     = "tcp"
  description = "Protocol for SSH traffic"
}

variable "TSM_from_port" {
  default     = 8850
  description = "From port for TSM traffic"
}

variable "TSM_to_port" {
  default     = 8850
  description = "To port for TSM traffic"
}

variable "RDP_from_port" {
  default     = 3389
  description = "From port for RDP traffic"
}

variable "rds_from_port" {
  default     = 5432
  description = "From port for Postgres traffic"
}

variable "rds_to_port" {
  default     = 5432
  description = "To port for Postgres traffic"
}

variable "rds_protocol" {
  default     = "tcp"
  description = "Protocol for Postgres traffic"
}

variable "dq_lambda_subnet_cidr" {
  default     = "10.1.42.0/24"
  description = "Dedicated subnet for Lambda ENIs"
}

variable "dq_lambda_subnet_cidr_az2" {
  default     = "10.1.43.0/24"
  description = "Dedicated subnet for Lambda ENIs"
}

variable "RDP_to_port" {
  default     = 3389
  description = "To port for RDP traffic"
}

variable "RDP_protocol" {
  default     = "tcp"
  description = "Protocol for RDP traffic"
}

variable "acp_prod_ingress_cidr" {
  default     = "10.5.0.0/16"
  description = "ACP Prod CIDR as per IP Addresses and CIDR blocks document"
}

variable "peering_cidr_block" {
  default     = "10.3.0.0/16"
  description = "DQ Peering CIDR as per IP Addresses and CIDR blocks document"
}

variable "dq_ops_ingress_cidr" {
  default     = "10.2.0.0/16"
  description = "DQ Ops CIDR as per IP Addresses and CIDR blocks document"
}

variable "dq_external_dashboard_subnet" {
  default     = "10.1.14.0/24"
  description = "DQ Apps CIDR as per IP Addresses and CIDR blocks document"
}

variable "dq_external_dashboard_subnet_az2" {
  default     = "10.1.15.0/24"
  description = "DQ Apps CIDR as per IP Addresses and CIDR blocks document"
}

variable "dq_external_dashboard_instance_ip" {
  description = "IP addresses of EC2 instances in Prod"
  type        = "list"

  default = [
    "10.1.14.111",
    "10.1.14.112",
    "10.1.14.113",
    "10.1.14.114",
  ]
}

variable "dq_external_staging_dashboard_instance_ip" {
  description = "IP addresses of EC2 instances in Prod"
  default     = "10.1.14.115"
}


variable "apps_vpc_id" {
  default     = false
  description = "Value obtained from Apps module"
}

variable "route_table_id" {
  default     = false
  description = "Value obtained from Apps module"
}

variable "key_name" {
  default = "test_instance"
}

variable "s3_archive_bucket" {
  description = "S3 archive bucket name"
}

variable "s3_archive_bucket_key" {
  description = "S3 archive bucket KMS key"
}

variable "s3_archive_bucket_name" {
  description = "Name of archive bucket"
}

variable "haproxy_private_ip2" {
  description = "IP of HaProxy 2"
}

variable "haproxy_config_bucket" {
  description = "HAPROXY config bucket ID"
}

variable "haproxy_config_bucket_key" {
  description = "HAPROXY config bucket KMS key"
}

variable "rds_enhanced_monitoring_role" {
  description = "ARN of the RDS enhanced monitoring role"
}
