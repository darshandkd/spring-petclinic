import org.jfrog.hudson.pipeline.Artifactory

node {
  environment {
      BUILD_NUMBER = '1.0.0'
  }
  
  //Clone spring-petclinic project from GitHub repository
  stage('Clone repo') {
    git branch: 'jenkins-workspace',
        url:    'https://github.com/darshandkd/spring-petclinic.git'
  }
  
  //run mvn wrapper for build, install and package
  stage('Build') {
    sh './mvnw -B -DskipTests clean'
  }
  
  //run all the Junit test
  stage('Execute tests') {
    sh './mvnw test'
    junit 'target/surefire-reports/*.xml'
  }
  
  //bundle application
  stage('Bundle app') {
    sh './mvnw package'
  }
  
  //Create pet-clinic application image
  stage('Build image - mvnw'){
    sh './mvnw spring-boot:build-image -Dspring-boot.build-image.imageName=pet-clinic-container-image'  
  }
  
  stage('Publish to jFrog-artifactory'){ 
//   def server = Artifactory.newServer url: 'ARTIFACTORY_URL', username: 'ARTIFACTORY_USER_NAME', password: 'ARTIFACTORY_PASSWORD'
   def server = Artifactory.server('https://darshandkd.jfrog.io')
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
