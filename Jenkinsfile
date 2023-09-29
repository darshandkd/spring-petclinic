pipeline {
    agent any

    tools {
        jdk 'jdk17'
        jfrog 'jfrog-cli'
    }
    environment {
        DOCKER_IMAGE_NAME = "darshankd.jfrog.io/dkd-spring-petclinic-docker/pet-clinic-container-image"
    }

    stages {
        stage('Clone repo') {
            // Clonning the Github repo "Main" branch to the target directory
            steps {
                git branch: 'main',
                    url: 'https://github.com/darshandkd/spring-petclinic.git'
            }
        }
        stage('Build app') {
            // Preparing the environment, cleaning up previous artifacts if exist.
            steps {
                sh './mvnw -B -DskipTests clean'
            }
        }
        stage('Execute tests') {
            // After the app is built, execting tests
            steps {
                sh './mvnw test'
                junit 'target/surefire-reports/*.xml'
            }
        }
        stage('Bundle app') {
            // After successful tests, bundling the compiled app as JAR
            steps {
                sh './mvnw package'
            }
        }
        stage('Build docker image') {
            // Building the Docker image of the JAR file for easy distribution
            steps {
                sh './mvnw spring-boot:build-image -Dspring-boot.build-image.imageName=$DOCKER_IMAGE_NAME'
            }
        }
        
        stage('OWASP dep. check') {
            steps {
                    // Run the OWASP Dependency-Check
                    dependencyCheck additionalArguments: "-s './' -f 'ALL' --prettyPrint", odcInstallation: "OWASP"
                    dependencyCheckPublisher pattern: 'dependency-check-report.xml'
            }
        }
        stage('jFrog X-ray scan') {
            steps {
                dir('jFrog-demo') {
                    // Scan Docker image for vulnerabilities
                    jf "docker scan $DOCKER_IMAGE_NAME"
                }
            }
        }
        stage('Push image to jFrog') {
            steps {
                dir('jFrog-demo') {
                    // tagging image with latest build number
                    jf "docker tag $DOCKER_IMAGE_NAME:latest $DOCKER_IMAGE_NAME:$env.BUILD_NUMBER"
                    // Push image to Artifactory
                    jf "docker push $DOCKER_IMAGE_NAME:$env.BUILD_NUMBER"
                }
            }
        }
        stage('Publish build info') {
            // Punlishing the build information to jFrog
            steps {
                jf 'rt build-publish'
            }
        }
    }
}
