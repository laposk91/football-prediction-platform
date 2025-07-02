pipeline {
    agent any

    environment {
        COMPOSE_PROJECT_NAME = "fpp_${BUILD_NUMBER}"
        BACKEND_PATH = "${WORKSPACE}/backend"
    }

    stages {
        // Add this stage to checkout the code from your Git repository
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
                sh 'docker-compose -f docker-compose.yml build --no-cache'
            }
        }

        stage('Run Tests') {
            steps {
                sh 'docker-compose -f docker-compose.yml up -d'
		sh 'docker-compose -f docker-compose.yml exec -T backend ls -la /app'
                sh 'docker-compose -f docker-compose.yml exec -T --workdir /app  backend poetry run pytest'
            }
        }
    }

    post {
        always {
            sh "docker-compose -f docker-compose.yml down"
            echo 'Pipeline finished.'
        }
    }
}
