variable "region" {
  description = "The name of AWS region where resources will be deployed to."
}

variable "account_id" {
  description = "The AWS account where resources will be deployed to."
}

variable "iam_arn" {
  description = "The IAM role ARN for deploying the resources."
}

# Module-specific variables go beneath this line
variable "region_subnet_id" {
  type = map(string)
  description = "map of aws region and subnet_id 'eu-central-1' = 'subnet-00aabbccddeeff012'..."
}

variable "region_vpc_id" {
  type = map(string)
  description = "map of aws region and vpc_id 'eu-central-1' = 'vpc-0123456789abcdef'..."
}

variable "region_az" {
  type = map(string)
  description = "map of aws region and availability zone 'eu-central-1' = 'a'..."
}

variable "network_ranges" {
  description = "network CIDR blocks"
  default     = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  type        = list(string)
}

# Common tagging variables. Normally nothing to change down here.
variable "tf_tags" {
  type = map(string)
}

