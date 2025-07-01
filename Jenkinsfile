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
                // We use 'run' here as well. It starts the necessary dependencies
                // (like the database), runs the tests in a new container,
                // and then stops, ensuring a clean environment.
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
