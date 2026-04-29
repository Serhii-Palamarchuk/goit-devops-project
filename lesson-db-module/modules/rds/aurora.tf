resource "aws_rds_cluster" "this" {
  count = var.use_aurora ? 1 : 0

  cluster_identifier = "${var.name}-aurora-cluster"

  engine         = var.engine
  engine_version = var.engine_version

  database_name   = var.db_name
  master_username = var.username
  master_password = var.password

  db_subnet_group_name            = aws_db_subnet_group.this.name
  vpc_security_group_ids          = [aws_security_group.this.id]
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.this[0].name

  storage_encrypted = true

  backup_retention_period = var.backup_retention_period
  skip_final_snapshot     = var.skip_final_snapshot
  deletion_protection     = var.deletion_protection

  apply_immediately = true

  tags = merge(var.tags, {
    Name = "${var.name}-aurora-cluster"
  })
}

resource "aws_rds_cluster_instance" "writer" {
  count = var.use_aurora ? 1 : 0

  identifier         = "${var.name}-aurora-writer"
  cluster_identifier = aws_rds_cluster.this[0].id

  engine         = aws_rds_cluster.this[0].engine
  engine_version = aws_rds_cluster.this[0].engine_version
  instance_class = var.instance_class

  db_subnet_group_name = aws_db_subnet_group.this.name
  publicly_accessible  = var.publicly_accessible

  tags = merge(var.tags, {
    Name = "${var.name}-aurora-writer"
  })
}

resource "aws_rds_cluster_instance" "reader" {
  count = var.use_aurora ? var.aurora_reader_count : 0

  identifier         = "${var.name}-aurora-reader-${count.index}"
  cluster_identifier = aws_rds_cluster.this[0].id

  engine         = aws_rds_cluster.this[0].engine
  engine_version = aws_rds_cluster.this[0].engine_version
  instance_class = var.instance_class

  db_subnet_group_name = aws_db_subnet_group.this.name
  publicly_accessible  = var.publicly_accessible

  tags = merge(var.tags, {
    Name = "${var.name}-aurora-reader-${count.index}"
  })
}
