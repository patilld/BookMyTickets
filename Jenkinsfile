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
        stage("Build docker image") {
            steps {
                echo "Building Docker image"
                sh 'docker build -t bookmytickets -t patilld94/bookmytickets:1.1.${BUILD_NUMBER} .'
                echo "Docker image built!!!"
            }
        }
        stage("Push docker image to Docker hub") {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub_cred',
                                                     usernameVariable: 'DOCKER_USER',
                                                     passwordVariable: 'DOCKER_PASS')]) {
                        sh 'docker login docker.io -u ${DOCKER_USER} -p ${DOCKER_PASS}'
                        echo 'Pushing Docker Image to Docker Hub...'
                        sh 'docker push patilld94/bookmytickets:1.1.${BUILD_NUMBER}'
                        echo 'Docker Image Pushed to Docker Hub Successfully!'
                    }
                }
            }
        }
        stage("Deploy docker image to ECR") {
            steps {
                script {
                    withDockerRegistry([credentialsId: 'ecr-credentials', url: "https://554422869155.dkr.ecr.ap-south-1.amazonaws.com"]) {
                        echo 'Pushing docker image to ECR...'
                        sh 'docker tag bookmytickets:latest 554422869155.dkr.ecr.ap-south-1.amazonaws.com/patilld94/bookmytickets:1.1.${BUILD_NUMBER}'
                        echo 'Docker image pushed to ECR successfully!'
                    }
                }
            }
        }
        stage("Remove docker images from local machine") {
            steps {
                sh 'docker system prune -af'
            }
        }
    }
}