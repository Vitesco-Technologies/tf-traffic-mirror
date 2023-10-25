resource "time_sleep" "wait_30_seconds" {
  depends_on = [aws_instance.tm-ec2-target]

  create_duration = "30s"
}

resource "aws_ec2_traffic_mirror_target" "tm_eni_target" {
  description          = "Org TM ENI target"
  network_interface_id = aws_network_interface.capture.id

  depends_on = [time_sleep.wait_30_seconds]

  tags = merge(var.tf_tags, {Name = "traffic-mirror-eni-target"})
}

resource "aws_ram_resource_share" "tm_eni_target_share" {
  name                      = "TM Target Share - ${var.region}"

  tags = merge(var.tf_tags, {Name = "traffic-mirror-eni-target"})
}

resource "aws_ram_principal_association" "tm_eni_target_share_ass" {
  principal          = data.aws_organizations_organization.current.arn
  resource_share_arn = aws_ram_resource_share.tm_eni_target_share.arn
}

resource "aws_ram_resource_association" "tm_eni_target_ass" {
  resource_arn       = aws_ec2_traffic_mirror_target.tm_eni_target.arn
  resource_share_arn = aws_ram_resource_share.tm_eni_target_share.arn
}
