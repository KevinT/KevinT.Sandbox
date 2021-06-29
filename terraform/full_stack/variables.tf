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

variable "subnet_prefix_frontend" {
  description = "cidr block for the frontend subnet"
  type = string
  default = "10.0.2.0/24"
}

variable "subnet_prefix_backend" {
  description = "cidr block for the backend subnet"
  type = string
  default = "10.0.2.0/24"
}