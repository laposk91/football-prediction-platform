pipeline {
    agent any
    stages {
        stage('Environment Check') {
            steps {
                sh 'docker --version'
                sh 'docker compose version || echo "docker compose not available"'
                sh 'docker-compose --version || echo "docker-compose not available"'
                sh 'which docker'
                sh 'ls -la /usr/local/bin/ | grep -i compose || echo "No compose in /usr/local/bin"'
            }
        }
        stage('Build and Test') {
            steps {
                script {
                    // Detect which compose command is available
                    def composeCmd = 'docker-compose'
                    try {
                        sh 'docker compose version'
                        composeCmd = 'docker compose'
                        echo "Using: docker compose"
                    } catch (Exception e) {
                        echo "Using: docker-compose (fallback)"
                    }
                    
                    // Build and start services
                    sh "${composeCmd} -f docker-compose.yml up --build -d"
                    
                    // Wait for services to be ready
                    sh 'sleep 15'
                    
                    // Run tests
                    sh "${composeCmd} -f docker-compose.yml exec -T backend pytest"
                    
                    // Store compose command for cleanup
                    env.COMPOSE_CMD = composeCmd
                }
            }
        }
    }
    post {
        always {
            script {
                def composeCmd = env.COMPOSE_CMD ?: 'docker-compose'
                // Cleanup
                sh "${composeCmd} -f docker-compose.yml down --volumes"
                
                // Optional: Clean up dangling images to save space
                sh 'docker image prune -f'
            }
        }
        failure {
            script {
                def composeCmd = env.COMPOSE_CMD ?: 'docker-compose'
                // Optional: Show logs on failure for debugging
                sh "${composeCmd} -f docker-compose.yml logs"
            }
        }
    }
}
