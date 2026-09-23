resource "aws_key_pair" "this" {
  key_name   = var.key_pair_name
  public_key = var.ssh_key

  tags = {
    Project = var.project_tag
    ID      = var.id_tag
  }
}
