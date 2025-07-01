pipeline {
    // 1. Agent Configuration
    agent any

    // 2. Environment Variables
    environment {
        // Use a unique project name to avoid conflicts if you have multiple projects
        COMPOSE_PROJECT_NAME = "fpp_${BUILD_NUMBER}"
    }

    // 3. Pipeline Stages
    stages {
        stage('Lint Code') {
            steps {
                sh 'docker run --rm -v $(pwd)/backend:/app -w /app python:3.10-slim sh -c "pip install flake8 && flake8 ."'
            }
        }

        stage('Build Services') {
            steps {
                sh 'docker-compose build --no-cache'
            }
        }

        stage('Run Tests') {
            steps {
                // Run docker-compose in detached mode
                sh 'docker-compose up -d'
                // Execute pytest inside the running backend container
                sh 'docker-compose exec -T backend poetry run pytest'
            }
        }
    }

    // 4. Post-build Actions
    post {
        always {
            // Clean up the containers and networks created by docker-compose
            sh "docker-compose down"
            echo 'Pipeline finished.'
        }
    }
}
