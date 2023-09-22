pipeline {
    agent any

    tools {
        jdk 'jdk17'
        jfrog 'jfrog-cli'
    }

    environment {
        DOCKER_IMAGE_NAME = "darshankd.jfrog.io/dkd-spring-petclinic-docker/pet-clinic-container-image"
        // SERVER_ID = "darshankd"
    }

    stages {
        stage('Clone repo') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/darshandkd/spring-petclinic.git'
            }
        }
        stage ('Artifactory configuration') {
            // server = Artifactory.server SERVER_ID
            //buildInfo = Artifactory.newBuildInfo()
            steps {
                script {
                    server = Artifactory.server(SERVER_ID)
                    buildInfo = Artifactory.newBuildInfo()
                }
            }
        }
        stage ('Publish build info') {
            server.publishBuildInfo buildInfo
        }
        stage('Build') {
            steps {
                sh './mvnw -B -DskipTests clean'
            }
        }
        stage('Execute tests') {
            steps {
                sh './mvnw test'
                junit 'target/surefire-reports/*.xml'
            }
        }
        stage('Bundle app') {
            steps {
                sh './mvnw package'
            }
        }

        stage('Build image - mvnw') {
            steps {
                sh './mvnw spring-boot:build-image -Dspring-boot.build-image.imageName=$DOCKER_IMAGE_NAME'
            }
        }
        
        stage('OWASP Depedency check') {
            steps {
                    // Run the OWASP Dependency-Check
                    dependencyCheck additionalArguments: "-s './' -f 'ALL' --failOnCVSS 5 --prettyPrint", odcInstallation: "OWASP" // This will fail the build if a CVSS score of 5 or higher is found
                    dependencyCheckPublisher pattern: 'dependency-check-report.xml'
            }
        }

        stage('Scan and push image') {
            steps {
                dir('jFrog-demo') {
                    // Scan Docker image for vulnerabilities
                    jf "docker scan $DOCKER_IMAGE_NAME"
                    // Push image to Artifactory
                    jf "docker push $DOCKER_IMAGE_NAME"
                }
            }
        }
        stage ('Xray scan') {
            def scanConfig = [
                    'buildName'      : buildInfo.name,
                    'buildNumber'    : buildInfo.number,
                    'failBuild'      : true
            ]
            def scanResult = server.xrayScan scanConfig
            echo scanResult as String
        }
        stage('Publish build info') {
            steps {
                jf 'rt build-publish'
            }
        }
    }
}
