output "db_endpoint" {
  description = "Database endpoint."
  value       = var.use_aurora ? aws_rds_cluster.this[0].endpoint : aws_db_instance.this[0].address
}

output "db_reader_endpoint" {
  description = "Aurora reader endpoint. Null for standard RDS."
  value       = var.use_aurora ? aws_rds_cluster.this[0].reader_endpoint : null
}

output "db_port" {
  description = "Database port."
  value       = local.db_port
}

output "db_name" {
  description = "Database name."
  value       = var.db_name
}

output "db_security_group_id" {
  description = "Security group ID used by the database."
  value       = aws_security_group.this.id
}

output "db_subnet_group_name" {
  description = "DB subnet group name."
  value       = aws_db_subnet_group.this.name
}

output "db_identifier" {
  description = "Database identifier."
  value       = var.use_aurora ? aws_rds_cluster.this[0].cluster_identifier : aws_db_instance.this[0].identifier
}