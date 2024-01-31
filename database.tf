resource "aws_db_subnet_group" "rds_subnet_group" {
  name = "rds-subnet-group"

  subnet_ids = [
    aws_subnet.private_subnet_az1c.id,
    aws_subnet.private_subnet_az2c.id,
  ]
}

resource "aws_db_instance" "my_rds_instance" {
  identifier           = "postgres"
  allocated_storage    = 20
  engine               = "postgres"
  engine_version       = "15"
  instance_class       = "db.t3.micro"
  username             = "postgres"
  password             = "postgres"
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  multi_az             = true
  publicly_accessible  = false
  skip_final_snapshot  = true

  vpc_security_group_ids = [aws_security_group.rds_sg.id]
}
