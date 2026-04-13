pipeline {
    agent any

    environment {
        IMAGE_NAME = "mon-app-python"
    }

    stages {
        stage('Checkout Code') {
            steps {
                // Cette étape récupère le code du dépôt Git configuré dans Jenkins
                checkout scm
            }
        }

        stage('Security Scan (Trivy)') {
            steps {
                echo "Analyse des vulnérabilités en cours..."
                // On scanne le dossier actuel avant même de build
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
                // On scanne l'image qu'on vient de créer pour détecter des failles
                sh "trivy image ${IMAGE_NAME}:latest"
            }
        }
	stage('Quality Analysis (SonarQube)') {
		steps {
		script {
            // On utilise l'outil configuré dans Jenkins
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
    }

    post {
        always {
            echo "Pipeline terminé !"
        }
    }
}
