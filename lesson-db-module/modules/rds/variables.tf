variable "name" {
  description = "Name prefix for RDS resources."
  type        = string
  default     = "lesson-db"
}

variable "use_aurora" {
  description = "If true, Aurora cluster will be created. If false, standard RDS instance will be created."
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "VPC ID where database resources will be created."
  type        = string
}

variable "subnet_ids" {
  description = "List of private subnet IDs for DB subnet group."
  type        = list(string)
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to connect to the database."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "db_name" {
  description = "Database name."
  type        = string
  default     = "appdb"
}

variable "username" {
  description = "Master database username."
  type        = string
  default     = "dbadmin"
}

variable "password" {
  description = "Master database password."
  type        = string
  sensitive   = true
}

variable "engine" {
  description = "Database engine. Supported values: postgres, mysql, aurora-postgresql, aurora-mysql."
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "Database engine version."
  type        = string
  default     = "16.3"
}

variable "instance_class" {
  description = "Database instance class."
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Storage size in GB for standard RDS instance."
  type        = number
  default     = 20
}

variable "multi_az" {
  description = "Enable Multi-AZ deployment for standard RDS."
  type        = bool
  default     = false
}

variable "publicly_accessible" {
  description = "Whether the database should be publicly accessible."
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot when database is destroyed."
  type        = bool
  default     = true
}

variable "backup_retention_period" {
  description = "Backup retention period in days."
  type        = number
  default     = 1
}

variable "deletion_protection" {
  description = "Enable deletion protection for database resources."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags for created resources."
  type        = map(string)
  default = {
    Project = "lesson-db-module"
  }
}