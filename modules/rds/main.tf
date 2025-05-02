resource "aws_db_instance" "this" {
  identifier             = "${var.project_name}-mariadb"
  engine                 = "mariadb"
  engine_version         = "10.5"
  instance_class         = "db.t3.medium"
  allocated_storage      = 20
  storage_type           = "gp2"
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  multi_az               = true # Multi-AZ enabled for high availability
  vpc_security_group_ids = [var.security_group_id]
  db_subnet_group_name   = aws_db_subnet_group.mariadb.name # Reference to the subnet group
  publicly_accessible    = false                            # RDS should not be publicly accessible

  tags = {
    Name = "${var.project_name}-mariadb"
  }

  skip_final_snapshot       = true
  final_snapshot_identifier = null
  backup_retention_period   = 0
}

resource "aws_db_subnet_group" "mariadb" {
  name       = "${var.project_name}-mariadb-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.project_name}-mariadb-subnet-group"
  }
}