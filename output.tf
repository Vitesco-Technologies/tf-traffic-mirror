# Copyright 2023 Uli Heilmeier, Vitesco Technologies
#
# SPDX-License-Identifier: Apache-2.0

output ec2_instance_id {
  value =  aws_instance.tm-ec2-target.id
}

output s3_bucket {
  value =  aws_s3_bucket.traffic_mirror_s3.id
}
