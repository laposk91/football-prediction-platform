pipeline {
    agent any

    stages {
        stage('Build and Test') {
            steps {
                // Use 'docker compose' (with a space)
                sh 'docker compose -f docker-compose.yml up --build -d'
                sh 'docker compose -f docker-compose.yml exec -T backend pytest'
            }
        }
    }
    post {
        always {
            // Also use 'docker compose' here for cleanup
            sh 'docker compose -f docker-compose.yml down --volumes'
        }
    }
}
