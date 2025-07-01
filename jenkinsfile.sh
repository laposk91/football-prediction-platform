#!/bin/bash
# This is the definitive script to build and run a stable, resilient Jenkins environment.

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
JENKINS_IMAGE_NAME="custom-jenkins-server"
JENKINS_CONTAINER_NAME="jenkins-server"
JENKINS_VOLUME_NAME="jenkins_home"
JENKINS_DOCKERFILE="Dockerfile.jenkins"

# --- Pre-flight Check ---
# Verify that the 'docker' group exists on the host machine.
echo "--- Verifying Docker group permissions ---"
if ! getent group docker > /dev/null; then
  echo "Error: The 'docker' group does not exist on this system." >&2
  echo "Please install Docker correctly and add your user to the 'docker' group." >&2
  exit 1
fi
DOCKER_GID=$(getent group docker | cut -d: -f3)
echo "Docker group found with GID: ${DOCKER_GID}. Proceeding."
echo ""

# --- Step 0: Comprehensive Cleanup ---
echo "--- Performing comprehensive cleanup of old Jenkins environments ---"
docker stop ${JENKINS_CONTAINER_NAME} jenkins jenkins-lts jenkins-docker || true
docker rm ${JENKINS_CONTAINER_NAME} jenkins jenkins-lts jenkins-docker || true
docker network rm jenkins || true
docker volume rm ${JENKINS_VOLUME_NAME} jenkins-data jenkins-docker-certs || true
echo "--- Cleanup complete ---"
echo ""

# --- Step 1: Build the Custom Jenkins Image ---
echo "--- Building custom Jenkins image from '${JENKINS_DOCKERFILE}' ---"
docker build -t ${JENKINS_IMAGE_NAME} -f ${JENKINS_DOCKERFILE} .
echo ""

# --- Step 2: Run the Jenkins Container ---
echo "--- Starting Jenkins container: '${JENKINS_CONTAINER_NAME}' ---"
docker run \
  --name ${JENKINS_CONTAINER_NAME} \
  --detach \
  --restart unless-stopped \
  --group-add ${DOCKER_GID} \
  --env JAVA_OPTS="-Xms1024m -Xmx2048m" \
  --publish 8080:8080 \
  --publish 50000:50000 \
  --volume ${JENKINS_VOLUME_NAME}:/var/jenkins_home \
  --volume /var/run/docker.sock:/var/run/docker.sock:z \
  ${JENKINS_IMAGE_NAME}

echo ""
echo "✅ Jenkins setup is complete and running in the background."
echo "   It may take a few minutes to be fully ready."
echo ""
echo "   Access Jenkins at: http://localhost:8080"
echo ""
echo "   To get the initial admin password, run: docker exec ${JENKINS_CONTAINER_NAME} cat /var/jenkins_home/secrets/initialAdminPassword"
echo ""

