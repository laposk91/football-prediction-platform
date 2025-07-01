pipeline {
    // 1. Agent Configuration
    // Use a specific Docker container as the build environment.
    // This container has docker-compose pre-installed.
    agent {
        docker {
            image 'docker/compose:1.29.2'
        }
    }

    // 2. Environment Variables
    environment {
        // Use a unique project name to avoid conflicts between concurrent builds.
        COMPOSE_PROJECT_NAME = "fpp_${BUILD_NUMBER}"
    }

    // 3. Pipeline Stages
    stages {
        stage('Lint Code') {
            steps {
                // Run linting within the same environment as your tests.
                // This assumes 'flake8' is a dev dependency in your 'pyproject.toml'.
                sh 'docker-compose run --rm backend flake8 .'
            }
        }

        stage('Build Services') {
            steps {
                // Use Docker's layer caching to speed up the pipeline.
                sh 'docker-compose build'
            }
        }

        stage('Run Tests') {
            steps {
                // Run docker-compose in detached mode.
                sh 'docker-compose up -d'
                // Execute pytest inside the running backend container.
                sh 'docker-compose exec -T backend poetry run pytest'
            }
        }
    }

    // 4. Post-build Actions
    post {
        // Always clean up containers and networks to prevent orphaned resources.
        always {
            sh "docker-compose down"
            echo 'Pipeline finished.'
        }
    }
}
