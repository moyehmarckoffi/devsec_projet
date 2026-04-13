pipeline {
    agent any

    environment {
        // On utilise ton nom Docker Hub pour que tout soit cohérent
        IMAGE_NAME = "moyehmarc/devsec_projet"
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Security Scan (Trivy)') {
            steps {
                echo "Analyse des vulnérabilités du code source..."
                sh "trivy fs ."
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Construction de l'image Docker..."
                sh "docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} ."
                sh "docker build -t ${IMAGE_NAME}:latest ."
            }
        }

        stage('Image Security Scan') {
            steps {
                echo "Scan de l'image Docker générée..."
                sh "trivy image ${IMAGE_NAME}:latest"
            }
        }

        stage('Quality Analysis (SonarQube)') {
            steps {
                script {
                    def scannerHome = tool 'SonarScanner'
                    withSonarQubeEnv('SonarQube') {
                        sh "${scannerHome}/bin/sonar-scanner \
                        -Dsonar.projectKey=devsec_projet \
                        -Dsonar.sources=. \
                        -Dsonar.host.url=http://localhost:9000"
                    }
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                echo "Envoi de l'image sur Docker Hub..."
                // On utilise sudo ici car tes tests manuels ont montré que c'était nécessaire
                sh "docker push ${IMAGE_NAME}:latest"
            }
        }

        stage('Deploy with Ansible') {
            steps {
                script {
                    echo "Déploiement sur la VM de production via Ansible..."
                    // On lance le playbook qui va faire le travail sur la VM 2
                    sh "ansible-playbook -i ansible/hosts.ini ansible/deploy.yml --extra-vars 'ansible_ssh_common_args=\"-o StrictHostKeyChecking=no\"'"
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline terminé !"
        }
    }
}
