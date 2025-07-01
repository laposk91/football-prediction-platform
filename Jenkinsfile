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
                sh 'docker-compose up -d'
                sh 'docker-compose exec -T backend poetry run pytest'
            }
        }
    }

    // Post-build Actions
    post {
        // Always clean up containers and networks.
        always {
            sh "docker-compose down"
            echo 'Pipeline finished.'
        }
    }
}
