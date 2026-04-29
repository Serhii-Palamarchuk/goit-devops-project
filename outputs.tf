output "s3_bucket_name" {
  value = module.s3_backend.bucket_name
}

output "dynamodb_table_name" {
  value = module.s3_backend.dynamodb_table_name
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "ecr_repository_url" {
  value = module.ecr.repository_url
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "db_endpoint" {
  description = "Database endpoint."
  value       = module.rds.db_endpoint
}

output "db_reader_endpoint" {
  description = "Aurora reader endpoint. Null for standard RDS."
  value       = module.rds.db_reader_endpoint
}

output "db_port" {
  description = "Database port."
  value       = module.rds.db_port
}

output "db_name" {
  description = "Database name."
  value       = module.rds.db_name
}

output "db_security_group_id" {
  description = "Database security group ID."
  value       = module.rds.db_security_group_id
}

output "db_subnet_group_name" {
  description = "Database subnet group name."
  value       = module.rds.db_subnet_group_name
}

output "db_identifier" {
  description = "Database identifier."
  value       = module.rds.db_identifier
}