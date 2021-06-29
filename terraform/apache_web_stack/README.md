# basic commands
$ terraform plan
$ terraform apply
$ terraform apply --auto-approve
$ terraform apply -var "var_name=var_value"
$ terraform apply -var-file filename.tfvars
$ terraform destroy

# checking state
$ terraform state list
$ terraform state show {resource}
$ terraform output   # re-show output
$ terraform refresh    # refresh outputs without doing an apply

# target a specific resource
$ terraform destroy -target {resource}
$ terraform apply -target {resource}

# example using an object:
subnet_prefix = [{cidr_block = "10.0.1.0/24", name = "prod_subnet"}, {cidr_block = "10.0.2.0/24", name = "dev_subnet"}]
## usage:
Name = var.subnet_prefix[0].name
