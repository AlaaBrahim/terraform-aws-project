resource "aws_instance" "bastion" {
  ami                    = "ami-0c7217cdde317cfec"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet_az1.id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  key_name               = aws_key_pair.generated_key.key_name


  tags = {
    Name = "Bastion Host"
  }
}
output "instance_ips" {
  value       = aws_instance.bastion.public_ip
  description = "The public IP addresses of the bastion host"
}
