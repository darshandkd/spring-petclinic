pipeline {
  tools {
    jdk 'jdk17'
    // jfrog 'jfrog-cli'
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
    sh './mvnw spring-boot:build-image -Dspring-boot.build-image.imageName=darshandkd.jfrog.io/docker/pet-clinic-container-image'  
  }
  }
    stage('Push Image to Artifactory') {
            steps {
                script {
                    docker.withRegistry('https://darshandkd.jfrog.io', 'darshan-artifactory') {
                        def customImage = docker.image("darshandkd.jfrog.io/docker/pet-clinic-container-image")
                        customImage.push("${env.BUILD_NUMBER}")
                    }
                }
            }
        }

//         stage ('Push Image to Artifactory') {
//             steps {
//   // docker login darshandkd.jfrog.io -u $ARTIFACTORY_USER -p $ARTIFACTORY_PASSWD
//                 rtDockerPush(
//                     serverId: "darshan-artifactory",
//                     image: "darshandkd.jfrog.io/docker/" + "pet-clinic-container-image",
//                     targetRepo: 'dkd-spring-petclinic',
//                     properties: 'project-name=spring-petclinic;status=stable'
//                 )
//             }
//         }

// }
  // stage ('Setup JFrog CLI') {
  //           steps {
  //               withCredentials([[$class:'UsernamePasswordMultiBinding', credentialsId: 'admin.jfrog', usernameVariable:'ARTIFACTORY_USER', passwordVariable:'ARTIFACTORY_PASS']]) {
  //                    sh '''
  //                       ./jfrog rt config --url=https://darshandkd.jfrog.io/artifactory --dist-url=https://darshandkd.jfrog.io/distribution --interactive=false --user=${ARTIFACTORY_USER} --password=${ARTIFACTORY_PASS}
  //                       ./jfrog rt ping
  //                    '''
  //                }
  //           }
  //       }
}
}
