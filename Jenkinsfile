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
                // Best Practice: Add a delay to allow services like the database
                // to fully initialize before running tests.
                echo "Waiting for services to start..."
                sh "sleep 10"

                // This command runs tests in a clean, ephemeral container.
                echo "Running tests..."
                sh 'docker-compose run --rm backend poetry run pytest'
            }
        }
    }

    // Post-build Actions
    post {
        // This block will now clean up any services that were started
        // as dependencies for the test run (e.g., the database).
        always {
            sh "docker-compose down"
            echo 'Pipeline finished.'
        }
    }
}
