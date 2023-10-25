# tf-traffic-mirror

## Overview

Terraform code to set up an ad-hoc VPC traffic mirror target (EC2 running Ubuntu) and share this target to the AWS organization of the deployment account.

* This code has to deployed per AWS region.
* As an EC2 instance type defines the bandwidth of an ENI, the instance type of TM target has to match the source EC2
* To connect to the TM target EC2 use SSM

This code has been demonstrated at [Sharkfest 23 EU](https://sharkfest.wireshark.org/sfeu/).
