#!/bin/sh

#set -eo pipefail

INIT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOCKER_USER="$1"
read -s -p "Please Enter password: " DOCKER_PASS


function docker_login {
   echo "${DOCKER_PASS}" | docker login --username="${DOCKER_USER}" --password-stdin
}

function docker_build {
    docker-compose -f $INIT_DIR/docker-compose.yaml  up --build -d
    docker tag simple-go-service_app:latest  "${DOCKER_USER}"/simple-go-service_app:latest
    docker push "${DOCKER_USER}"/simple-go-service_app:latest
}

function deploy_ingress {
  helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
  helm repo update
  helm upgrade --install --wait --timeout 720s ingress-nginx ingress-nginx --repo https://kubernetes.github.io/ingress-nginx --namespace ingress-nginx --create-namespace
}

function deploy_helm_go_app {
  local PROJECT_DIR="$INIT_DIR/helm/golang-app"
  local RELEASE_NAME="golang-app"

  if [[ -f "$PROJECT_DIR/values.yaml" ]]; then
      helm upgrade --install $RELEASE_NAME  $PROJECT_DIR --set image.repository="${DOCKER_USER}"/simple-go-service_app,image.tag=latest
  fi
}

function deploy_helm_postgres_app {
  local PROJECT_DIR="$INIT_DIR/helm/postgres-app"
  local RELEASE_NAME="postgres-app"

  if [[ -f "$PROJECT_DIR/values.yaml" ]]; then
    helm upgrade --install $RELEASE_NAME  $PROJECT_DIR --set image.repository="${DOCKER_USER}"/postgres,image.tag=14.2-alpine
  fi
}


function deployment {
   docker_login
   docker_build
   deploy_ingress
   deploy_helm_go_app
   deploy_helm_postgres_app
}

deployment "$@"
