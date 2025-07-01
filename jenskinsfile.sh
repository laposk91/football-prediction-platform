#!/bin/bash

# --- Cleanup: Stop and remove old containers and network to ensure a clean start ---
echo "Cleaning up old containers and network..."
docker stop jenkins-blueocean jenkins-docker &> /dev/null
docker rm jenkins-blueocean jenkins-docker &> /dev/null
docker network rm jenkins &> /dev/null
echo "Cleanup complete."

# 1. Create a Docker network
echo "Creating Jenkins network..."
docker network create jenkins

# 2. Run the Docker-in-Docker (dind) container
echo "Starting Docker-in-Docker container..."
docker run \
  --name jenkins-docker \
  --rm \
  --detach \
  --privileged \
  --network jenkins \
  --network-alias docker \
  --env DOCKER_TLS_CERTDIR=/certs \
  --volume jenkins-docker-certs:/certs/client \
  --volume jenkins-data:/var/jenkins_home \
  docker:dind

# 3. Wait for the dind container to be ready
echo "Waiting for Docker-in-Docker to initialize..."
sleep 15

# 4. Run the Jenkins container (with the fix)
echo "Starting Jenkins Blue Ocean container..."
docker run \
  --name jenkins-blueocean \
  --detach \
  --network jenkins \
  --env DOCKER_HOST=tcp://docker:2376 \
  --env DOCKER_CERT_PATH=/certs/client \
  --env DOCKER_TLS_VERIFY=1 \
  --publish 8080:8080 \
  --publish 50000:50000 \
  --volume jenkins-data:/var/jenkins_home \
  --volume "$HOME":/home \
  jenkins/jenkins:lts-jdk11
