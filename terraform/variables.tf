variable "project" {
  description = "Project name tag prefix"
  type        = string
  default     = "node-ci-cd"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.20.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.20.1.0/24"
}

variable "ssh_ingress_cidr" {
  description = "CIDR allowed to SSH (lock this to your IP if possible)"
  type        = string
  default     = "0.0.0.0/0"
}

variable "create_eip" {
  description = "Attach an Elastic IP for stable public IP"
  type        = bool
  default     = true
}
