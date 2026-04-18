pipeline {
    agent any

    environment {
        IMAGE_NAME = "moyehmarc/devsec_projet"
        // Nom du scanner défini dans "Manage Jenkins > Tools"
        SCANNER_HOME = tool 'sonar-scanner' 
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Security Scan (Trivy FS)') {
            steps {
                echo "Analyse des vulnérabilités du code source..."
                sh "trivy fs ."
            }
        }

        stage('Quality Analysis (SonarCloud)') {
            steps {
                echo "Analyse de la qualité sur SonarCloud..."
                // Utilisation du Token sécurisé configuré dans Jenkins
                withCredentials([string(credentialsId: 'SONAR_TOKEN', variable: 'SONAR_TOKEN')]) {
                    sh "${SCANNER_HOME}/bin/sonar-scanner \
                        -Dsonar.projectKey=dev-sec-project_dev-sec-project \
                        -Dsonar.organization=dev-sec-project \
                        -Dsonar.sources=. \
                        -Dsonar.host.url=https://sonarcloud.io \
                        -Dsonar.token=${SONAR_TOKEN}"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Construction de l'image Docker..."
                sh "docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} ."
                sh "docker build -t ${IMAGE_NAME}:latest ."
            }
        }

        stage('Image Security Scan (Trivy)') {
            steps {
                echo "Scan de l'image Docker générée..."
                sh "trivy image ${IMAGE_NAME}:latest"
            }
        }

        stage('Push to Docker Hub') {
            steps {
                echo "Envoi de l'image sur Docker Hub..."
                // Connexion et Push (Assure-toi d'être connecté sur la VM ou d'ajouter un stage login)
                sh "docker push ${IMAGE_NAME}:latest"
                sh "docker push ${IMAGE_NAME}:${BUILD_NUMBER}"
            }
        }

        stage('Deploy with Ansible') {
            steps {
                echo "Déploiement sur la VM via Ansible..."
                // Utilisation des fichiers dans ton dossier ansible/
                sh "ansible-playbook -i ansible/hosts.ini ansible/deploy.yml --extra-vars 'image_tag=${BUILD_NUMBER}'"
            }
        }
    }

    post {
        always {
            echo "Pipeline terminé !"
            // Nettoyage optionnel pour économiser l'espace disque
            sh "docker image prune -f"
        }
        success {
            echo "Déploiement réussi avec succès !"
        }
        failure {
            echo "Le pipeline a échoué. Vérifie les logs de l'étape en erreur."
        }
    }
}
