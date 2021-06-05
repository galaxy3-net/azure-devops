provider "kubernetes" {
  config_path    = "~/.kube/config"
  #config_context = "my-context"
}

resource "kubernetes_namespace" "wordpress" {
  metadata {
    name = "wordpress"
  }
}

#  https://artifacthub.io/packages/helm/bitnami/wordpress
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "wordpress" {
  name       = "wordpress"

  repository = "https://charts.bitnami.com/bitnami"
  chart      = "wordpress"
  namespace  = "wordpress"

  values         = [file("config/values.yml")]

  set {
    name  = "service.type"
    value = "LoadBalancer"
    #value = "ClusterIP"
  }

#  values = [
#      <<-EOF
#      wordpressUsername: vagrant
#      wordpressPassword: vagrant
#      mariadb.auth.rootPassword: secretpassword
#      EOF
#  ]

}

#
#  Providing values for a Terraform helm_release
#    https://devopsrunbook.wordpress.com/2019/03/23/terraform-helm_release/