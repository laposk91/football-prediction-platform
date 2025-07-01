pipeline {
    // 1. Agent Configuration
    // This tells Jenkins to run all stages inside a container.
    // We use an image that has Docker tools pre-installed.
    agent {
        docker {
            image 'docker:latest'
            reuseNode true // Important for sharing the workspace
            args '-v /var/run/docker.sock:/var/run/docker.sock' // Mount the Docker socket
        }
    }

    // 2. Environment Variables
    environment {
        // Use a unique project name to avoid conflicts
        COMPOSE_PROJECT_NAME = "fpp_${BUILD_NUMBER}"
    }

    // 3. Pipeline Stages
    stages {
        stage('Install Dependencies') {
            steps {
                // The docker image doesn't have Python, so we install it
                // along with the necessary Python tools.
                sh 'apk add --no-cache python3 py3-pip'
                sh 'pip3 install flake8'
            }
        }
        stage('Lint Code') {
            steps {
                // Now we can run flake8 directly on the source code
                sh 'flake8 backend/'
            }
        }
        stage('Build and Test') {
            steps {
                // These commands now work because the agent has docker-compose
                // and can talk to the Docker daemon via the mounted socket.
                sh 'docker-compose build'
                sh 'docker-compose up -d'
                sh 'docker-compose exec -T backend pytest'
            }
        }
    }

    // 4. Post-build Actions
    post {
        // This 'always' block runs to clean up the environment,
        // regardless of whether the pipeline succeeds or fails.
        always {
            sh 'docker-compose down --volumes'
        }
    }
}
