// -------------------------------------------------------------------
//
// Module:         dotnetsample
// Submodule:      Jenkinsfile
// Environments:   all
// Purpose:        Jenkins scripted pipeline to perform the CI and CD
//                 build of the dotnetsample repo.
//                 NOTE: Scripted pipeline
//
// Created on:     15 August 2019
// Created by:     David Sanders
// Creator email:  dsanderscanada@nospam-gmail.com
//
// -------------------------------------------------------------------
// Modifed On   | Modified By                 | Release Notes
// -------------------------------------------------------------------
// 15 Aug 2019  | David Sanders               | First release.
// -------------------------------------------------------------------

def major = '19'
def minor = '08'
def imageName = ''
def shortName = ''

podTemplate(containers: [
    containerTemplate(name: 'dotnetcore', image: 'k8s-master:32084/dotnet/core/sdk:2.2', ttyEnabled: true, command: 'cat'),
    containerTemplate(name: 'maven', image: 'k8s-master:32080/maven:3.6.1-jdk-11-slim', ttyEnabled: true, command: 'cat'),
    containerTemplate(name: 'docker', image: 'k8s-master:32080/docker:19.03.1-dind', ttyEnabled: true, privileged: true),
  ],
  ) {
  node(POD_LABEL) {
    stage('Setup environment') {
        if ( (env.BRANCH_NAME).equals('master') ) {
            shortName = "dotnetsample.${major}.${minor}.${env.BUILD_NUMBER}"
            imageName = "dsanderscan/dotnetsample:${major}.${minor}.${env.BUILD_NUMBER}"
        } else {
            shortName = "dotnetsample.${env.BRANCH_NAME}.${env.BUILD_NUMBER}"
            imageName = "dsanderscan/dotnetsample:${env.BRANCH_NAME}.${env.BUILD_NUMBER}"
        }
        checkout scm
        container('dotnetcore') {
            sh """
                dotnet --info
                dotnet restore -f
            """
        }
    }
    stage('Build applications') {
        container('dotnetcore') {
            sh 'dotnet build'
        }
    }
    stage('Execute unit tests') {
        container('dotnetcore') {
            try {
                sh """
                    dotnet run
                """
            } finally {
                echo "TBD"
                // junit 'unittest-reports/*.xml'
            }
        }
    }
    stage('Publish the app') {
        container('dotnetcore') {
            try {
                sh """
                    dotnet publish -c Release
                """
            } finally {
                echo "TBD"
                // junit 'unittest-reports/*.xml'
            }
        }
    }
    stage('Sonarqube code coverage') {
        container('maven') {
            def scannerHome = tool 'SonarQube Scanner';
            withSonarQubeEnv('Sonarqube') {
                sh """
                    echo "TBD"
                """
            }
        }
    }
    stage('Quality Gate') {
        container('maven') {
            echo "TBD"
            // def scannerHome = tool 'SonarQube Scanner';
            // timeout(time: 10, unit: 'MINUTES') {
            //     waitForQualityGate abortPipeline: false
            // }
        }
    }
    stage('Docker Build') {
        container('docker') {
            withCredentials([
                [$class: 'UsernamePasswordMultiBinding', 
                credentialsId: 'dockerhub',
                usernameVariable: 'USERNAME', 
                passwordVariable: 'PASSWORD']
            ]) {
                sh """
                    echo "Adding k8s_master  ${env.k8s_master}"
                    echo "${env.k8s_master}    k8s-master" >> /etc/hosts
                    echo "Adding daemon.json  ${env.daemon_json}"
                    echo "${env.daemon_json}" > /etc/docker/daemon.json
                    docker login -u "${USERNAME}" -p "${PASSWORD}"
                    docker build -t ${imageName} -f Dockerfile .
                """
            }
        }
    }
    stage('Docker image test') {
        container('docker') {
            sh """
                docker run --rm ${imageName}
            """
        }
    }
    stage('Docker push') {
        container('docker') {
            sh """
                docker push ${imageName}
            """
        }
    }
    stage('Tidy up') {
        container('docker') {
            sh """
                docker image rm ${imageName}
            """
        }
    }
  }
}
