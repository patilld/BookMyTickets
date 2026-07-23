pipeline {
    agent any
    options {
        buildDiscarder(logRotator(numToKeepStr:'3', artifactNumToKeepStr:'3'))
    }
    tools {
        maven 'mvn_3.9.16'
    }
    stages {
        stage("Code compilation") {
            steps {
                echo "Code compilation started"
                sh 'mvn clean compile'
                echo "Code compilation completed!!!"
            }
        }
        stage("Unit testing") {
            steps {
                echo "Unit testing started"
                sh 'mvn test'
                echo "Unit testing completed!!!"
            }
        }
        stage("Code package") {
            steps {
                echo "Code packaging started"
                sh 'mvn package'
                sh 'cp target/*.jar target/bookmytickets-1.1.${BUILD_NUMBER}.jar'
                echo "Code packaging completed!!!"
            }
        }
    }

}