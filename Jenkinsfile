pipeline {
   agent { label 'Wraith_slave' }

   stages {
      stage('Build') {
         steps {
            sh "sudo python3 -m pip install -r requirements.txt"
            sh "sudo python3 manage.py migrate"
         }
      }
   }
}