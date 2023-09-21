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
            steps {
                git branch: 'main',
                    url: 'https://github.com/darshandkd/spring-petclinic.git'
            }
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
        
        stage('OWASP Dependency Check') {
            steps {
                    // Run the OWASP Dependency-Check
                    dependencyCheck additionalArguments: "-s './' -f 'ALL' --failOnCVSS 5", odcInstallation: "OWASP" // This will fail the build if a CVSS score of 5 or higher is found
            }
        }
        
    // stage('OWASP Dependency-Check Vulnerabilities') {
    //   steps {
    //     dependencyCheck additionalArguments: ''' 
    //                 -o './'
    //                 -s './'
    //                 -f 'ALL' 
    //                 --prettyPrint''', odcInstallation: 'OWASP'
        
    //     dependencyCheckPublisher pattern: 'dependency-check-report.xml'
    //   }
    // }

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

        stage('Publish build info') {
            steps {
                jf 'rt build-publish'
            }
        }
    }
}
