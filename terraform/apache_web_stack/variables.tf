variable "aws_region" {
  default     = "us-east-1"
  description = "Default AWS Region"
}

variable "aws_epl_access_key" {
  description = "AWS Access Key"
}

variable "aws_epl_secret_key" {
  description = "AWS Secret Key"
}

variable "subnet_prefix" {
  description = "cidr block for the subnet"
  type = string
  default = "10.0.1.0/24"
}