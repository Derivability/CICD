#!/bin/bash

set -x

function wait_for_jenkins ()
{
    echo "Waiting jenkins to launch on 8080..."

    while (( 1 )); do
        echo "Waiting for Jenkins"

        nc -zv ${JENKINS_IP} 8080
        if (( $? == 0 )); then
            break
        fi

        sleep 10
    done

    echo "Jenkins launched"
}

function slave_setup()
{
    # Wait till jar file gets available
    ret=1
    while (( $ret != 0 )); do
        sleep 10
        wget -O /opt/jenkins-cli.jar http://${JENKINS_IP}:8080/jnlpJars/jenkins-cli.jar
        ret=$?

        echo "jenkins cli ret [$ret]"
    done

    ret=1
    while (( $ret != 0 )); do
        wget -O /opt/slave.jar http://${JENKINS_IP}:8080/jnlpJars/slave.jar
        ret=$?

        echo "jenkins slave ret [$ret]"
    done
    
    mkdir -p /opt/jenkins-slave
    chown -R ubuntu:ubuntu /opt/jenkins-slave

    # Register_slave
    JENKINS_URL="http://${JENKINS_IP}:8080"

    USERNAME="${JENKINS_USER}"
    
    # PASSWORD=$(cat /tmp/secret)
    PASSWORD="${JENKINS_PASS}"

    SLAVE_IP=$(ip -o -4 addr list | tail -n1 | awk '{print $4}' | cut -d/ -f1)
    NODE_NAME="${AGENT_NAME}"
    NODE_SLAVE_HOME="/opt/jenkins-slave"
    EXECUTORS=1
    SSH_PORT=22

    CRED_ID="edu"
    LABELS="linux"
    USERID="ubuntu"

    cd /opt
    # Creating CMD utility for jenkins-cli commands
    jenkins_cmd="java -jar /opt/jenkins-cli.jar -s $JENKINS_URL -auth $USERNAME:$PASSWORD"

    # Waiting for Jenkins to load all plugins
    while (( 1 )); do

      count=$($jenkins_cmd list-plugins 2>/dev/null | wc -l)
      ret=$?

      echo "count [$count] ret [$ret]"

      if (( $count > 0 )); then
          break
      fi

      sleep 30
    done
    

    # Generating cred.xml for creating credentials on Jenkins server
    cat > /tmp/cred.xml <<EOF
<com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey plugin="ssh-credentials@1.16">
  <scope>GLOBAL</scope>
  <id>$CRED_ID</id>
  <description>Generated via Terraform for $SLAVE_IP</description>
  <username>$USERID</username>
  <privateKeySource class="com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey\$DirectEntryPrivateKeySource">
    <privateKey>${PEM}</privateKey>
  </privateKeySource>
</com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey>
EOF

    # Creating credential using cred.xml
    cat /tmp/cred.xml | $jenkins_cmd create-credentials-by-xml system::system::jenkins _
    
    # For Deleting Node, used when testing
    $jenkins_cmd delete-node $NODE_NAME
    
    # Generating node.xml for creating node on Jenkins server
    cat > /tmp/node.xml <<EOF
<slave>
  <name>$NODE_NAME</name>
  <description>Linux Slave</description>
  <remoteFS>$NODE_SLAVE_HOME</remoteFS>
  <numExecutors>$EXECUTORS</numExecutors>
  <mode>NORMAL</mode>
  <retentionStrategy class="hudson.slaves.RetentionStrategy\$Always"/>
  <launcher class="hudson.plugins.sshslaves.SSHLauncher" plugin="ssh-slaves@1.5">
    <host>$SLAVE_IP</host>
    <port>$SSH_PORT</port>
    <credentialsId>$CRED_ID</credentialsId>
  </launcher>
  <label>$LABELS</label>
  <nodeProperties/>
  <userId>$USERID</userId>
</slave>
EOF

  sleep 10
  
  # Creating node using node.xml
  cat /tmp/node.xml | $jenkins_cmd create-node $NODE_NAME
}

### script begins here ###

apt update
apt install -y openjdk-8-jre-headless python

wait_for_jenkins

slave_setup

echo "Done"
exit 0
