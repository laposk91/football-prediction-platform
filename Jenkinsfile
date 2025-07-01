pipeline {
    // Use the main Jenkins agent. Our custom Docker image has all the tools
    // (docker, docker-compose) and permissions needed.
    agent any

    // Environment Variables
    environment {
        // Use a unique project name to avoid conflicts between concurrent builds.
        COMPOSE_PROJECT_NAME = "fpp_${BUILD_NUMBER}"
    }

    // Pipeline Stages
    stages {
        stage('Lint Code') {
            steps {
                // This 'run' command works well for one-off tasks.
                sh 'docker-compose run --rm backend flake8 .'
            }
        }

        stage('Build Services') {
            steps {
                sh 'docker-compose build'
            }
        }

        stage('Run Tests') {
            steps {
                // Best Practice: For CI, create an override file to disable
                // development-only configurations like volume mounts.
                // An empty 'volumes' list here overrides the one in the main file.
                writeFile file: 'docker-compose.ci.yml', text: '''
services:
  backend:
    volumes: []
'''
                echo "Waiting for services to start..."
                sh "sleep 10"

                // Run docker-compose using both the base file and the CI override file.
                // This ensures tests run against the code baked into the image.
                echo "Running tests..."
                sh 'docker-compose -f docker-compose.yml -f docker-compose.ci.yml run --rm backend poetry run pytest'
            }
        }
    }

    // Post-build Actions
    post {
        // Always clean up containers and networks.
        // We must also use the override file here to ensure the correct
        // set of containers is targeted for cleanup.
        always {
            sh "docker-compose -f docker-compose.yml -f docker-compose.ci.yml down"
            echo 'Pipeline finished.'
        }
    }
}
