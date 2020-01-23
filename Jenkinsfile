pipeline {
   agent any

   stages {
      stage('Build') {
         steps {
            sh "docker-compose build"
         }
      }
      stage('Test') {
         environment {
                ERROR_FILE = 'web/failed.err'
            }
         steps {
            sh "docker-compose up --abort-on-container-exit"
            sh "if [ -f $ERROR_FILE ]; then exit 1; fi"
         }
      }
   }
}
