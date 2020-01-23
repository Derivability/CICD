pipeline {
   agent any

   stages {
      stage('Build') {
         steps {
            sh "docker-compose build"
         }
      }
      stage('Test') {
         steps {
            sh "docker-compose up --abort-on-container-exit"
         }
      }
   }
}
