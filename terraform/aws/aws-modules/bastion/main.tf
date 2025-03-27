# Create a security group for the bastion host
resource "aws_security_group" "bastion_sg" {
  name        = "${var.cluster_name}-bastion-sg"
  description = "Security group for bastion host"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["49.207.233.146/32"] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-bastion-sg"
    }
  )
}

# Create a key pair for SSH access
data "aws_key_pair" "bastion_key" {
  key_name = "zamp-bastion-key"
}


# Create IAM role for SSM access
resource "aws_iam_role" "bastion_ssm_role" {
  name = "${var.cluster_name}-bastion-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach AmazonSSMManagedInstanceCore policy to the role
resource "aws_iam_role_policy_attachment" "bastion_ssm_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.bastion_ssm_role.name
}

# Create an instance profile
resource "aws_iam_instance_profile" "bastion_instance_profile" {
  name = "${var.cluster_name}-bastion-instance-profile"
  role = aws_iam_role.bastion_ssm_role.name
}

# Create the bastion EC2 instance
resource "aws_instance" "bastion" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t2.medium"
  key_name      = data.aws_key_pair.bastion_key.key_name
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  subnet_id     = var.public_subnet_ids[0]  # Place the bastion in a public subnet
  associate_public_ip_address = true
  iam_instance_profile = aws_iam_instance_profile.bastion_instance_profile.name


  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-bastion"
    }
  )
    lifecycle {
    ignore_changes = [ami]
  }
}


data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}