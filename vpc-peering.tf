data "terraform_remote_state" "env1" {
  backend = "s3"
  config = {
    region = "us-east-1"
    bucket = "example"
    key    = "env1/terraform.tfstate"
  }
}

data "terraform_remote_state" "env2" {
  backend = "s3"
  config = {
    region = "us-east-1"
    bucket = "example"
    key    = "env2/terraform.tfstate"
  }
}


resource "aws_vpc_peering_connection" "env1toenv2 {
  peer_vpc_id = data.terraform_remote_state.env1.outputs.vpc_id
  vpc_id  = data.terraform_remote_state.env2.outputs.vpc_id_env2
  auto_accept   = true

  tags = {
    Name = "VPC Peering between env1 and env2"
  }
}




resource "aws_route" "env1toenv2" {
  route_table_id            = data.terraform_remote_state.env1.outputs.private_route_table_id_bastion
  destination_cidr_block    = data.terraform_remote_state.env2.outputs.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.env1toenv2id
}

resource "aws_route" "env2toenv1" {
  route_table_id            = data.terraform_remote_state.env2.outputs.private_route_table_ids
  destination_cidr_block    = data.terraform_remote_state.env1.outputs.vpc_cidrblock_bastion
  vpc_peering_connection_id = aws_vpc_peering_connection.env1toenv2.id
}


