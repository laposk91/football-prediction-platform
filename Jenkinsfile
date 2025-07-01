pipeline {
    // 1. Agent Configuration
    // Use a specific Docker container as the build environment.
    // This ensures all necessary tools (docker, docker-compose) are available.
    // The agent will connect to the Docker-in-Docker service you set up.
    agent {
        docker {
            image 'docker/compose:1.29.2'
            // These arguments are crucial for the agent to communicate with the dind service.
            // It connects to the 'jenkins' network and mounts the shared TLS certificates.
            args '--network jenkins --volume jenkins-docker-certs:/certs/client'
        }
    }

    // 2. Environment Variables
    environment {
        // This is a great practice! It prevents conflicts between concurrent builds.
        COMPOSE_PROJECT_NAME = "fpp_${BUILD_NUMBER}"
    }

    // 3. Pipeline Stages
    stages {
        stage('Lint Code') {
            steps {
                // Best Practice: Run linting within the same environment as your tests.
                // This command assumes 'flake8' is a dev dependency in your 'pyproject.toml'.
                // It starts the necessary services (if any are needed for linting),
                // runs the command in a new 'backend' container, and then removes it.
                sh 'docker-compose run --rm backend flake8 .'
            }
        }

        stage('Build Services') {
            steps {
                // Best Practice: Remove '--no-cache' for CI builds to leverage Docker's
                // layer caching and speed up the pipeline.
                sh 'docker-compose build'
            }
        }

        stage('Run Tests') {
            steps {
                // This part of your logic was already solid.
                // Run docker-compose in detached mode.
                sh 'docker-compose up -d'
                // Execute pytest inside the running backend container.
                sh 'docker-compose exec -T backend poetry run pytest'
            }
        }
    }

    // 4. Post-build Actions
    post {
        // This is a critical best practice for cleanup.
        always {
            // Clean up the containers and networks created by docker-compose.
            sh "docker-compose down"
            echo 'Pipeline finished.'
        }
    }
}
