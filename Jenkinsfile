pipeline {
    agent any

    environment {
        COMPOSE_PROJECT_NAME = "fpp_${BUILD_NUMBER}"
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Lint Code') {
            steps {
                sh 'docker run --rm -v $(pwd)/backend:/app -w /app python:3.10-slim sh -c "pip install flake8 && flake8 ."'
            }
        }

        stage('Build Services') {
            steps {
                // Use the default docker-compose.yml file
                sh 'docker-compose build --no-cache'
            }
        }

        stage('Run Tests') {
            steps {
                // Use the default docker-compose.yml file
                sh 'docker-compose up -d'
                // The workdir flag is still correct and necessary
                sh 'docker-compose exec -T --workdir /app backend poetry run python -m pytest'
            }
        }
    }

    post {
        always {
            // Use the default docker-compose.yml file
            sh "docker-compose down"
            echo 'Pipeline finished.'
        }
    }
}
