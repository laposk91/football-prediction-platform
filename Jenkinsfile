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
        
        stage('Prepare Environment') {
            steps {
                // Correctly replace the placeholder AND save to a new file
                sh 'sed "s|BACKEND_PATH_PLACEHOLDER|${WORKSPACE}/backend:z|g" docker-compose.yml > docker-compose.ci.yml'
            }
        }

        stage('Lint Code') {
            steps {
                sh 'docker run --rm -v $(pwd)/backend:/app -w /app python:3.10-slim sh -c "pip install flake8 && flake8 ."'
            }
        }

        stage('Build Services') {
            steps {
                // Use the new docker-compose.ci.yml file
                sh 'docker-compose -f docker-compose.ci.yml build --no-cache'
            }
        }

        stage('Run Tests') {
            steps {
                // Use the new docker-compose.ci.yml file
                sh 'docker-compose -f docker-compose.ci.yml up -d'
                sh 'docker-compose -f docker-compose.ci.yml exec -T --workdir /app backend poetry run pytest'
            }
        }
    }

    post {
        always {
            // Use the new docker-compose.ci.yml file
            sh "docker-compose -f docker-compose.ci.yml down"
            echo 'Pipeline finished.'
        }
    }
}
