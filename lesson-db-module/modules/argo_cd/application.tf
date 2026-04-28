resource "kubernetes_namespace_v1" "django_app" {
  metadata {
    name = "django-app"
  }
}

resource "kubernetes_manifest" "django_app" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"

    metadata = {
      name      = "django-app"
      namespace = kubernetes_namespace_v1.argocd.metadata[0].name
    }

    spec = {
      project = "default"

      source = {
        repoURL        = "https://github.com/Serhii-Palamarchuk/goit-devops-project.git"
        targetRevision = "main"
        path           = "lesson-8-9/charts/django-app"

        helm = {
          valueFiles = ["values.yaml"]
        }
      }

      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = kubernetes_namespace_v1.django_app.metadata[0].name
      }

      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }

        syncOptions = [
          "CreateNamespace=true"
        ]
      }
    }
  }

  depends_on = [
    helm_release.argocd,
    kubernetes_namespace_v1.django_app
  ]
}
