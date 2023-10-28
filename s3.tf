# Copyright 2023 Uli Heilmeier, Vitesco Technologies
#
# SPDX-License-Identifier: Apache-2.0

resource "aws_s3_bucket" "traffic_mirror_s3" {

  bucket = "tm-traffic-mirror-s3-${var.region}-${random_string.random.result}"
  tags = merge(var.tf_tags, {Name = "traffic-mirror-3"})
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "traffic_mirror_s3" {

  bucket = aws_s3_bucket.traffic_mirror_s3.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "traffic_mirror_s3" {

  bucket = aws_s3_bucket.traffic_mirror_s3.id

  policy = <<POLICY
{
  "Id": "BucketPolicy",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowSSLRequestsOnly",
      "Action": "s3:*",
      "Effect": "Deny",
      "Resource": [
        "${aws_s3_bucket.traffic_mirror_s3.arn}",
        "${aws_s3_bucket.traffic_mirror_s3.arn}/*"
      ],
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      },
      "Principal": "*"
    }
  ]
}
POLICY
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_enc" {
  bucket = aws_s3_bucket.traffic_mirror_s3.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}
