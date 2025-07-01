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
                // Best Practice: For CI, we rely on the code baked into the Docker
                // image, not on live volume mounts. We will temporarily disable the
                // volume mount in docker-compose.yml to ensure a clean test run.
                echo "Temporarily disabling source code volume mount for CI..."
                sh "sed -i 's|- ./backend:/app:z|-# ./backend:/app:z|' docker-compose.yml"
                
                echo "Waiting for services to start..."
                sh "sleep 10"

                // This command now runs tests against the code baked into the image.
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
