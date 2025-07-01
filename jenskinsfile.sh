pipeline {
    agent any
    
    stages {
        stage('Environment Check') {
            steps {
                sh 'docker --version'
                sh 'docker-compose --version'
                sh 'pwd && ls -la'
            }
        }
        
        stage('Build and Test') {
            steps {
                sh 'docker-compose -f docker-compose.yml up --build -d'
                
                // Wait for services to be ready
                sh 'sleep 20'
                
                // Run tests
                sh 'docker-compose -f docker-compose.yml exec -T backend pytest'
            }
        }
    }
    
    post {
        always {
            // Cleanup
            sh 'docker-compose -f docker-compose.yml down --volumes'
            
            // Clean up dangling images
            sh 'docker image prune -f'
        }
        failure {
            // Show logs on failure for debugging
            sh 'docker-compose -f docker-compose.yml logs'
        }
    }
}
