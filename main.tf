provider "aws" {
  region = "us-east-1"
  }
resource "aws_security_group" "rds_sg" {
  name = "rds_sg"
  # Define ingress and egress rules for RDS
  
 # ssh for terraform remote exec
  ingress {
    description = "Allow remote SSH from anywhere"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  # enable http
  ingress {
    description = "Allow HTTP request from anywhere"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  # enable http
  ingress {
    description = "Allow HTTP request from anywhere"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
  }

  
   ingress {
  description = "Allow HTTP request from anywhere"
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 8080
  to_port     = 8080
  protocol    = "tcp"
}
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "rds-security-group"
  }
}


resource "aws_db_instance" "my_rds_instance" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "8.0.35"
  instance_class       = "db.t3.micro"
  identifier           = "my-rds-instance"
  db_name              = "mydata"
  username             = "vaseem"
  password             = "vaseem12345"
  skip_final_snapshot  = true
  publicly_accessible  = true
}
  
resource "aws_instance" "name" {
  ami = "ami-04a81a99f5ec58529"
  instance_type = "t2.medium"
  key_name = "TEST1"
  vpc_security_group_ids = [ "sg-01364e06de0b9d712" ] #default security group has to be given
  tags = {
    Name = "vaseem"
  }
    provisioner "remote-exec" {
        inline = [
         "sudo apt-get update",
         "sudo apt-get upgrade -y",
         "sudo apt install python3-pip -y",
         "sudo apt install python3-venv -y",
         "sudo apt install python3-virtualenv -y",
         "python3 -m venv /home/ubuntu/venv",
         ". /home/ubuntu/venv/bin/activate",
         "git clone https://github.com/vaseem2914/mymart08-07.git",
         "cd mymart08-07",
         "sudo apt install openjdk-17-jdk -y",
         "sudo apt install maven -y",
         "sudo apt install spring -y",
         "sudo apt install gradle -y",
         "mvn clean package -DskipTests",
         "java -jar target/MyMart-0.0.1-SNAPSHOT.jar" 

        ] 
        on_failure = continue   

        connection {
         type     = "ssh"
         user     = "ubuntu"  
         private_key = file("TEST1.pem")  
         host     = self.public_ip  
        }
    }
}
