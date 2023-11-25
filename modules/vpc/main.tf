 resource aws_vpc "demo_vpc"{
  cidr_block  = var.vpc-cidr


  tags = {
    Name = "${var.mani}-vpc"
  }
}



resource "aws_subnet" "public_sub" {
  vpc_id     = aws_vpc.demo_vpc.id
  cidr_block = var.sub-cidr1
  availability_zone = var.az

  tags = {
    Name = "${var.mani}-public-sub"
  }
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.demo_vpc.id

  tags = {
    Name = "${var.mani}-IGW"
  }
}


resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.demo_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

 tags = {
    Name = "${var.mani}-public-route"
  }
 }


resource "aws_route_table_association" "public_rta" {
  subnet_id      = aws_subnet.public_sub.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "msg" {
  name = "mani_sg"
  vpc_id = aws_vpc.demo_vpc.id


 tags = {
    Name = "${var.mani}-sg"
  }

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress  {
    from_port    = 80
    to_port      = 80
    protocol     ="tcp"
    cidr_blocks  = ["0.0.0.0/0"]
    }

 egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  
  }
  
}


 resource "aws_key_pair" "mkp" {
  public_key = file(var.key)
}


resource "aws_instance" "public_ec2" {
  ami           = var.ami
  instance_type = var.insta
  subnet_id = aws_subnet.public_sub.id
  key_name = aws_key_pair.mkp.id
  associate_public_ip_address = true
  security_groups =  [aws_security_group.msg.id]

      user_data = <<-EOF
#!/bin/bash
  yum -y update
  yum install nginx -y
  sudo systemctl start nginx
  sudo systemctl enable nginx
  # echo "MANIDEEP" >/usr/share/nginx/html/index.html


   # Create an index.html file with your name in big letters and custom styles
    cat <<HTML > /usr/share/nginx/html/index.html
    <!DOCTYPE html>
    <html>
    <head>
        <style>
            body {
                background-color: #fcde67; /* Change this to your desired background color */
                text-align: center;
            }

            h1 {
                font-size: 36px;
                color: #5bccf6; /* Change this to your desired text color */
                padding: 20px;
            }
            /* CSS code to change the font of specific elements */
        h1 {
            font-family: "Lucida Console", monospace;
        }

        </style>
    </head>
    <body>
        <h1>WELCOME TO MANIDEEP WEB PAGE</h1>
    </body>
    </html>
 
     EOF


tags = {
  Name = "${var.mani}-public ec2"
  } 
}

