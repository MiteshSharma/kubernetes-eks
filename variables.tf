# Variables
variable "region" {
  default = "us-east-1"
}

variable "cidr_vpc" {
  description = "CIDR block for the VPC"
  default     = "10.1.0.0/16"
}

variable "subnets" {
  description = "AZ to CIDR mapping for each subnet"
  type        = map(any)
  default     = {
    us-east-1a = "10.1.0.0/21"
    us-east-1b = "10.1.8.0/21"
  }
}

variable "public_key_path" {
  description = "Public key path"
  default     = "~/.ssh/id_rsa.pub"
}

variable "instance_ami" {
  description = "AMI for aws EC2 instance"
  default     = "ami-0cf31d971a3ca20d6"
}

variable "instance_type" {
  description = "type for aws EC2 instance"
  default     = "t2.small"
}

variable "environment_tag" {
  description = "Environment tag"
  default     = "Production"
}

variable "cluster_name" {
  description = "Cluster Name"
  default     = "test"
}