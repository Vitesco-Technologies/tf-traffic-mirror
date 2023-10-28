# Copyright 2023 Uli Heilmeier, Vitesco Technologies
#
# SPDX-License-Identifier: Apache-2.0

data "template_cloudinit_config" "master" {
  gzip          = true
  base64_encode = true

  # get common user_data and disk
  part {
    filename     = "00-setup.sh"
    content_type = "text/x-shellscript"
    content = templatefile(
      "./setup.sh",
      {}
    )
  }
}

