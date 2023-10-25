resource "aws_instance" "tm-ec2-target" {
  ami                    = data.aws_ami.ubuntu-linux.id
  instance_type          = "c7g.xlarge"
  user_data              = data.template_cloudinit_config.master.rendered

  iam_instance_profile   = aws_iam_instance_profile.tm_ssm_inst_profile.name

  availability_zone = "${var.region}${var.region_az[var.region]}"

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
    encrypted   = true
  }

  network_interface {
    network_interface_id = aws_network_interface.mgmt.id
    device_index         = 0
  }
  network_interface {
    network_interface_id = aws_network_interface.capture.id
    device_index         = 1
  }

  tags = merge(var.tf_tags, {Name = "traffic-mirror-ec2"})
}

resource "aws_volume_attachment" "this_ec2" {
  skip_destroy = true
  device_name  = "/dev/sdh"
  volume_id    = aws_ebs_volume.this.id
  instance_id  = aws_instance.tm-ec2-target.id
}

resource "aws_ebs_volume" "this" {
  availability_zone = "${var.region}${var.region_az[var.region]}"
  size              = 100
  type              = "gp3"
  encrypted         = true

  
  tags = merge(var.tf_tags, {Name = "traffic-mirror-ebs"})
}

resource "aws_security_group" "ssh-vxlan" {
  name        = "allow_ssh_vxlan_traffic_mirror-${var.region}"
  description = "Allow SSH and VXLAN inbound traffic"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.network_ranges
  }

  ingress {
    description = "VXLAN"
    from_port   = 4789
    to_port     = 4789
    protocol    = "udp"
    cidr_blocks = var.network_ranges
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = var.region_vpc_id[var.region]

  tags = merge(var.tf_tags, {Name = "traffic-mirror-sg"})
}

resource "aws_network_interface" "mgmt" {
  subnet_id   = var.region_subnet_id[var.region]
  security_groups = [aws_security_group.ssh-vxlan.id]

  tags = merge(var.tf_tags, {Name = "traffic-mirror-mgmt-if"})
}

resource "aws_network_interface" "capture" {
  subnet_id   = var.region_subnet_id[var.region]
  security_groups = [aws_security_group.ssh-vxlan.id]

  tags = merge(var.tf_tags, {Name = "traffic-mirror-capture-if"})
}

# Create EC2 Instance Role
resource "aws_iam_role" "ssm_s3_role" {
  name = "tm-traffic-mirror-ssm-role-${var.region}"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF

  tags = merge(var.tf_tags, {Name = "traffic-mirror-ec2-role"})
}

resource "aws_iam_instance_profile" "tm_ssm_inst_profile" {
  name = "tm-traffic-mirror-ssm-inst-profile-${var.region}"
  role = aws_iam_role.ssm_s3_role.name
}

data "aws_iam_policy" "AmazonSSMManagedInstanceCore" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "SSM-role-policy-attach" {
  role       = aws_iam_role.ssm_s3_role.name
  policy_arn = data.aws_iam_policy.AmazonSSMManagedInstanceCore.arn
}

resource "aws_iam_policy" "s3_access" {
  name        = "tm-traffic-mirror-s3-policy"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "allowS3Access",
        "Effect": "Allow",
        "Action": [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ],
        "Resource": [
          "arn:aws:s3:::${aws_s3_bucket.traffic_mirror_s3.id}",
          "arn:aws:s3:::${aws_s3_bucket.traffic_mirror_s3.id}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_attach" {
  role       = aws_iam_role.ssm_s3_role.name
  policy_arn = aws_iam_policy.s3_access.arn
}
