pipeline {
  tools {
    jdk 'jdk17',
    jfrog 'jfrog-cli'
  }
  agent any
  stages {
  //Clone spring-petclinic project from GitHub repository
  stage('Clone repo') {
    steps {
    git branch: 'master',
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
    sh './mvnw spring-boot:build-image -Dspring-boot.build-image.imageName=pet-clinic-container-image'  
  }
  }
  stage('Publish to jFrog-artifactory'){ 
    steps {
   def server = Artifactory.newServer url: 'ARTIFACTORY_URL', username: 'ARTIFACTORY_USER_NAME', password: 'ARTIFACTORY_PASSWORD'
   def uploadSpec = """{
       "files": [
            { 
              "pattern": "target/*.jar",
              "target" : "ARTIFACTORY_TARGET_REPO",
              "props"  : "Unit-Tested=Yes"
            }
        ]
      }"""
    server.upload(uploadSpec)
    }
   }
}
}
