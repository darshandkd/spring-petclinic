pipeline {
  tools {
    jdk 'jdk17',
    jfrog 'jfrog-cli'
  }
  agent any
  environment {
		DOCKER_IMAGE_NAME = "darshankd.jfrog.io/dkd-spring-petclinic-docker/pet-clinic-container-image"
    //DOCKER_IMAGE_NAME = "darshankd.jfrog.io/docker-local/hello-frog:1.0.0"
	}
  stages {
  //Clone spring-petclinic project from GitHub repository
  stage('Clone repo') {
    steps {
    git branch: 'main',
        url:    'https://github.com/darshandkd/spring-petclinic.git'
  }
  }
  //run mvn wrapper for build, install and package
  stage('Build') {
    steps {
    sh './mvnw -B -DskipTests clean'      
  }
  }
    
  //run all the Junit test
  stage('Execute tests') {
    steps {
    sh './mvnw test'
    junit 'target/surefire-reports/*.xml'
  }
  }
  
  //bundle application
  stage('Bundle app') {
    steps {
    sh './mvnw package'
    }
  }
  
  //Create pet-clinic application image
  stage('Build image - mvnw'){
    steps {
    //sh './mvnw spring-boot:build-image -Dspring-boot.build-image.imageName=darshandkd.jfrog.io/dkd-spring-petclinic-docker/pet-clinic-container-image'  
    sh './mvnw spring-boot:build-image -Dspring-boot.build-image.imageName=$DOCKER_IMAGE_NAME'  
  }
  }
/*    stage('Push Image to Artifactory') {
            steps {
                script {
                    docker.withRegistry('https://darshandkd.jfrog.io', 'darshan-artifactory') {
                        def customImage = docker.image("darshandkd.jfrog.io/dkd-spring-petclinic-docker/pet-clinic-container-image")
                        customImage.push("${env.BUILD_NUMBER}")
                    }
                }
            }
        }
*/

  stage('Scan and push image') {
      steps {
				dir('/workspace/spring-petclinic') {
					// Scan Docker image for vulnerabilities
					jf 'docker scan $DOCKER_IMAGE_NAME'

					// Push image to Artifactory
					jf 'docker push $DOCKER_IMAGE_NAME'
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
