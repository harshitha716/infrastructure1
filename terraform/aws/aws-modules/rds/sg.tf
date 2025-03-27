resource "aws_security_group" "db_sg" {
  name = var.db_sg_name
  description = "Security group for db server"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 9807
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

 
  egress {
    description = "Allow all outbound traffic"
    from_port = "0"
    to_port = "0"
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



