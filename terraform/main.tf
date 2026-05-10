resource "null_resource" "install_k3s" {

  provisioner "local-exec" {
    command = "bash ../scripts/install_k3s.sh"
  }
}
