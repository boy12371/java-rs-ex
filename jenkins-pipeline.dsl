node {
stage 'build'
openshiftBuild(buildConfig: 'master', showBuildLogs: 'true')
stage 'deploy integration'
openshiftVerifyDeployment(deploymentConfig: 'master')
stage 'test integration'
sh 'curl -i -s http://master-eap-integration.192.168.122.109.xip.io/rest/json | head -1 |grep 200; exit $?'
stage 'promote to uat'
openshiftTag(alias: 'false', apiURL: '', authToken: '', destStream: 'helloworld', destTag: 'master', destinationAuthToken: '', destinationNamespace: 'eap-uat', namespace: 'eap-integration', srcStream: 'master', srcTag: 'latest', verbose: 'false')
openshiftTag(alias: 'false', apiURL: '', authToken: '', destStream: 'helloworld', destTag: 'latest', destinationAuthToken: '', destinationNamespace: 'eap-uat', namespace: 'eap-uat', srcStream: 'helloworld', srcTag: 'master', verbose: 'false')
stage 'deploy uat'
openshiftVerifyDeployment(namespace: 'eap-uat', deploymentConfig: 'helloworld')
openshiftScale(namespace: 'eap-uat', deploymentConfig: 'helloworld',replicaCount: '2')
stage 'test uat'
sh 'curl -i -s http://helloworld-eap-uat.192.168.122.109.xip.io/rest/json | head -1 |grep 200; exit $?'
stage 'promote to production'
openshiftTag(alias: 'false', apiURL: '', authToken: '', destStream: 'helloworld', destTag: 'master', destinationAuthToken: '', destinationNamespace: 'eap-production', namespace: 'eap-uat', srcStream: 'helloworld', srcTag: 'master', verbose: 'false')
openshiftTag(alias: 'false', apiURL: '', authToken: '', destStream: 'blue', destTag: 'latest', destinationAuthToken: '', destinationNamespace: 'eap-production', namespace: 'eap-production', srcStream: 'helloworld', srcTag: 'master', verbose: 'false')
stage 'deploy production'
openshiftVerifyDeployment(namespace: 'eap-production', deploymentConfig: 'blue')
openshiftScale(namespace: 'eap-production', deploymentConfig: 'blue', replicaCount: '2')
}
