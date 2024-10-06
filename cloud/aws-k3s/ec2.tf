# Create an EC2 instance
resource "aws_instance" "k8s_node" {
  count = var.node_count
  ami           = "ami-00060fac2f8c42d30" 
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public[count.index].id
  key_name      = "cloud_k8s_key_pair" 
  iam_instance_profile = aws_iam_instance_profile.ec2_ssm.name
  security_groups = [aws_security_group.sg_main.id]  
  associate_public_ip_address = true
  private_ip = count.index == 0 ? replace(var.cidr_blocks[count.index], "0/24", "100") : null
  user_data = templatefile("K3S_INSTALL.sh", {
    count_index = count.index
  })
  root_block_device {
    volume_size = 30  
    volume_type = "gp2" 
  }
  tags = {
    Name = "${var.project_name}-k8s-node-${random_string.node_suffix[count.index].result}"
  }

}

# Create a random string to append to the node name
resource "random_string" "node_suffix" {
  count = var.node_count
  length  = 5 
  special = false 
  upper   = false 
  numeric  = true
}


# Create a Security Group
resource "aws_security_group" "sg_main" {
  name        = "k8s_node_sg"
  description = "K8s node secuirty group"
  vpc_id      = aws_vpc.vpc_main.id 
  tags = {
    Name = "k8s_node_sg"
  }
}

# Add rule to allow SSH access (port 22)
resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.sg_main.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
  tags = {
    Name = "allow_ssh_ipv4"
  }
}

# Add rule to allow kube-api access (port 6443)
resource "aws_vpc_security_group_ingress_rule" "allow_6443_ipv4" {
  security_group_id = aws_security_group.sg_main.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 6443
  ip_protocol       = "tcp"
  to_port           = 6443
  tags = {
    Name = "allow_6443_ipv4"
  }
}

# Add rule to allow etcd communication (port 2379)
resource "aws_vpc_security_group_ingress_rule" "allow_2379_ipv4" {
  security_group_id = aws_security_group.sg_main.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 2379
  ip_protocol       = "tcp"
  to_port           = 2379
  tags = {
    Name = "allow_2379_ipv4"
  }
}

# Add rule to allow etcd communication (port 2380)
resource "aws_vpc_security_group_ingress_rule" "allow_2380_ipv4" {
  security_group_id = aws_security_group.sg_main.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 2380
  ip_protocol       = "tcp"
  to_port           = 2380
  tags = {
    Name = "allow_2380_ipv4"
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.sg_main.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" 
  tags = {
    Name = "allow_all_traffic_ipv4"
  }
}
