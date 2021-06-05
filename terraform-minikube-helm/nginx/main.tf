#  https://artifacthub.io/packages/helm/bitnami/nginx-ingress-controller
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource helm_release nginx_ingress {
  name       = "nginx-ingress-controller"

  repository = "https://charts.bitnami.com/bitnami"
  chart      = "nginx-ingress-controller"

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  set {
    name = "defaultBackend.containerPort"
    value = "8081"
  }
}