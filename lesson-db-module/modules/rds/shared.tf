locals {
  is_postgres = contains(["postgres", "aurora-postgresql"], var.engine)
  is_mysql    = contains(["mysql", "aurora-mysql"], var.engine)

  db_port = local.is_mysql ? 3306 : 5432

  rds_parameter_family = local.is_mysql ? "mysql8.0" : "postgres16"

  aurora_parameter_family = var.engine == "aurora-mysql" ? "aurora-mysql8.0" : "aurora-postgresql16"

  postgres_parameters = {
    max_connections = "100"
    log_statement   = "all"
    work_mem        = "4096"
  }

  mysql_parameters = {
    max_connections = "100"
    slow_query_log  = "1"
  }

  selected_parameters = local.is_mysql ? local.mysql_parameters : local.postgres_parameters
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, {
    Name = "${var.name}-subnet-group"
  })
}

resource "aws_security_group" "this" {
  name        = "${var.name}-sg"
  description = "Security group for database access"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow database access"
    from_port   = local.db_port
    to_port     = local.db_port
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name}-sg"
  })
}

resource "aws_db_parameter_group" "this" {
  count = var.use_aurora ? 0 : 1

  name   = "${var.name}-db-parameter-group"
  family = local.rds_parameter_family

  dynamic "parameter" {
    for_each = local.selected_parameters

    content {
      name  = parameter.key
      value = parameter.value
    }
  }

  tags = merge(var.tags, {
    Name = "${var.name}-db-parameter-group"
  })
}

resource "aws_rds_cluster_parameter_group" "this" {
  count = var.use_aurora ? 1 : 0

  name   = "${var.name}-cluster-parameter-group"
  family = local.aurora_parameter_family

  dynamic "parameter" {
    for_each = local.selected_parameters

    content {
      name  = parameter.key
      value = parameter.value
    }
  }

  tags = merge(var.tags, {
    Name = "${var.name}-cluster-parameter-group"
  })
}