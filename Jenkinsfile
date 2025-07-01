pipeline {
    // We can use 'agent any' because the main Jenkins container
    // now has direct access to Docker.
    agent any

    stages {
        stage('Build and Test') {
            steps {
                // Use the docker-compose file to define and run the services.
                // The Jenkins agent has docker-compose because we are mounting the docker binary.
                sh 'docker-compose -f docker-compose.yml up --build -d'
                sh 'docker-compose -f docker-compose.yml exec -T backend pytest'
            }
        }
    }
    post {
        always {
            // Always clean up the services after the build.
            sh 'docker-compose -f docker-compose.yml down --volumes'
        }
    }
}
