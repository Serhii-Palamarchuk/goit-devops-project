pipeline {
  agent {
    kubernetes {
      yaml '''
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug
    command:
    - cat
    tty: true
    volumeMounts:
    - name: docker-config
      mountPath: /kaniko/.docker
  - name: git
    image: alpine/git:latest
    command:
    - cat
    tty: true
  volumes:
  - name: docker-config
    secret:
      secretName: ecr-docker-config
'''
    }
  }

  environment {
    AWS_REGION = 'us-west-2'
    ECR_REPOSITORY = '493947253485.dkr.ecr.us-west-2.amazonaws.com/lesson-8-9-ecr'
    IMAGE_TAG = "${env.BUILD_NUMBER}"
  }

  stages {
    stage('Checkout') {
      steps {
          checkout scm
      }
    }
    stage('Build and Push Docker Image') {
      steps {
        container('kaniko') {
          sh '''
            /kaniko/executor \
              --context=${WORKSPACE}/lesson-8-9/app \
              --dockerfile=${WORKSPACE}/lesson-8-9/app/Dockerfile \
              --destination=${ECR_REPOSITORY}:${IMAGE_TAG}
          '''
        }
      }
    }

    stage('Update Helm values.yaml') {
      steps {
        container('git') {
          sh '''
            cd ${WORKSPACE}

            git config --global --add safe.directory ${WORKSPACE}

            git config user.email "jenkins@example.com"
            git config user.name "Jenkins CI"

            sed -i "s/tag: .*/tag: ${IMAGE_TAG}/" lesson-8-9/charts/django-app/values.yaml

            git add lesson-8-9/charts/django-app/values.yaml
            git commit -m "Update image tag to ${IMAGE_TAG}" || echo "No changes to commit"
          '''

          withCredentials([usernamePassword(credentialsId: 'github-token', usernameVariable: 'GIT_USERNAME', passwordVariable: 'GIT_TOKEN')]) {
            sh '''
              cd ${WORKSPACE}

              git remote set-url origin https://${GIT_USERNAME}:${GIT_TOKEN}@github.com/Serhii-Palamarchuk/goit-devops-project.git
              git push origin HEAD:main
            '''
          }
        }
      }
    }
  }
}
